/* ============================================================
   03_pruebas_rendimiento_consultas.sql
   Proyecto Integrador BDD - PyME Generica

   Ubicacion:
   07_Pruebas_Optimizacion\Indices_y_Rendimiento

   Objetivo:
   Medir tiempos e IO de consultas relevantes.

   Forma de uso:
   1) Ejecutar 01_eliminar_indices_optimizacion.sql
   2) Ejecutar este script y guardar captura: SIN INDICES
   3) Ejecutar 02_crear_indices_optimizacion.sql
   4) Ejecutar este script y guardar captura: CON INDICES
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

DECLARE @inicio DATETIME2(7);
DECLARE @fin DATETIME2(7);

PRINT 'PRUEBA 1 - Total facturado por mes';

SET @inicio = SYSDATETIME();

SELECT
    YEAR(f.fecha_emision) AS anio,
    MONTH(f.fecha_emision) AS mes,
    SUM(f.total_neto) AS total_neto,
    SUM(f.total_impuestos) AS total_impuestos,
    SUM(f.total_descuentos) AS total_descuentos,
    SUM(f.total_recargos) AS total_recargos,
    SUM(f.total) AS total_facturado
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON ef.id_estado_factura = f.id_estado_factura
WHERE ef.estado = 'Pagada'
GROUP BY
    YEAR(f.fecha_emision),
    MONTH(f.fecha_emision)
ORDER BY
    anio,
    mes;

SET @fin = SYSDATETIME();

SELECT
    'PRUEBA 1 - Total facturado por mes' AS prueba,
    DATEDIFF(MICROSECOND, @inicio, @fin) AS duracion_microsegundos_aproximada;

PRINT 'PRUEBA 2 - Productos o servicios mas vendidos';

SET @inicio = SYSDATETIME();

SELECT TOP (10)
    ps.nombre AS producto_servicio,
    SUM(df.cantidad) AS cantidad_total,
    SUM(df.subtotal_neto) AS total_neto,
    SUM(df.importe_impuesto) AS total_impuestos,
    SUM(df.subtotal_con_impuesto) AS total_con_impuesto
FROM dbo.DETALLES_FACTURA df
INNER JOIN dbo.PRODUCTOS_SERVICIOS ps
    ON ps.id_producto_servicio = df.id_producto_servicio
INNER JOIN dbo.FACTURAS f
    ON f.id_factura = df.id_factura
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON ef.id_estado_factura = f.id_estado_factura
WHERE ef.estado <> 'Anulada'
GROUP BY ps.nombre
ORDER BY
    cantidad_total DESC,
    total_con_impuesto DESC;

SET @fin = SYSDATETIME();

SELECT
    'PRUEBA 2 - Productos o servicios mas vendidos' AS prueba,
    DATEDIFF(MICROSECOND, @inicio, @fin) AS duracion_microsegundos_aproximada;

PRINT 'PRUEBA 3 - Clientes con mayor monto facturado';

SET @inicio = SYSDATETIME();

SELECT TOP (10)
    CASE
        WHEN c.tipo_persona = 'F'
            THEN c.nombre + ' ' + c.apellido
        ELSE c.razon_social
    END AS cliente,
    c.tipo_persona,
    COUNT(f.id_factura) AS cantidad_facturas,
    SUM(f.total) AS total_facturado
FROM dbo.FACTURAS f
INNER JOIN dbo.CLIENTES c
    ON c.id_cliente = f.id_cliente
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON ef.id_estado_factura = f.id_estado_factura
WHERE ef.estado <> 'Anulada'
GROUP BY
    c.id_cliente,
    c.tipo_persona,
    c.nombre,
    c.apellido,
    c.razon_social
ORDER BY total_facturado DESC;

SET @fin = SYSDATETIME();

SELECT
    'PRUEBA 3 - Clientes con mayor monto facturado' AS prueba,
    DATEDIFF(MICROSECOND, @inicio, @fin) AS duracion_microsegundos_aproximada;

PRINT 'PRUEBA 4 - Facturas con cliente, usuario, estado y tipo';

SET @inicio = SYSDATETIME();

SELECT
    f.numero_factura,
    f.fecha_emision,
    CASE
        WHEN c.tipo_persona = 'F'
            THEN c.nombre + ' ' + c.apellido
        ELSE c.razon_social
    END AS cliente,
    u.nombre_completo AS usuario_emisor,
    ef.estado AS estado_factura,
    tf.tipo AS tipo_factura,
    tof.operacion AS tipo_operacion,
    f.total_neto,
    f.total_impuestos,
    f.total_descuentos,
    f.total_recargos,
    f.total
FROM dbo.FACTURAS f
INNER JOIN dbo.CLIENTES c
    ON c.id_cliente = f.id_cliente
INNER JOIN dbo.USUARIOS u
    ON u.id_usuario = f.id_usuario
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON ef.id_estado_factura = f.id_estado_factura
INNER JOIN dbo.TIPOS_FACTURA tf
    ON tf.id_tipo_factura = f.id_tipo_factura
INNER JOIN dbo.TIPOS_OPERACION_FACTURA tof
    ON tof.id_tipo_operacion_factura = f.id_tipo_operacion_factura
ORDER BY f.fecha_emision;

SET @fin = SYSDATETIME();

SELECT
    'PRUEBA 4 - Facturas con cliente, usuario, estado y tipo' AS prueba,
    DATEDIFF(MICROSECOND, @inicio, @fin) AS duracion_microsegundos_aproximada;

PRINT 'PRUEBA 5 - Control de consistencia cabecera/detalle';

SET @inicio = SYSDATETIME();

SELECT
    f.numero_factura,
    f.total_neto AS total_neto_cabecera,
    ISNULL(SUM(df.subtotal_neto), 0) AS total_neto_detalle,
    f.total_impuestos AS total_impuestos_cabecera,
    ISNULL(SUM(df.importe_impuesto), 0) AS total_impuestos_detalle,
    CASE
        WHEN f.total_neto = ISNULL(SUM(df.subtotal_neto), 0)
         AND f.total_impuestos = ISNULL(SUM(df.importe_impuesto), 0)
            THEN 'OK'
        ELSE 'REVISAR'
    END AS estado_control
FROM dbo.FACTURAS f
LEFT JOIN dbo.DETALLES_FACTURA df
    ON df.id_factura = f.id_factura
GROUP BY
    f.numero_factura,
    f.total_neto,
    f.total_impuestos
ORDER BY f.numero_factura;

SET @fin = SYSDATETIME();

SELECT
    'PRUEBA 5 - Control de consistencia cabecera/detalle' AS prueba,
    DATEDIFF(MICROSECOND, @inicio, @fin) AS duracion_microsegundos_aproximada;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT 'Pruebas de rendimiento finalizadas.';
GO
