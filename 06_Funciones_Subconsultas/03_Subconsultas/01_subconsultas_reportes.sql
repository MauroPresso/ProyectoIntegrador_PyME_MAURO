/* ============================================================
   01_subconsultas_reportes.sql
   Bloque: 06_Funciones_Subconsultas / 03_Subconsultas

   Objetivo:
   - Demostrar subconsultas aplicadas al modelo real del proyecto.
   - Usar IN, EXISTS, NOT EXISTS, subconsulta escalar,
     subconsulta correlacionada y tablas derivadas.
   - Mantener el script como consulta de solo lectura.

   Base de datos: BaseDeDatos_PyME
   Motor: SQL Server
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
GO

PRINT '1) CLIENTES QUE TIENEN FACTURAS - SUBCONSULTA CON EXISTS';

SELECT
    c.id_cliente,
    c.numero_documento,
    CASE
        WHEN c.tipo_persona = 'F' THEN COALESCE(c.nombre, '') + ' ' + COALESCE(c.apellido, '')
        WHEN c.tipo_persona = 'J' THEN c.razon_social
    END AS cliente,
    tc.tipo AS tipo_cliente
FROM dbo.CLIENTES c
INNER JOIN dbo.TIPOS_CLIENTE tc
    ON c.id_tipo_cliente = tc.id_tipo_cliente
WHERE EXISTS
(
    SELECT 1
    FROM dbo.FACTURAS f
    WHERE f.id_cliente = c.id_cliente
)
ORDER BY c.id_cliente;
GO

PRINT '2) CLIENTES SIN FACTURAS - SUBCONSULTA CON NOT EXISTS';

SELECT
    c.id_cliente,
    c.numero_documento,
    CASE
        WHEN c.tipo_persona = 'F' THEN COALESCE(c.nombre, '') + ' ' + COALESCE(c.apellido, '')
        WHEN c.tipo_persona = 'J' THEN c.razon_social
    END AS cliente,
    tc.tipo AS tipo_cliente
FROM dbo.CLIENTES c
INNER JOIN dbo.TIPOS_CLIENTE tc
    ON c.id_tipo_cliente = tc.id_tipo_cliente
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.FACTURAS f
    WHERE f.id_cliente = c.id_cliente
)
ORDER BY c.id_cliente;
GO

PRINT '3) PRODUCTOS O SERVICIOS FACTURADOS - SUBCONSULTA CON IN';

SELECT
    ps.id_producto_servicio,
    ps.nombre,
    ps.precio_unitario_actual,
    ps.stock_actual,
    cp.nombre AS categoria
FROM dbo.PRODUCTOS_SERVICIOS ps
INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
    ON ps.id_categoria = cp.id_categoria
WHERE ps.id_producto_servicio IN
(
    SELECT DISTINCT df.id_producto_servicio
    FROM dbo.DETALLES_FACTURA df
)
ORDER BY ps.id_producto_servicio;
GO

PRINT '4) FACTURAS CON TOTAL SUPERIOR AL PROMEDIO - SUBCONSULTA ESCALAR';

SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    f.total,
    (
        SELECT AVG(CAST(f_prom.total AS DECIMAL(12,2)))
        FROM dbo.FACTURAS f_prom
    ) AS promedio_general_facturas
FROM dbo.FACTURAS f
WHERE f.total >
(
    SELECT AVG(CAST(f_prom.total AS DECIMAL(12,2)))
    FROM dbo.FACTURAS f_prom
)
ORDER BY f.total DESC;
GO

PRINT '5) TOTAL FACTURADO POR CLIENTE - TABLA DERIVADA PARA AGRUPAR ANTES DE UNIR';

SELECT
    c.id_cliente,
    c.numero_documento,
    CASE
        WHEN c.tipo_persona = 'F' THEN COALESCE(c.nombre, '') + ' ' + COALESCE(c.apellido, '')
        WHEN c.tipo_persona = 'J' THEN c.razon_social
    END AS cliente,
    totales.cantidad_facturas,
    totales.total_facturado
FROM dbo.CLIENTES c
INNER JOIN
(
    SELECT
        f.id_cliente,
        COUNT(*) AS cantidad_facturas,
        SUM(f.total) AS total_facturado
    FROM dbo.FACTURAS f
    GROUP BY f.id_cliente
) AS totales
    ON c.id_cliente = totales.id_cliente
ORDER BY totales.total_facturado DESC, c.id_cliente;
GO

PRINT '6) ULTIMA FACTURA DE CADA CLIENTE - SUBCONSULTA CORRELACIONADA';

SELECT
    f.id_factura,
    f.id_cliente,
    c.numero_documento,
    CASE
        WHEN c.tipo_persona = 'F' THEN COALESCE(c.nombre, '') + ' ' + COALESCE(c.apellido, '')
        WHEN c.tipo_persona = 'J' THEN c.razon_social
    END AS cliente,
    f.numero_factura,
    f.fecha_emision,
    f.total
FROM dbo.FACTURAS f
INNER JOIN dbo.CLIENTES c
    ON f.id_cliente = c.id_cliente
WHERE f.fecha_emision =
(
    SELECT MAX(f2.fecha_emision)
    FROM dbo.FACTURAS f2
    WHERE f2.id_cliente = f.id_cliente
)
ORDER BY f.fecha_emision DESC, f.id_factura DESC;
GO

PRINT '7) PRODUCTOS CON IMPORTE FACTURADO MAYOR AL PROMEDIO - TABLA DERIVADA Y SUBCONSULTA';

SELECT
    ventas_producto.id_producto_servicio,
    ps.nombre,
    ventas_producto.cantidad_vendida,
    ventas_producto.importe_facturado
FROM
(
    SELECT
        df.id_producto_servicio,
        SUM(df.cantidad) AS cantidad_vendida,
        SUM(df.subtotal_con_impuesto) AS importe_facturado
    FROM dbo.DETALLES_FACTURA df
    GROUP BY df.id_producto_servicio
) AS ventas_producto
INNER JOIN dbo.PRODUCTOS_SERVICIOS ps
    ON ventas_producto.id_producto_servicio = ps.id_producto_servicio
WHERE ventas_producto.importe_facturado >
(
    SELECT AVG(promedios.importe_facturado)
    FROM
    (
        SELECT
            df2.id_producto_servicio,
            SUM(df2.subtotal_con_impuesto) AS importe_facturado
        FROM dbo.DETALLES_FACTURA df2
        GROUP BY df2.id_producto_servicio
    ) AS promedios
)
ORDER BY ventas_producto.importe_facturado DESC;
GO

PRINT '8) FACTURAS CON DETALLE CALCULADO POR SUBCONSULTA DERIVADA';

SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    detalle.cantidad_items,
    detalle.total_neto_calculado,
    detalle.total_impuestos_calculado,
    detalle.total_con_impuesto_calculado,
    f.total AS total_guardado_en_factura
FROM dbo.FACTURAS f
INNER JOIN
(
    SELECT
        df.id_factura,
        COUNT(*) AS cantidad_items,
        SUM(df.subtotal_neto) AS total_neto_calculado,
        SUM(df.importe_impuesto) AS total_impuestos_calculado,
        SUM(df.subtotal_con_impuesto) AS total_con_impuesto_calculado
    FROM dbo.DETALLES_FACTURA df
    GROUP BY df.id_factura
) AS detalle
    ON f.id_factura = detalle.id_factura
ORDER BY f.id_factura;
GO

PRINT 'Script de subconsultas finalizado.';
GO
