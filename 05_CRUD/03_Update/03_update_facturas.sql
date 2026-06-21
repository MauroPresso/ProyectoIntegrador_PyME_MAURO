/* ============================================================
   03_update_facturas.sql
   Bloque: 05_CRUD / 03_Update

   Objetivo:
   - Actualizar observaciones de factura.
   - Recalcular totales desde los detalles, descuentos y recargos.
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

DECLARE @id_factura INT;

SELECT @id_factura = id_factura
FROM dbo.FACTURAS
WHERE numero_factura = 'F-CRUD-0001';

IF @id_factura IS NULL
    THROW 60301, 'No existe la factura F-CRUD-0001. Ejecutar primero 03_insert_facturas.sql.', 1;

UPDATE dbo.FACTURAS
SET observaciones = 'Factura actualizada desde script CRUD directo.'
WHERE id_factura = @id_factura;

/* Recalculo de totales de cabecera */
UPDATE f
SET
    total_neto = COALESCE(det.total_neto, 0),
    total_impuestos = COALESCE(det.total_impuestos, 0),
    total_descuentos = COALESCE(descu.total_descuentos, 0),
    total_recargos = COALESCE(recar.total_recargos, 0),
    total = COALESCE(det.total_neto, 0)
          + COALESCE(det.total_impuestos, 0)
          - COALESCE(descu.total_descuentos, 0)
          + COALESCE(recar.total_recargos, 0)
FROM dbo.FACTURAS f
OUTER APPLY
(
    SELECT
        SUM(subtotal_neto) AS total_neto,
        SUM(importe_impuesto) AS total_impuestos
    FROM dbo.DETALLES_FACTURA
    WHERE id_factura = f.id_factura
) det
OUTER APPLY
(
    SELECT SUM(monto) AS total_descuentos
    FROM dbo.DESCUENTOS_FACTURA
    WHERE id_factura = f.id_factura
) descu
OUTER APPLY
(
    SELECT SUM(monto) AS total_recargos
    FROM dbo.RECARGOS_FACTURA
    WHERE id_factura = f.id_factura
) recar
WHERE f.id_factura = @id_factura;

SELECT
    f.id_factura,
    f.numero_factura,
    ef.estado AS estado_factura,
    f.total_neto,
    f.total_impuestos,
    f.total_descuentos,
    f.total_recargos,
    f.total,
    f.observaciones
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
WHERE f.id_factura = @id_factura;
GO
