/* ============================================================
   01_UPDATE_CLIENTE_PRODUCTO_FACTURA_DEMO.SQL
   Proyecto Integrador BDD - PyME Genérica
   Motor: SQL Server
   Base de datos: BaseDeDatos_PyME
   Ubicación sugerida:
   05_CRUD\03_Update

   Objetivo:
   Demostrar operación UPDATE del CRUD.
   Actualiza datos del cliente, producto/servicio, detalle,
   totales de factura, comprobante de pago y auditoría.

   Requisito previo:
   Haber ejecutado previamente:
   - 05_CRUD\01_Create_Insert\01_insert_cliente_producto_factura_demo.sql
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @id_cliente INT;
    DECLARE @id_producto_servicio INT;
    DECLARE @id_factura INT;
    DECLARE @id_detalle_factura INT;
    DECLARE @id_estado_cliente_moroso INT;
    DECLARE @id_estado_factura_pagada INT;
    DECLARE @id_forma_pago_mercado_pago INT;
    DECLARE @id_usuario INT;
    DECLARE @porcentaje_impuesto DECIMAL(5,2);

    SELECT @id_cliente = id_cliente
    FROM dbo.CLIENTES
    WHERE numero_documento = '30999999999';

    SELECT @id_producto_servicio = id_producto_servicio
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Servicio de soporte técnico CRUD';

    SELECT @id_factura = id_factura
    FROM dbo.FACTURAS
    WHERE numero_factura = 'CRUD-0001';

    SELECT @id_detalle_factura = id_detalle_factura
    FROM dbo.DETALLES_FACTURA
    WHERE id_factura = @id_factura
      AND id_producto_servicio = @id_producto_servicio;

    SELECT @id_estado_cliente_moroso = id_estado_cliente
    FROM dbo.ESTADOS_CLIENTES
    WHERE estado = 'Moroso';

    SELECT @id_estado_factura_pagada = id_estado_factura
    FROM dbo.ESTADOS_FACTURA
    WHERE estado = 'Pagada';

    SELECT @id_forma_pago_mercado_pago = id_forma_pago
    FROM dbo.FORMAS_PAGO
    WHERE forma_pago = 'Mercado Pago'
      AND activo = 1;

    SELECT @id_usuario = id_usuario
    FROM dbo.USUARIOS
    WHERE nombre_usuario = 'vendedor1';

    SELECT @porcentaje_impuesto = i.porcentaje
    FROM dbo.PRODUCTOS_SERVICIOS ps
    INNER JOIN dbo.IMPUESTOS i
        ON i.id_impuesto = ps.id_impuesto
    WHERE ps.id_producto_servicio = @id_producto_servicio;

    IF @id_cliente IS NULL
        THROW 50101, 'No existe el cliente demo. Ejecutar primero el script INSERT.', 1;

    IF @id_producto_servicio IS NULL
        THROW 50102, 'No existe el producto/servicio demo. Ejecutar primero el script INSERT.', 1;

    IF @id_factura IS NULL
        THROW 50103, 'No existe la factura CRUD-0001. Ejecutar primero el script INSERT.', 1;

    IF @id_detalle_factura IS NULL
        THROW 50104, 'No existe el detalle de factura demo. Ejecutar primero el script INSERT.', 1;

    IF @id_estado_cliente_moroso IS NULL
        THROW 50105, 'No existe el estado de cliente Moroso. Ejecutar datos iniciales.', 1;

    IF @id_estado_factura_pagada IS NULL
        THROW 50106, 'No existe el estado de factura Pagada. Ejecutar datos iniciales.', 1;

    IF @id_forma_pago_mercado_pago IS NULL
        THROW 50107, 'No existe la forma de pago Mercado Pago activa. Ejecutar datos iniciales.', 1;

    IF @id_usuario IS NULL
        THROW 50108, 'No existe el usuario vendedor1. Ejecutar datos iniciales.', 1;

    /* ============================================================
       1. UPDATE de cliente
       ============================================================ */

    UPDATE dbo.CLIENTES
    SET
        id_estado_cliente = @id_estado_cliente_moroso,
        direccion = 'Av. Argentina 1234 - Piso 2',
        telefono = '2991112233',
        email = 'administracion@clientecruddemo.com'
    WHERE id_cliente = @id_cliente;

    /* ============================================================
       2. UPDATE de producto/servicio
       ============================================================ */

    UPDATE dbo.PRODUCTOS_SERVICIOS
    SET
        descripcion = 'Servicio actualizado para demostrar operaciones UPDATE del proyecto.',
        precio_unitario_actual = 18000.00,
        stock_actual = 45,
        activo = 1
    WHERE id_producto_servicio = @id_producto_servicio;

    /* ============================================================
       3. UPDATE de detalle de factura
       Recalcula cantidades, precio, impuesto y subtotal.
       ============================================================ */

    DECLARE @cantidad_actualizada DECIMAL(12,2) = 3.00;
    DECLARE @precio_actualizado DECIMAL(12,2) = 18000.00;
    DECLARE @subtotal_neto DECIMAL(12,2);
    DECLARE @importe_impuesto DECIMAL(12,2);
    DECLARE @subtotal_con_impuesto DECIMAL(12,2);

    SET @subtotal_neto = ROUND(@cantidad_actualizada * @precio_actualizado, 2);
    SET @importe_impuesto = ROUND(@subtotal_neto * @porcentaje_impuesto / 100, 2);
    SET @subtotal_con_impuesto = @subtotal_neto + @importe_impuesto;

    UPDATE dbo.DETALLES_FACTURA
    SET
        cantidad = @cantidad_actualizada,
        precio_unitario_facturado = @precio_actualizado,
        subtotal_neto = @subtotal_neto,
        porcentaje_impuesto_facturado = @porcentaje_impuesto,
        importe_impuesto = @importe_impuesto,
        subtotal_con_impuesto = @subtotal_con_impuesto
    WHERE id_detalle_factura = @id_detalle_factura;

    /* ============================================================
       4. UPDATE de totales de factura
       ============================================================ */

    UPDATE f
    SET
        id_estado_factura = @id_estado_factura_pagada,
        total_neto = x.total_neto,
        total_impuestos = x.total_impuestos,
        total_descuentos = 0.00,
        total_recargos = 0.00,
        total = x.total_neto + x.total_impuestos,
        observaciones = 'Factura actualizada desde script CRUD UPDATE.'
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
    ) x ON x.id_factura = f.id_factura;

    /* ============================================================
       5. UPDATE de comprobante de pago
       ============================================================ */

    DECLARE @total_actualizado DECIMAL(12,2);

    SELECT @total_actualizado = total
    FROM dbo.FACTURAS
    WHERE id_factura = @id_factura;

    UPDATE dbo.COMPROBANTES_PAGO
    SET
        id_forma_pago = @id_forma_pago_mercado_pago,
        fecha_pago = GETDATE(),
        monto = @total_actualizado,
        numero_referencia = 'MP-CRUD-0001-ACT',
        observaciones = 'Comprobante actualizado desde script CRUD UPDATE.'
    WHERE id_factura = @id_factura;

    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO dbo.COMPROBANTES_PAGO
        (
            id_factura,
            id_forma_pago,
            fecha_pago,
            monto,
            numero_referencia,
            observaciones
        )
        VALUES
        (
            @id_factura,
            @id_forma_pago_mercado_pago,
            GETDATE(),
            @total_actualizado,
            'MP-CRUD-0001-ACT',
            'Comprobante creado como respaldo desde script CRUD UPDATE.'
        );
    END

    /* ============================================================
       6. Auditoría de la actualización
       ============================================================ */

    INSERT INTO dbo.AUDITORIA_FACTURA
    (
        id_factura,
        id_usuario,
        accion,
        fecha,
        detalle
    )
    VALUES
    (
        @id_factura,
        @id_usuario,
        'UPDATE_FACTURA_CRUD',
        GETDATE(),
        'Factura, detalle, cliente, producto y comprobante actualizados mediante operación UPDATE.'
    );

    COMMIT TRANSACTION;

    PRINT 'Script UPDATE ejecutado correctamente.';

    SELECT
        f.id_factura,
        f.numero_factura,
        c.numero_documento,
        c.razon_social,
        ec.estado AS estado_cliente,
        ps.nombre AS producto_servicio,
        df.cantidad,
        df.precio_unitario_facturado,
        f.total_neto,
        f.total_impuestos,
        f.total,
        ef.estado AS estado_factura,
        fp.forma_pago,
        cp.monto AS monto_pagado
    FROM dbo.FACTURAS f
    INNER JOIN dbo.CLIENTES c
        ON c.id_cliente = f.id_cliente
    INNER JOIN dbo.ESTADOS_CLIENTES ec
        ON ec.id_estado_cliente = c.id_estado_cliente
    INNER JOIN dbo.ESTADOS_FACTURA ef
        ON ef.id_estado_factura = f.id_estado_factura
    INNER JOIN dbo.DETALLES_FACTURA df
        ON df.id_factura = f.id_factura
    INNER JOIN dbo.PRODUCTOS_SERVICIOS ps
        ON ps.id_producto_servicio = df.id_producto_servicio
    LEFT JOIN dbo.COMPROBANTES_PAGO cp
        ON cp.id_factura = f.id_factura
    LEFT JOIN dbo.FORMAS_PAGO fp
        ON fp.id_forma_pago = cp.id_forma_pago
    WHERE f.numero_factura = 'CRUD-0001';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @mensaje_error NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @severidad INT = ERROR_SEVERITY();
    DECLARE @estado INT = ERROR_STATE();

    RAISERROR(@mensaje_error, @severidad, @estado);
END CATCH;
GO
