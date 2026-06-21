/* ============================================================
   03_sp_facturas.sql
   Proyecto Integrador BDD - PyME Generica
   Bloque: 05_CRUD / 05_Stored_Procedures

   Procedimientos incluidos:
   - dbo.usp_Facturas_Crear_Cabecera
   - dbo.usp_Facturas_Recalcular_Totales
   - dbo.usp_Facturas_Agregar_Detalle
   - dbo.usp_Facturas_Registrar_Descuento
   - dbo.usp_Facturas_Registrar_Recargo
   - dbo.usp_Facturas_Registrar_Pago
   - dbo.usp_Facturas_Anular
   - dbo.usp_Facturas_Eliminar_Logico
   - dbo.usp_Facturas_Seleccionar
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

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Facturas_Crear_Cabecera
    @id_cliente INT,
    @id_usuario INT,
    @id_tipo_factura INT,
    @id_tipo_operacion_factura INT,
    @numero_factura VARCHAR(30),
    @fecha_emision DATETIME = NULL,
    @observaciones VARCHAR(250) = NULL,
    @id_factura_creada INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        DECLARE @id_estado_emitida INT;

        SELECT @id_estado_emitida = id_estado_factura
        FROM dbo.ESTADOS_FACTURA
        WHERE estado = 'Emitida';

        SET @numero_factura = NULLIF(LTRIM(RTRIM(@numero_factura)), '');

        IF @id_estado_emitida IS NULL
            THROW 63001, 'No existe el estado de factura Emitida.', 1;

        IF @numero_factura IS NULL
            THROW 63002, 'El numero_factura es obligatorio.', 1;

        IF EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura = @numero_factura)
            THROW 63003, 'Ya existe una factura con ese numero_factura.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE id_cliente = @id_cliente)
            THROW 63004, 'El cliente indicado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE id_usuario = @id_usuario)
            THROW 63005, 'El usuario indicado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_FACTURA WHERE id_tipo_factura = @id_tipo_factura)
            THROW 63006, 'El tipo de factura indicado no existe.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.TIPOS_OPERACION_FACTURA
            WHERE id_tipo_operacion_factura = @id_tipo_operacion_factura
        )
            THROW 63007, 'El tipo de operacion de factura indicado no existe.', 1;

        BEGIN TRANSACTION;

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
            @id_tipo_operacion_factura,
            @numero_factura,
            COALESCE(@fecha_emision, GETDATE()),
            0,
            0,
            0,
            0,
            0,
            @observaciones
        );

        SET @id_factura_creada = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.AUDITORIA_FACTURA
        (
            id_factura,
            id_usuario,
            accion,
            detalle
        )
        VALUES
        (
            @id_factura_creada,
            @id_usuario,
            'CREACION',
            'Creacion de cabecera de factura.'
        );

        COMMIT TRANSACTION;

        EXEC dbo.usp_Facturas_Seleccionar @id_factura = @id_factura_creada;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Facturas_Recalcular_Totales
    @id_factura INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE id_factura = @id_factura)
        THROW 63008, 'La factura indicada no existe.', 1;

    DECLARE
        @total_neto DECIMAL(12,2),
        @total_impuestos DECIMAL(12,2),
        @total_descuentos DECIMAL(12,2),
        @total_recargos DECIMAL(12,2),
        @total DECIMAL(12,2);

    SELECT
        @total_neto = COALESCE(SUM(subtotal_neto), 0),
        @total_impuestos = COALESCE(SUM(importe_impuesto), 0)
    FROM dbo.DETALLES_FACTURA
    WHERE id_factura = @id_factura;

    SELECT @total_descuentos = COALESCE(SUM(monto), 0)
    FROM dbo.DESCUENTOS_FACTURA
    WHERE id_factura = @id_factura;

    SELECT @total_recargos = COALESCE(SUM(monto), 0)
    FROM dbo.RECARGOS_FACTURA
    WHERE id_factura = @id_factura;

    SET @total = @total_neto + @total_impuestos - @total_descuentos + @total_recargos;

    IF @total < 0
        SET @total = 0;

    UPDATE dbo.FACTURAS
    SET
        total_neto = @total_neto,
        total_impuestos = @total_impuestos,
        total_descuentos = @total_descuentos,
        total_recargos = @total_recargos,
        total = @total
    WHERE id_factura = @id_factura;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Facturas_Agregar_Detalle
    @id_factura INT,
    @id_producto_servicio INT,
    @cantidad DECIMAL(12,2),
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        DECLARE
            @estado_factura VARCHAR(50),
            @producto_activo BIT,
            @stock_actual INT,
            @precio_unitario DECIMAL(12,2),
            @porcentaje_impuesto DECIMAL(5,2),
            @subtotal_neto DECIMAL(12,2),
            @importe_impuesto DECIMAL(12,2),
            @subtotal_con_impuesto DECIMAL(12,2),
            @cantidad_stock INT;

        IF @cantidad <= 0
            THROW 63009, 'La cantidad debe ser mayor a cero.', 1;

        IF @cantidad <> FLOOR(@cantidad)
            THROW 63010, 'Para este modelo, la cantidad debe ser entera porque stock_actual es INT.', 1;

        SET @cantidad_stock = CAST(@cantidad AS INT);

        SELECT @estado_factura = ef.estado
        FROM dbo.FACTURAS f
        INNER JOIN dbo.ESTADOS_FACTURA ef
            ON f.id_estado_factura = ef.id_estado_factura
        WHERE f.id_factura = @id_factura;

        IF @estado_factura IS NULL
            THROW 63011, 'La factura indicada no existe.', 1;

        IF @estado_factura = 'Anulada'
            THROW 63012, 'No se pueden agregar detalles a una factura anulada.', 1;

        IF @estado_factura = 'Pagada'
            THROW 63013, 'No se pueden agregar detalles a una factura pagada.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE id_usuario = @id_usuario)
            THROW 63014, 'El usuario indicado no existe.', 1;

        SELECT
            @producto_activo = ps.activo,
            @stock_actual = ps.stock_actual,
            @precio_unitario = ps.precio_unitario_actual,
            @porcentaje_impuesto = i.porcentaje
        FROM dbo.PRODUCTOS_SERVICIOS ps
        INNER JOIN dbo.IMPUESTOS i
            ON ps.id_impuesto = i.id_impuesto
        WHERE ps.id_producto_servicio = @id_producto_servicio;

        IF @precio_unitario IS NULL
            THROW 63015, 'El producto/servicio indicado no existe.', 1;

        IF @producto_activo = 0
            THROW 63016, 'El producto/servicio indicado no esta activo.', 1;

        IF @stock_actual < @cantidad_stock
            THROW 63017, 'Stock insuficiente para agregar el detalle.', 1;

        SET @subtotal_neto = @cantidad * @precio_unitario;
        SET @importe_impuesto = ROUND(@subtotal_neto * @porcentaje_impuesto / 100, 2);
        SET @subtotal_con_impuesto = @subtotal_neto + @importe_impuesto;

        BEGIN TRANSACTION;

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

        EXEC dbo.usp_Facturas_Recalcular_Totales @id_factura = @id_factura;

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
            'AGREGAR_DETALLE',
            'Se agrego un detalle a la factura.'
        );

        COMMIT TRANSACTION;

        EXEC dbo.usp_Facturas_Seleccionar @id_factura = @id_factura;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Facturas_Registrar_Descuento
    @id_factura INT,
    @descripcion VARCHAR(150),
    @monto DECIMAL(12,2),
    @porcentaje DECIMAL(5,2) = NULL,
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET @descripcion = NULLIF(LTRIM(RTRIM(@descripcion)), '');

        IF @descripcion IS NULL
            THROW 63018, 'La descripcion del descuento es obligatoria.', 1;

        IF @monto <= 0
            THROW 63019, 'El monto del descuento debe ser mayor a cero.', 1;

        IF @porcentaje IS NOT NULL AND @porcentaje < 0
            THROW 63020, 'El porcentaje del descuento no puede ser negativo.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE id_factura = @id_factura)
            THROW 63021, 'La factura indicada no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE id_usuario = @id_usuario)
            THROW 63022, 'El usuario indicado no existe.', 1;

        BEGIN TRANSACTION;

        INSERT INTO dbo.DESCUENTOS_FACTURA
        (
            id_factura,
            descripcion,
            porcentaje,
            monto
        )
        VALUES
        (
            @id_factura,
            @descripcion,
            @porcentaje,
            @monto
        );

        EXEC dbo.usp_Facturas_Recalcular_Totales @id_factura = @id_factura;

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
            'DESCUENTO',
            'Se registro un descuento en la factura.'
        );

        COMMIT TRANSACTION;

        EXEC dbo.usp_Facturas_Seleccionar @id_factura = @id_factura;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Facturas_Registrar_Recargo
    @id_factura INT,
    @descripcion VARCHAR(150),
    @monto DECIMAL(12,2),
    @porcentaje DECIMAL(5,2) = NULL,
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET @descripcion = NULLIF(LTRIM(RTRIM(@descripcion)), '');

        IF @descripcion IS NULL
            THROW 63023, 'La descripcion del recargo es obligatoria.', 1;

        IF @monto <= 0
            THROW 63024, 'El monto del recargo debe ser mayor a cero.', 1;

        IF @porcentaje IS NOT NULL AND @porcentaje < 0
            THROW 63025, 'El porcentaje del recargo no puede ser negativo.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE id_factura = @id_factura)
            THROW 63026, 'La factura indicada no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE id_usuario = @id_usuario)
            THROW 63027, 'El usuario indicado no existe.', 1;

        BEGIN TRANSACTION;

        INSERT INTO dbo.RECARGOS_FACTURA
        (
            id_factura,
            descripcion,
            porcentaje,
            monto
        )
        VALUES
        (
            @id_factura,
            @descripcion,
            @porcentaje,
            @monto
        );

        EXEC dbo.usp_Facturas_Recalcular_Totales @id_factura = @id_factura;

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
            'RECARGO',
            'Se registro un recargo en la factura.'
        );

        COMMIT TRANSACTION;

        EXEC dbo.usp_Facturas_Seleccionar @id_factura = @id_factura;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Facturas_Registrar_Pago
    @id_factura INT,
    @id_forma_pago INT,
    @monto DECIMAL(12,2),
    @numero_referencia VARCHAR(100) = NULL,
    @observaciones VARCHAR(150) = NULL,
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        DECLARE
            @total DECIMAL(12,2),
            @estado_actual VARCHAR(50),
            @id_estado_pagada INT;

        IF @monto <= 0
            THROW 63028, 'El monto del pago debe ser mayor a cero.', 1;

        SELECT
            @total = f.total,
            @estado_actual = ef.estado
        FROM dbo.FACTURAS f
        INNER JOIN dbo.ESTADOS_FACTURA ef
            ON f.id_estado_factura = ef.id_estado_factura
        WHERE f.id_factura = @id_factura;

        IF @total IS NULL
            THROW 63029, 'La factura indicada no existe.', 1;

        IF @estado_actual = 'Anulada'
            THROW 63030, 'No se puede pagar una factura anulada.', 1;

        IF @estado_actual = 'Pagada'
            THROW 63031, 'La factura ya se encuentra pagada.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE id_forma_pago = @id_forma_pago AND activo = 1)
            THROW 63032, 'La forma de pago indicada no existe o no esta activa.', 1;

        IF EXISTS (SELECT 1 FROM dbo.COMPROBANTES_PAGO WHERE id_factura = @id_factura)
            THROW 63033, 'La factura ya tiene un comprobante de pago asociado.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE id_usuario = @id_usuario)
            THROW 63034, 'El usuario indicado no existe.', 1;

        SELECT @id_estado_pagada = id_estado_factura
        FROM dbo.ESTADOS_FACTURA
        WHERE estado = 'Pagada';

        IF @id_estado_pagada IS NULL
            THROW 63035, 'No existe el estado de factura Pagada.', 1;

        EXEC dbo.usp_Facturas_Recalcular_Totales @id_factura = @id_factura;

        SELECT @total = total
        FROM dbo.FACTURAS
        WHERE id_factura = @id_factura;

        IF ABS(@monto - @total) > 0.01
            THROW 63036, 'El monto del pago debe coincidir con el total de la factura.', 1;

        BEGIN TRANSACTION;

        INSERT INTO dbo.COMPROBANTES_PAGO
        (
            id_factura,
            id_forma_pago,
            monto,
            numero_referencia,
            observaciones
        )
        VALUES
        (
            @id_factura,
            @id_forma_pago,
            @monto,
            @numero_referencia,
            @observaciones
        );

        UPDATE dbo.FACTURAS
        SET id_estado_factura = @id_estado_pagada
        WHERE id_factura = @id_factura;

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
            'PAGO',
            'Se registro el pago de la factura.'
        );

        COMMIT TRANSACTION;

        EXEC dbo.usp_Facturas_Seleccionar @id_factura = @id_factura;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Facturas_Anular
    @id_factura INT,
    @id_usuario INT,
    @motivo VARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        DECLARE
            @estado_actual VARCHAR(50),
            @id_estado_anulada INT;

        SELECT @estado_actual = ef.estado
        FROM dbo.FACTURAS f
        INNER JOIN dbo.ESTADOS_FACTURA ef
            ON f.id_estado_factura = ef.id_estado_factura
        WHERE f.id_factura = @id_factura;

        IF @estado_actual IS NULL
            THROW 63037, 'La factura indicada no existe.', 1;

        IF @estado_actual = 'Anulada'
            THROW 63038, 'La factura ya se encuentra anulada.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE id_usuario = @id_usuario)
            THROW 63039, 'El usuario indicado no existe.', 1;

        SELECT @id_estado_anulada = id_estado_factura
        FROM dbo.ESTADOS_FACTURA
        WHERE estado = 'Anulada';

        IF @id_estado_anulada IS NULL
            THROW 63040, 'No existe el estado de factura Anulada.', 1;

        BEGIN TRANSACTION;

        UPDATE ps
        SET ps.stock_actual = ps.stock_actual + CAST(d.cantidad AS INT)
        FROM dbo.PRODUCTOS_SERVICIOS ps
        INNER JOIN dbo.DETALLES_FACTURA d
            ON ps.id_producto_servicio = d.id_producto_servicio
        WHERE d.id_factura = @id_factura;

        UPDATE dbo.FACTURAS
        SET id_estado_factura = @id_estado_anulada
        WHERE id_factura = @id_factura;

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
            'ANULACION',
            COALESCE(@motivo, 'Factura anulada.')
        );

        COMMIT TRANSACTION;

        EXEC dbo.usp_Facturas_Seleccionar @id_factura = @id_factura;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Facturas_Eliminar_Logico
    @id_factura INT,
    @id_usuario INT,
    @motivo VARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_Facturas_Anular
        @id_factura = @id_factura,
        @id_usuario = @id_usuario,
        @motivo = @motivo;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Facturas_Seleccionar
    @id_factura INT = NULL,
    @numero_factura VARCHAR(30) = NULL,
    @id_cliente INT = NULL,
    @estado VARCHAR(50) = NULL,
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        f.id_factura,
        f.numero_factura,
        f.fecha_emision,
        f.total_neto,
        f.total_impuestos,
        f.total_descuentos,
        f.total_recargos,
        f.total,
        f.observaciones,
        ef.estado AS estado_factura,
        tf.tipo AS tipo_factura,
        tof.operacion AS tipo_operacion,
        c.id_cliente,
        CASE
            WHEN c.tipo_persona = 'F'
                THEN c.nombre + ' ' + c.apellido
            ELSE c.razon_social
        END AS cliente,
        c.numero_documento,
        u.id_usuario,
        u.nombre_usuario
    FROM dbo.FACTURAS f
    INNER JOIN dbo.ESTADOS_FACTURA ef
        ON f.id_estado_factura = ef.id_estado_factura
    INNER JOIN dbo.TIPOS_FACTURA tf
        ON f.id_tipo_factura = tf.id_tipo_factura
    INNER JOIN dbo.TIPOS_OPERACION_FACTURA tof
        ON f.id_tipo_operacion_factura = tof.id_tipo_operacion_factura
    INNER JOIN dbo.CLIENTES c
        ON f.id_cliente = c.id_cliente
    INNER JOIN dbo.USUARIOS u
        ON f.id_usuario = u.id_usuario
    WHERE
        (@id_factura IS NULL OR f.id_factura = @id_factura)
        AND (@numero_factura IS NULL OR f.numero_factura = @numero_factura)
        AND (@id_cliente IS NULL OR f.id_cliente = @id_cliente)
        AND (@estado IS NULL OR ef.estado = @estado)
        AND (@fecha_desde IS NULL OR CONVERT(DATE, f.fecha_emision) >= @fecha_desde)
        AND (@fecha_hasta IS NULL OR CONVERT(DATE, f.fecha_emision) <= @fecha_hasta)
    ORDER BY f.fecha_emision DESC, f.id_factura DESC;

    IF @id_factura IS NOT NULL
    BEGIN
        SELECT
            d.id_detalle_factura,
            d.id_factura,
            d.id_producto_servicio,
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
        WHERE d.id_factura = @id_factura
        ORDER BY d.id_detalle_factura;
    END;
END;
GO
