/* ============================================================
   03_delete_facturas.sql
   Bloque: 05_CRUD / 04_Delete

   Objetivo:
   - Demostrar eliminacion logica de facturas mediante estado Anulada.
   - Restaurar stock de los detalles si la factura no estaba anulada.
   - Demostrar DELETE fisico controlado sobre una factura temporal sin detalles.
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

SET XACT_ABORT ON;
GO

DECLARE
    @id_factura INT,
    @estado_actual VARCHAR(50),
    @id_estado_anulada INT,
    @id_cliente INT,
    @id_usuario INT,
    @id_estado_emitida INT,
    @id_tipo_factura INT,
    @id_tipo_operacion_venta INT,
    @id_factura_temporal INT;

SELECT @id_factura = f.id_factura,
       @estado_actual = ef.estado
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
WHERE f.numero_factura = 'F-CRUD-0001';

SELECT @id_estado_anulada = id_estado_factura
FROM dbo.ESTADOS_FACTURA
WHERE estado = 'Anulada';

IF @id_factura IS NULL
    THROW 60501, 'No existe la factura F-CRUD-0001. Ejecutar primero 03_insert_facturas.sql.', 1;

IF @id_estado_anulada IS NULL
    THROW 60502, 'No existe el estado de factura Anulada.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    /* 1) Baja logica de factura de negocio */
    IF @estado_actual <> 'Anulada'
    BEGIN
        UPDATE ps
        SET ps.stock_actual = ps.stock_actual + CAST(d.cantidad AS INT)
        FROM dbo.PRODUCTOS_SERVICIOS ps
        INNER JOIN dbo.DETALLES_FACTURA d
            ON ps.id_producto_servicio = d.id_producto_servicio
        WHERE d.id_factura = @id_factura;

        UPDATE dbo.FACTURAS
        SET
            id_estado_factura = @id_estado_anulada,
            observaciones = 'Factura anulada desde script CRUD directo.'
        WHERE id_factura = @id_factura;
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;

/* 2) DELETE fisico controlado de factura temporal sin detalles */
SELECT @id_cliente = id_cliente
FROM dbo.CLIENTES
WHERE numero_documento = '20999000111';

SELECT TOP 1 @id_usuario = id_usuario
FROM dbo.USUARIOS
ORDER BY id_usuario;

SELECT @id_estado_emitida = id_estado_factura
FROM dbo.ESTADOS_FACTURA
WHERE estado = 'Emitida';

SELECT TOP 1 @id_tipo_factura = id_tipo_factura
FROM dbo.TIPOS_FACTURA
WHERE tipo IN ('B', 'Factura B')
ORDER BY CASE WHEN tipo = 'B' THEN 0 ELSE 1 END;

SELECT @id_tipo_operacion_venta = id_tipo_operacion_factura
FROM dbo.TIPOS_OPERACION_FACTURA
WHERE operacion = 'Venta';

IF @id_cliente IS NOT NULL
   AND @id_usuario IS NOT NULL
   AND @id_estado_emitida IS NOT NULL
   AND @id_tipo_factura IS NOT NULL
   AND @id_tipo_operacion_venta IS NOT NULL
   AND NOT EXISTS
   (
       SELECT 1
       FROM dbo.FACTURAS
       WHERE numero_factura = 'F-CRUD-DELETE-0001'
   )
BEGIN
    INSERT INTO dbo.FACTURAS
    (
        id_cliente,
        id_usuario,
        id_estado_factura,
        id_tipo_factura,
        id_tipo_operacion_factura,
        numero_factura,
        fecha_emision,
        total_neto,
        total_impuestos,
        total_descuentos,
        total_recargos,
        total,
        observaciones
    )
    VALUES
    (
        @id_cliente,
        @id_usuario,
        @id_estado_emitida,
        @id_tipo_factura,
        @id_tipo_operacion_venta,
        'F-CRUD-DELETE-0001',
        GETDATE(),
        0,
        0,
        0,
        0,
        0,
        'Factura temporal creada solo para demostrar DELETE fisico.'
    );
END;

SELECT @id_factura_temporal = id_factura
FROM dbo.FACTURAS
WHERE numero_factura = 'F-CRUD-DELETE-0001';

DELETE FROM dbo.FACTURAS
WHERE id_factura = @id_factura_temporal
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.DETALLES_FACTURA
      WHERE id_factura = @id_factura_temporal
  )
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.COMPROBANTES_PAGO
      WHERE id_factura = @id_factura_temporal
  )
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.AUDITORIA_FACTURA
      WHERE id_factura = @id_factura_temporal
  )
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.DESCUENTOS_FACTURA
      WHERE id_factura = @id_factura_temporal
  )
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.RECARGOS_FACTURA
      WHERE id_factura = @id_factura_temporal
  );

SELECT
    f.id_factura,
    f.numero_factura,
    ef.estado AS estado_factura,
    f.total,
    f.observaciones
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
WHERE f.numero_factura IN ('F-CRUD-0001', 'F-CRUD-DELETE-0001')
ORDER BY f.id_factura;
GO
