/* ============================================================
   01_SELECT_FILTROS_AGRUPACIONES_JOINS.SQL
   Proyecto Integrador BDD - PyME Genérica
   Motor: SQL Server
   Base de datos: BaseDeDatos_PyME
   Ubicación sugerida:
   05_CRUD\02_Read_Select

   Objetivo:
   Demostrar operación READ del CRUD mediante SELECT.
   Incluye filtros, agrupaciones, ordenamientos y JOINs.

   Requisito previo:
   Haber ejecutado previamente:
   - creación de base de datos
   - creación de tablas
   - inserts de datos iniciales / datos de prueba
   - opcionalmente el script CRUD INSERT
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

/* ============================================================
   1. SELECT con filtros simples
   Clientes activos de Neuquén o Río Negro
   ============================================================ */

SELECT
    c.id_cliente,
    c.tipo_persona,
    c.numero_documento,
    COALESCE(c.razon_social, CONCAT(c.apellido, ', ', c.nombre)) AS cliente,
    tc.tipo AS tipo_cliente,
    ec.estado AS estado_cliente,
    l.nombre AS localidad,
    p.nombre AS provincia,
    c.telefono,
    c.email
FROM dbo.CLIENTES c
INNER JOIN dbo.TIPOS_CLIENTE tc
    ON tc.id_tipo_cliente = c.id_tipo_cliente
INNER JOIN dbo.ESTADOS_CLIENTES ec
    ON ec.id_estado_cliente = c.id_estado_cliente
INNER JOIN dbo.LOCALIDADES l
    ON l.id_localidad = c.id_localidad
INNER JOIN dbo.PROVINCIAS p
    ON p.id_provincia = l.id_provincia
WHERE ec.estado = 'Activo'
  AND p.nombre IN ('Neuquén', 'Río Negro')
ORDER BY p.nombre, l.nombre, cliente;
GO

/* ============================================================
   2. SELECT con filtros por precio, stock y estado activo
   Productos/servicios disponibles para vender
   ============================================================ */

SELECT
    ps.id_producto_servicio,
    ps.nombre AS producto_servicio,
    cp.nombre AS categoria,
    i.impuesto,
    i.porcentaje AS porcentaje_impuesto,
    ps.precio_unitario_actual,
    ps.stock_actual,
    ps.activo
FROM dbo.PRODUCTOS_SERVICIOS ps
INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
    ON cp.id_categoria = ps.id_categoria
INNER JOIN dbo.IMPUESTOS i
    ON i.id_impuesto = ps.id_impuesto
WHERE ps.activo = 1
  AND ps.precio_unitario_actual > 0
  AND ps.stock_actual >= 0
ORDER BY cp.nombre, ps.nombre;
GO

/* ============================================================
   3. SELECT con JOINs completos
   Facturas con cliente, usuario, detalle, producto, impuesto
   y comprobante de pago
   ============================================================ */

SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    ef.estado AS estado_factura,
    tf.tipo AS tipo_factura,
    tof.operacion AS tipo_operacion,
    COALESCE(c.razon_social, CONCAT(c.apellido, ', ', c.nombre)) AS cliente,
    td.tipo AS tipo_documento,
    c.numero_documento,
    l.nombre AS localidad,
    p.nombre AS provincia,
    u.nombre_usuario AS usuario_emisor,
    df.id_detalle_factura,
    ps.nombre AS producto_servicio,
    cat.nombre AS categoria,
    df.cantidad,
    df.precio_unitario_facturado,
    df.subtotal_neto,
    df.porcentaje_impuesto_facturado,
    df.importe_impuesto,
    df.subtotal_con_impuesto,
    fp.forma_pago,
    cpago.monto AS monto_pagado,
    cpago.numero_referencia
FROM dbo.FACTURAS f
INNER JOIN dbo.CLIENTES c
    ON c.id_cliente = f.id_cliente
INNER JOIN dbo.TIPOS_DOCUMENTO td
    ON td.id_tipo_documento = c.id_tipo_documento
INNER JOIN dbo.LOCALIDADES l
    ON l.id_localidad = c.id_localidad
INNER JOIN dbo.PROVINCIAS p
    ON p.id_provincia = l.id_provincia
INNER JOIN dbo.USUARIOS u
    ON u.id_usuario = f.id_usuario
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON ef.id_estado_factura = f.id_estado_factura
INNER JOIN dbo.TIPOS_FACTURA tf
    ON tf.id_tipo_factura = f.id_tipo_factura
INNER JOIN dbo.TIPOS_OPERACION_FACTURA tof
    ON tof.id_tipo_operacion_factura = f.id_tipo_operacion_factura
INNER JOIN dbo.DETALLES_FACTURA df
    ON df.id_factura = f.id_factura
INNER JOIN dbo.PRODUCTOS_SERVICIOS ps
    ON ps.id_producto_servicio = df.id_producto_servicio
