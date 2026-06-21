/* ============================================================
   01_funciones_fecha_facturas.sql
   Bloque: 06_Funciones_Subconsultas / 02_Funciones_Fecha

   Objetivo:
   - Demostrar funciones de fecha solicitadas en la consigna:
     GETDATE y DATEDIFF.
   - Calcular antiguedad de facturas y demora de pago.
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

PRINT '1) FECHA Y HORA ACTUAL DEL SERVIDOR SQL SERVER CON GETDATE';

SELECT
    GETDATE() AS fecha_hora_actual_servidor;
GO

PRINT '2) ANTIGUEDAD DE FACTURAS CON GETDATE Y DATEDIFF';

SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    GETDATE() AS fecha_actual,
    DATEDIFF(DAY, f.fecha_emision, GETDATE()) AS dias_desde_emision,
    DATEDIFF(HOUR, f.fecha_emision, GETDATE()) AS horas_desde_emision,
    ef.estado AS estado_factura,
    f.total
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
ORDER BY f.fecha_emision DESC, f.id_factura DESC;
GO

PRINT '3) DIAS ENTRE EMISION Y PAGO DE CADA FACTURA';

SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    cp.fecha_pago,
    CASE
        WHEN cp.fecha_pago IS NULL THEN 'Sin comprobante de pago'
        ELSE 'Con comprobante de pago'
    END AS estado_pago,
    DATEDIFF(DAY, f.fecha_emision, COALESCE(cp.fecha_pago, GETDATE())) AS dias_hasta_pago_o_actualidad,
    DATEDIFF(HOUR, f.fecha_emision, COALESCE(cp.fecha_pago, GETDATE())) AS horas_hasta_pago_o_actualidad,
    f.total,
    cp.monto AS monto_pagado
FROM dbo.FACTURAS f
LEFT JOIN dbo.COMPROBANTES_PAGO cp
    ON f.id_factura = cp.id_factura
ORDER BY f.fecha_emision DESC, f.id_factura DESC;
GO

PRINT '4) CLASIFICACION DE FACTURAS SEGUN ANTIGUEDAD';

SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    DATEDIFF(DAY, f.fecha_emision, GETDATE()) AS dias_desde_emision,
    CASE
        WHEN DATEDIFF(DAY, f.fecha_emision, GETDATE()) = 0 THEN 'Emitida hoy'
        WHEN DATEDIFF(DAY, f.fecha_emision, GETDATE()) BETWEEN 1 AND 7 THEN 'Antiguedad menor o igual a una semana'
        WHEN DATEDIFF(DAY, f.fecha_emision, GETDATE()) BETWEEN 8 AND 30 THEN 'Antiguedad menor o igual a un mes'
        ELSE 'Antiguedad mayor a un mes'
    END AS clasificacion_antiguedad,
    ef.estado AS estado_factura,
    f.total
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
ORDER BY DATEDIFF(DAY, f.fecha_emision, GETDATE()) DESC, f.id_factura;
GO

PRINT '5) PROMEDIO DE DIAS DE DEMORA AGRUPADO POR ESTADO DE FACTURA';

SELECT
    ef.estado AS estado_factura,
    COUNT(*) AS cantidad_facturas,
    AVG(CAST(DATEDIFF(DAY, f.fecha_emision, COALESCE(cp.fecha_pago, GETDATE())) AS DECIMAL(12,2))) AS promedio_dias_emision_a_pago_o_actualidad,
    MIN(DATEDIFF(DAY, f.fecha_emision, COALESCE(cp.fecha_pago, GETDATE()))) AS minimo_dias,
    MAX(DATEDIFF(DAY, f.fecha_emision, COALESCE(cp.fecha_pago, GETDATE()))) AS maximo_dias
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
LEFT JOIN dbo.COMPROBANTES_PAGO cp
    ON f.id_factura = cp.id_factura
GROUP BY ef.estado
ORDER BY ef.estado;
GO

PRINT 'Script de funciones de fecha finalizado.';
GO
