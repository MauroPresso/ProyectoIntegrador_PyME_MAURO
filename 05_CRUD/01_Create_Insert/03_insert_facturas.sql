/* ============================================================
   03_insert_facturas.sql
   Bloque: 05_CRUD / 01_Create_Insert

   Objetivo:
   - Insertar una factura de prueba con cabecera y detalle.
   - Calcular subtotal, impuesto y total.
   - Descontar stock del producto facturado.
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
    @id_cliente INT,
    @id_usuario INT,
    @id_estado_emitida INT,
    @id_tipo_factura INT,
    @id_tipo_operacion_venta INT,
    @id_producto_servicio INT,
    @id_factura INT,
    @numero_factura VARCHAR(30) = 'F-CRUD-0001',
    @cantidad DECIMAL(12,2) = 2.00,
    @cantidad_stock INT = 2,
    @precio_unitario DECIMAL(12,2),
    @porcentaje_impuesto DECIMAL(5,2),
    @subtotal_neto DECIMAL(12,2),
    @importe_impuesto DECIMAL(12,2),
    @subtotal_con_impuesto DECIMAL(12,2);

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

SELECT
    @id_producto_servicio = ps.id_producto_servicio,
    @precio_unitario = ps.precio_unitario_actual,
    @porcentaje_impuesto = i.porcentaje
FROM dbo.PRODUCTOS_SERVICIOS ps
INNER JOIN dbo.IMPUESTOS i
    ON ps.id_impuesto = i.id_impuesto
WHERE ps.nombre = 'Monitor LED 24 CRUD'
  AND ps.activo = 1;

IF @id_cliente IS NULL
    THROW 60201, 'No existe el cliente de prueba 20999000111. Ejecutar primero 01_insert_clientes.sql.', 1;

IF @id_usuario IS NULL
    THROW 60202, 'No existen usuarios cargados.', 1;

IF @id_estado_emitida IS NULL
    THROW 60203, 'No existe el estado de factura Emitida.', 1;

IF @id_tipo_factura IS NULL
    THROW 60204, 'No existe el tipo de factura B.', 1;

IF @id_tipo_operacion_venta IS NULL
    THROW 60205, 'No existe el tipo de operacion Venta.', 1;

IF @id_producto_servicio IS NULL
    THROW 60206, 'No existe el producto Monitor LED 24 CRUD activo. Ejecutar primero 02_insert_productos_servicios.sql.', 1;

IF EXISTS
(
    SELECT 1
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE id_producto_servicio = @id_producto_servicio
      AND stock_actual < @cantidad_stock
)
    THROW 60207, 'Stock insuficiente para crear la factura de prueba.', 1;

SET @subtotal_neto = @cantidad * @precio_unitario;
SET @importe_impuesto = ROUND(@subtotal_neto * @porcentaje_impuesto / 100, 2);
SET @subtotal_con_impuesto = @subtotal_neto + @importe_impuesto;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.FACTURAS
        WHERE numero_factura = @numero_factura
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
            @numero_factura,
            GETDATE(),
            0,
            0,
            0,
            0,
            0,
            'Factura de prueba creada desde CRUD directo.'
        );

        SET @id_factura = SCOPE_IDENTITY();

        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura,
            id_producto_servicio,
            cantidad,
            precio_unitario_facturado,
            subtotal_neto,
            porcentaje_impuesto_facturado,
            importe_impuesto,
            subtotal_con_impuesto
        )
        VALUES
        (
            @id_factura,
            @id_producto_servicio,
            @cantidad,
            @precio_unitario,
            @subtotal_neto,
            @porcentaje_impuesto,
            @importe_impuesto,
            @subtotal_con_impuesto
        );

        UPDATE dbo.PRODUCTOS_SERVICIOS
        SET stock_actual = stock_actual - @cantidad_stock
        WHERE id_producto_servicio = @id_producto_servicio;

        INSERT INTO dbo.AUDITORIA_FACTURA
        (
            id_factura,
            id_usuario,
            accion,
            detalle
        )
        VALUES
        (
            @id_factura,
            @id_usuario,
            'INSERT_DIRECTO',
            'Factura creada desde script CRUD directo.'
        );
    END
    ELSE
    BEGIN
        SELECT @id_factura = id_factura
        FROM dbo.FACTURAS
        WHERE numero_factura = @numero_factura;
    END;

    UPDATE f
    SET
        total_neto = tot.total_neto,
        total_impuestos = tot.total_impuestos,
        total_descuentos = COALESCE(descu.total_descuentos, 0),
        total_recargos = COALESCE(recar.total_recargos, 0),
        total = tot.total_neto
              + tot.total_impuestos
              - COALESCE(descu.total_descuentos, 0)
              + COALESCE(recar.total_recargos, 0)
    FROM dbo.FACTURAS f
    INNER JOIN
    (
        SELECT
            id_factura,
            SUM(subtotal_neto) AS total_neto,
            SUM(importe_impuesto) AS total_impuestos
        FROM dbo.DETALLES_FACTURA
        WHERE id_factura = @id_factura
        GROUP BY id_factura
    ) tot
        ON f.id_factura = tot.id_factura
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

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;

SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    ef.estado AS estado_factura,
    f.total_neto,
    f.total_impuestos,
    f.total_descuentos,
    f.total_recargos,
    f.total
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
WHERE f.numero_factura = @numero_factura;

SELECT
    d.id_detalle_factura,
    ps.nombre AS producto_servicio,
    d.cantidad,
    d.precio_unitario_facturado,
    d.subtotal_neto,
    d.porcentaje_impuesto_facturado,
    d.importe_impuesto,
    d.subtotal_con_impuesto
FROM dbo.DETALLES_FACTURA d
INNER JOIN dbo.PRODUCTOS_SERVICIOS ps
    ON d.id_producto_servicio = ps.id_producto_servicio
INNER JOIN dbo.FACTURAS f
    ON d.id_factura = f.id_factura
WHERE f.numero_factura = @numero_factura
ORDER BY d.id_detalle_factura;
GO
