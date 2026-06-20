/* ============================================================
   CONSULTAS.SQL
   Ubicación: 04_SQLServer_Modelo_Fisico\04_Consultas
   ============================================================ */
USE BaseDeDatos_PyME;
GO
SET NOCOUNT ON;
GO

-- 1. Total facturado por mes, solo facturas pagadas.
SELECT YEAR(f.fecha_emision) AS anio, MONTH(f.fecha_emision) AS mes,
       SUM(f.total_neto) AS total_neto,
       SUM(f.total_impuestos) AS total_impuestos,
       SUM(f.total_descuentos) AS total_descuentos,
       SUM(f.total_recargos) AS total_recargos,
       SUM(f.total) AS total_facturado
FROM dbo.FACTURAS f
JOIN dbo.ESTADOS_FACTURA ef ON ef.id_estado_factura = f.id_estado_factura
WHERE ef.estado = 'Pagada'
GROUP BY YEAR(f.fecha_emision), MONTH(f.fecha_emision)
ORDER BY anio, mes;
GO

-- 2. Productos o servicios más vendidos.
SELECT TOP 10 ps.nombre AS producto_servicio,
       SUM(df.cantidad) AS cantidad_total,
       SUM(df.subtotal_neto) AS total_neto,
       SUM(df.importe_impuesto) AS total_impuestos,
       SUM(df.subtotal_con_impuesto) AS total_con_impuesto
FROM dbo.DETALLES_FACTURA df
JOIN dbo.PRODUCTOS_SERVICIOS ps ON ps.id_producto_servicio = df.id_producto_servicio
JOIN dbo.FACTURAS f ON f.id_factura = df.id_factura
JOIN dbo.ESTADOS_FACTURA ef ON ef.id_estado_factura = f.id_estado_factura
WHERE ef.estado <> 'Anulada'
GROUP BY ps.nombre
ORDER BY cantidad_total DESC, total_con_impuesto DESC;
GO

-- 3. Clientes con mayor monto facturado.
SELECT TOP 10
       CASE WHEN c.tipo_persona = 'F' THEN c.nombre + ' ' + c.apellido ELSE c.razon_social END AS cliente,
       c.tipo_persona,
       COUNT(f.id_factura) AS cantidad_facturas,
       SUM(f.total) AS total_facturado
FROM dbo.FACTURAS f
JOIN dbo.CLIENTES c ON c.id_cliente = f.id_cliente
JOIN dbo.ESTADOS_FACTURA ef ON ef.id_estado_factura = f.id_estado_factura
WHERE ef.estado <> 'Anulada'
GROUP BY c.id_cliente, c.tipo_persona, c.nombre, c.apellido, c.razon_social
ORDER BY total_facturado DESC;
GO

-- 4. Cabecera de facturas con cliente, usuario, estado y tipo.
SELECT f.numero_factura, f.fecha_emision,
       CASE WHEN c.tipo_persona = 'F' THEN c.nombre + ' ' + c.apellido ELSE c.razon_social END AS cliente,
       u.nombre_completo AS usuario_emisor,
       ef.estado AS estado_factura,
       tf.tipo AS tipo_factura,
       tof.operacion AS tipo_operacion,
       f.total_neto, f.total_impuestos, f.total_descuentos, f.total_recargos, f.total
FROM dbo.FACTURAS f
JOIN dbo.CLIENTES c ON c.id_cliente = f.id_cliente
JOIN dbo.USUARIOS u ON u.id_usuario = f.id_usuario
JOIN dbo.ESTADOS_FACTURA ef ON ef.id_estado_factura = f.id_estado_factura
JOIN dbo.TIPOS_FACTURA tf ON tf.id_tipo_factura = f.id_tipo_factura
JOIN dbo.TIPOS_OPERACION_FACTURA tof ON tof.id_tipo_operacion_factura = f.id_tipo_operacion_factura
ORDER BY f.fecha_emision;
GO

