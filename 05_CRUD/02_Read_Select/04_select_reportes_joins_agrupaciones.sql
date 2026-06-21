/* ============================================================
   04_select_reportes_joins_agrupaciones.sql
   Bloque: 05_CRUD / 02_Read_Select

   Objetivo:
   - Demostrar SELECT con filtros, JOINs, GROUP BY, SUM, COUNT y ORDER BY.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

/* 1) Total facturado por estado */
SELECT
    ef.estado AS estado_factura,
    COUNT(f.id_factura) AS cantidad_facturas,
    COALESCE(SUM(f.total_neto), 0) AS total_neto,
    COALESCE(SUM(f.total_impuestos), 0) AS total_impuestos,
    COALESCE(SUM(f.total_descuentos), 0) AS total_descuentos,
    COALESCE(SUM(f.total_recargos), 0) AS total_recargos,
    COALESCE(SUM(f.total), 0) AS total_general
FROM dbo.ESTADOS_FACTURA ef
LEFT JOIN dbo.FACTURAS f
    ON ef.id_estado_factura = f.id_estado_factura
GROUP BY ef.estado
ORDER BY ef.estado;

/* 2) Productos/servicios mas vendidos */
SELECT TOP 10
    ps.id_producto_servicio,
    ps.nombre AS producto_servicio,
    cp.nombre AS categoria,
    SUM(d.cantidad) AS cantidad_vendida,
    SUM(d.subtotal_neto) AS total_neto_vendido,
    SUM(d.importe_impuesto) AS total_impuestos,
    SUM(d.subtotal_con_impuesto) AS total_con_impuestos
FROM dbo.DETALLES_FACTURA d
INNER JOIN dbo.PRODUCTOS_SERVICIOS ps
    ON d.id_producto_servicio = ps.id_producto_servicio
INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
    ON ps.id_categoria = cp.id_categoria
INNER JOIN dbo.FACTURAS f
    ON d.id_factura = f.id_factura
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
WHERE ef.estado <> 'Anulada'
GROUP BY
    ps.id_producto_servicio,
    ps.nombre,
    cp.nombre
ORDER BY cantidad_vendida DESC, total_con_impuestos DESC;

/* 3) Clientes con mayor monto comprado */
SELECT TOP 10
    c.id_cliente,
    CASE
        WHEN c.tipo_persona = 'F'
            THEN c.nombre + ' ' + c.apellido
        ELSE c.razon_social
    END AS cliente,
    c.numero_documento,
    ec.estado AS estado_cliente,
    COUNT(f.id_factura) AS cantidad_facturas,
    COALESCE(SUM(f.total), 0) AS total_comprado
FROM dbo.CLIENTES c
INNER JOIN dbo.ESTADOS_CLIENTES ec
    ON c.id_estado_cliente = ec.id_estado_cliente
LEFT JOIN dbo.FACTURAS f
    ON c.id_cliente = f.id_cliente
LEFT JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
WHERE ef.estado IS NULL OR ef.estado <> 'Anulada'
GROUP BY
    c.id_cliente,
    c.tipo_persona,
    c.nombre,
    c.apellido,
    c.razon_social,
    c.numero_documento,
    ec.estado
ORDER BY total_comprado DESC, cantidad_facturas DESC;

/* 4) Facturacion mensual */
SELECT
    YEAR(f.fecha_emision) AS anio,
    MONTH(f.fecha_emision) AS mes,
    COUNT(f.id_factura) AS cantidad_facturas,
    SUM(f.total) AS total_facturado
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
WHERE ef.estado <> 'Anulada'
GROUP BY
    YEAR(f.fecha_emision),
    MONTH(f.fecha_emision)
ORDER BY anio DESC, mes DESC;
GO