INNER JOIN dbo.CATEGORIAS_PRODUCTO cat
    ON cat.id_categoria = ps.id_categoria
LEFT JOIN dbo.COMPROBANTES_PAGO cpago
    ON cpago.id_factura = f.id_factura
LEFT JOIN dbo.FORMAS_PAGO fp
    ON fp.id_forma_pago = cpago.id_forma_pago
WHERE f.fecha_emision >= DATEADD(DAY, -365, GETDATE())
ORDER BY f.fecha_emision DESC, f.numero_factura, df.id_detalle_factura;
GO

/* ============================================================
   4. SELECT con agrupación por cliente
   Total facturado por cliente
   ============================================================ */

SELECT
    c.id_cliente,
    COALESCE(c.razon_social, CONCAT(c.apellido, ', ', c.nombre)) AS cliente,
    c.numero_documento,
    COUNT(f.id_factura) AS cantidad_facturas,
    SUM(f.total_neto) AS total_neto_facturado,
    SUM(f.total_impuestos) AS total_impuestos_facturados,
    SUM(f.total) AS total_facturado
FROM dbo.CLIENTES c
INNER JOIN dbo.FACTURAS f
    ON f.id_cliente = c.id_cliente
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON ef.id_estado_factura = f.id_estado_factura
WHERE ef.estado <> 'Anulada'
GROUP BY
    c.id_cliente,
    c.razon_social,
    c.apellido,
    c.nombre,
    c.numero_documento
HAVING SUM(f.total) > 0
ORDER BY total_facturado DESC;
GO

/* ============================================================
   5. SELECT con agrupación por provincia y mes
   Ventas mensuales por provincia
   ============================================================ */

SELECT
    p.nombre AS provincia,
    YEAR(f.fecha_emision) AS anio,
    MONTH(f.fecha_emision) AS mes,
    COUNT(DISTINCT f.id_factura) AS cantidad_facturas,
    SUM(f.total_neto) AS total_neto,
    SUM(f.total_impuestos) AS total_impuestos,
    SUM(f.total) AS total_facturado
FROM dbo.FACTURAS f
INNER JOIN dbo.CLIENTES c
    ON c.id_cliente = f.id_cliente
INNER JOIN dbo.LOCALIDADES l
    ON l.id_localidad = c.id_localidad
INNER JOIN dbo.PROVINCIAS p
    ON p.id_provincia = l.id_provincia
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON ef.id_estado_factura = f.id_estado_factura
WHERE ef.estado <> 'Anulada'
GROUP BY
    p.nombre,
    YEAR(f.fecha_emision),
    MONTH(f.fecha_emision)
ORDER BY anio DESC, mes DESC, total_facturado DESC;
GO

/* ============================================================
   6. SELECT con agrupación por producto/servicio
   Productos o servicios más vendidos
   ============================================================ */

SELECT
    ps.id_producto_servicio,
    ps.nombre AS producto_servicio,
    cat.nombre AS categoria,
    SUM(df.cantidad) AS cantidad_total_vendida,
    SUM(df.subtotal_neto) AS total_neto_vendido,
    SUM(df.importe_impuesto) AS total_impuestos,
    SUM(df.subtotal_con_impuesto) AS total_con_impuestos
FROM dbo.DETALLES_FACTURA df
INNER JOIN dbo.FACTURAS f
    ON f.id_factura = df.id_factura
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON ef.id_estado_factura = f.id_estado_factura
INNER JOIN dbo.PRODUCTOS_SERVICIOS ps
    ON ps.id_producto_servicio = df.id_producto_servicio
INNER JOIN dbo.CATEGORIAS_PRODUCTO cat
    ON cat.id_categoria = ps.id_categoria
WHERE ef.estado <> 'Anulada'
GROUP BY
    ps.id_producto_servicio,
    ps.nombre,
    cat.nombre
ORDER BY cantidad_total_vendida DESC, total_con_impuestos DESC;
GO

/* ============================================================
   7. SELECT con LEFT JOIN
   Facturas emitidas que no tienen comprobante de pago
   ============================================================ */

SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    COALESCE(c.razon_social, CONCAT(c.apellido, ', ', c.nombre)) AS cliente,
    ef.estado AS estado_factura,
    f.total,
    cpago.id_comprobante_pago
FROM dbo.FACTURAS f
INNER JOIN dbo.CLIENTES c
    ON c.id_cliente = f.id_cliente
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON ef.id_estado_factura = f.id_estado_factura
LEFT JOIN dbo.COMPROBANTES_PAGO cpago
    ON cpago.id_factura = f.id_factura
WHERE cpago.id_comprobante_pago IS NULL
  AND ef.estado <> 'Anulada'
ORDER BY f.fecha_emision DESC;
GO