-- 5. Detalle completo de facturas con impuestos históricos.
SELECT f.numero_factura, ps.nombre AS producto_servicio,
       df.cantidad, df.precio_unitario_facturado, df.subtotal_neto,
       df.porcentaje_impuesto_facturado, df.importe_impuesto, df.subtotal_con_impuesto
FROM dbo.DETALLES_FACTURA df
JOIN dbo.FACTURAS f ON f.id_factura = df.id_factura
JOIN dbo.PRODUCTOS_SERVICIOS ps ON ps.id_producto_servicio = df.id_producto_servicio
ORDER BY f.numero_factura, ps.nombre;
GO

-- 6. Comprobantes de pago asociados a facturas. Relación esperada: 1 a 1.
SELECT f.numero_factura, cp.fecha_pago, fp.forma_pago, cp.monto,
       cp.numero_referencia, cp.observaciones
FROM dbo.COMPROBANTES_PAGO cp
JOIN dbo.FACTURAS f ON f.id_factura = cp.id_factura
JOIN dbo.FORMAS_PAGO fp ON fp.id_forma_pago = cp.id_forma_pago
ORDER BY cp.fecha_pago;
GO

-- 7. Ventas por forma de pago.
SELECT fp.forma_pago,
       COUNT(cp.id_comprobante_pago) AS cantidad_comprobantes,
       SUM(cp.monto) AS monto_total
FROM dbo.COMPROBANTES_PAGO cp
JOIN dbo.FORMAS_PAGO fp ON fp.id_forma_pago = cp.id_forma_pago
GROUP BY fp.forma_pago
ORDER BY monto_total DESC;
GO

-- 8. Productos activos con categoría e impuesto.
SELECT ps.nombre AS producto_servicio, cp.nombre AS categoria,
       i.impuesto, i.porcentaje,
       ps.precio_unitario_actual, ps.stock_actual, ps.activo
FROM dbo.PRODUCTOS_SERVICIOS ps
JOIN dbo.CATEGORIAS_PRODUCTO cp ON cp.id_categoria = ps.id_categoria
JOIN dbo.IMPUESTOS i ON i.id_impuesto = ps.id_impuesto
WHERE ps.activo = 1
ORDER BY cp.nombre, ps.nombre;
GO

-- 9. Facturas con descuentos o recargos.
SELECT f.numero_factura, f.total_neto, f.total_impuestos,
       f.total_descuentos, f.total_recargos, f.total
FROM dbo.FACTURAS f
WHERE f.total_descuentos > 0 OR f.total_recargos > 0
ORDER BY f.numero_factura;
GO

-- 10. Auditoría de facturas.
SELECT f.numero_factura, a.accion, a.fecha,
       u.nombre_completo AS usuario, a.detalle
FROM dbo.AUDITORIA_FACTURA a
JOIN dbo.FACTURAS f ON f.id_factura = a.id_factura
JOIN dbo.USUARIOS u ON u.id_usuario = a.id_usuario
ORDER BY a.fecha;
GO

-- 11. Control de consistencia entre cabecera y detalle.
SELECT f.numero_factura,
       f.total_neto AS total_neto_cabecera,
       ISNULL(SUM(df.subtotal_neto), 0) AS total_neto_detalle,
       f.total_impuestos AS total_impuestos_cabecera,
       ISNULL(SUM(df.importe_impuesto), 0) AS total_impuestos_detalle,
       CASE WHEN f.total_neto = ISNULL(SUM(df.subtotal_neto), 0)
             AND f.total_impuestos = ISNULL(SUM(df.importe_impuesto), 0)
            THEN 'OK' ELSE 'REVISAR' END AS estado_control
FROM dbo.FACTURAS f
LEFT JOIN dbo.DETALLES_FACTURA df ON df.id_factura = f.id_factura
GROUP BY f.numero_factura, f.total_neto, f.total_impuestos
ORDER BY f.numero_factura;
GO
