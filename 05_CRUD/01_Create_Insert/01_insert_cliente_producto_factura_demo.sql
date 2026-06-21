/* ============================================================
   01_INSERT_CLIENTE_PRODUCTO_FACTURA_DEMO.SQL
   Proyecto Integrador BDD - PyME Genérica
   Motor: SQL Server
   Base de datos: BaseDeDatos_PyME
   Ubicación sugerida:
   05_CRUD\01_Create_Insert

   Objetivo:
   Demostrar operación CREATE del CRUD mediante INSERT.
   Inserta un cliente, un producto/servicio, una factura,
   un detalle de factura, un comprobante de pago y un registro
   de auditoría.

   Requisito previo:
   Haber ejecutado previamente:
   - creación de base de datos
   - creación de tablas
   - inserts de datos iniciales / datos de prueba
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* ============================================================
       1. Búsqueda de claves foráneas necesarias
       ============================================================ */

    DECLARE @id_localidad INT;
    DECLARE @id_tipo_cliente INT;
    DECLARE @id_tipo_documento INT;
    DECLARE @id_estado_cliente INT;
    DECLARE @id_categoria INT;
    DECLARE @id_impuesto INT;
    DECLARE @porcentaje_impuesto DECIMAL(5,2);
    DECLARE @id_usuario INT;
    DECLARE @id_estado_factura INT;
    DECLARE @id_tipo_factura INT;
    DECLARE @id_tipo_operacion_factura INT;
    DECLARE @id_forma_pago INT;

    SELECT @id_localidad = id_localidad
    FROM dbo.LOCALIDADES
    WHERE nombre = 'Neuquén'
      AND codigo_postal = '8300';

    SELECT @id_tipo_cliente = id_tipo_cliente
    FROM dbo.TIPOS_CLIENTE
    WHERE tipo = 'Responsable Inscripto';

    SELECT @id_tipo_documento = id_tipo_documento
    FROM dbo.TIPOS_DOCUMENTO
    WHERE tipo = 'CUIT';

    SELECT @id_estado_cliente = id_estado_cliente
    FROM dbo.ESTADOS_CLIENTES
    WHERE estado = 'Activo';

    SELECT @id_categoria = id_categoria
    FROM dbo.CATEGORIAS_PRODUCTO
    WHERE nombre = 'Servicios';

    SELECT
        @id_impuesto = id_impuesto,
        @porcentaje_impuesto = porcentaje
    FROM dbo.IMPUESTOS
    WHERE impuesto = 'IVA 21%';

    SELECT @id_usuario = id_usuario
    FROM dbo.USUARIOS
    WHERE nombre_usuario = 'vendedor1';

    SELECT @id_estado_factura = id_estado_factura
    FROM dbo.ESTADOS_FACTURA
    WHERE estado = 'Pagada';

    SELECT @id_tipo_factura = id_tipo_factura
    FROM dbo.TIPOS_FACTURA
    WHERE tipo = 'Factura A';

    SELECT @id_tipo_operacion_factura = id_tipo_operacion_factura
    FROM dbo.TIPOS_OPERACION_FACTURA
    WHERE operacion = 'Venta';

    SELECT @id_forma_pago = id_forma_pago
    FROM dbo.FORMAS_PAGO
    WHERE forma_pago = 'Transferencia'
      AND activo = 1;

    IF @id_localidad IS NULL
        THROW 50001, 'Falta la localidad Neuquén 8300. Ejecutar datos iniciales.', 1;

    IF @id_tipo_cliente IS NULL
        THROW 50002, 'Falta el tipo de cliente Responsable Inscripto. Ejecutar datos iniciales.', 1;

    IF @id_tipo_documento IS NULL
        THROW 50003, 'Falta el tipo de documento CUIT. Ejecutar datos iniciales.', 1;

    IF @id_estado_cliente IS NULL
        THROW 50004, 'Falta el estado de cliente Activo. Ejecutar datos iniciales.', 1;

    IF @id_categoria IS NULL
        THROW 50005, 'Falta la categoría Servicios. Ejecutar datos iniciales.', 1;

    IF @id_impuesto IS NULL
        THROW 50006, 'Falta el impuesto IVA 21%. Ejecutar datos iniciales.', 1;

    IF @id_usuario IS NULL
        THROW 50007, 'Falta el usuario vendedor1. Ejecutar datos iniciales.', 1;

    IF @id_estado_factura IS NULL
        THROW 50008, 'Falta el estado de factura Pagada. Ejecutar datos iniciales.', 1;

    IF @id_tipo_factura IS NULL
        THROW 50009, 'Falta el tipo de factura Factura A. Ejecutar datos iniciales.', 1;

    IF @id_tipo_operacion_factura IS NULL
        THROW 50010, 'Falta el tipo de operación Venta. Ejecutar datos iniciales.', 1;

    IF @id_forma_pago IS NULL
        THROW 50011, 'Falta la forma de pago Transferencia activa. Ejecutar datos iniciales.', 1;

    /* ============================================================
       2. CREATE / INSERT de cliente de demostración
       ============================================================ */

    DECLARE @id_cliente INT;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.CLIENTES
        WHERE numero_documento = '30999999999'
    )
    BEGIN
        INSERT INTO dbo.CLIENTES
        (
            id_localidad,
            id_tipo_cliente,
            id_tipo_documento,
            id_estado_cliente,
            tipo_persona,
            numero_documento,
            nombre,
            apellido,
            razon_social,
            direccion,
            telefono,
            email
        )
        VALUES
        (
            @id_localidad,
            @id_tipo_cliente,
            @id_tipo_documento,
            @id_estado_cliente,
            'J',
            '30999999999',
            NULL,
            NULL,
            'Cliente CRUD Demo SRL',
            'Av. Argentina 1234',
            '2990000000',
            'contacto@clientecruddemo.com'
        );

        SET @id_cliente = CONVERT(INT, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        SELECT @id_cliente = id_cliente
        FROM dbo.CLIENTES
        WHERE numero_documento = '30999999999';
    END

    /* ============================================================
       3. CREATE / INSERT de producto o servicio de demostración
       ============================================================ */

    DECLARE @id_producto_servicio INT;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.PRODUCTOS_SERVICIOS
        WHERE nombre = 'Servicio de soporte técnico CRUD'
    )
    BEGIN
        INSERT INTO dbo.PRODUCTOS_SERVICIOS
        (
            id_categoria,
            id_impuesto,
            nombre,
            descripcion,
            precio_unitario_actual,
            stock_actual,
            activo
        )
        VALUES
        (
            @id_categoria,
            @id_impuesto,
            'Servicio de soporte técnico CRUD',
            'Servicio creado para demostrar operaciones CRUD del proyecto.',
            15000.00,
            50,
            1
        );

        SET @id_producto_servicio = CONVERT(INT, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        SELECT @id_producto_servicio = id_producto_servicio
        FROM dbo.PRODUCTOS_SERVICIOS
        WHERE nombre = 'Servicio de soporte técnico CRUD';
    END

    /* ============================================================
       4. CREATE / INSERT de factura de demostración
       ============================================================ */

    DECLARE @id_factura INT;
    DECLARE @numero_factura VARCHAR(30) = 'CRUD-0001';

    IF NOT EXISTS (
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
            @id_estado_factura,
            @id_tipo_factura,
            @id_tipo_operacion_factura,
            @numero_factura,
            GETDATE(),
            0.00,
            0.00,
            0.00,
            0.00,
            0.00,
            'Factura creada desde script CRUD INSERT.'
        );

        SET @id_factura = CONVERT(INT, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        SELECT @id_factura = id_factura
        FROM dbo.FACTURAS
        WHERE numero_factura = @numero_factura;
    END

    /* ============================================================
       5. CREATE / INSERT de detalle de factura
       ============================================================ */

    DECLARE @cantidad DECIMAL(12,2) = 2.00;
    DECLARE @precio_unitario DECIMAL(12,2);
    DECLARE @subtotal_neto DECIMAL(12,2);
    DECLARE @importe_impuesto DECIMAL(12,2);
    DECLARE @subtotal_con_impuesto DECIMAL(12,2);

    SELECT @precio_unitario = precio_unitario_actual
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE id_producto_servicio = @id_producto_servicio;

    SET @subtotal_neto = ROUND(@cantidad * @precio_unitario, 2);
    SET @importe_impuesto = ROUND(@subtotal_neto * @porcentaje_impuesto / 100, 2);
    SET @subtotal_con_impuesto = @subtotal_neto + @importe_impuesto;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.DETALLES_FACTURA
        WHERE id_factura = @id_factura
          AND id_producto_servicio = @id_producto_servicio
    )
    BEGIN
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
    END

    /* ============================================================
       6. Actualización de totales de la factura creada
       ============================================================ */

    UPDATE f
    SET
        total_neto = x.total_neto,
        total_impuestos = x.total_impuestos,
        total_descuentos = 0.00,
        total_recargos = 0.00,
        total = x.total_neto + x.total_impuestos
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
       7. CREATE / INSERT de comprobante de pago
       ============================================================ */

    DECLARE @total_factura DECIMAL(12,2);

    SELECT @total_factura = total
    FROM dbo.FACTURAS
    WHERE id_factura = @id_factura;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.COMPROBANTES_PAGO
        WHERE id_factura = @id_factura
    )
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
            @id_forma_pago,
            GETDATE(),
            @total_factura,
            'TRF-CRUD-0001',
            'Comprobante creado desde script CRUD INSERT.'
        );
    END

    /* ============================================================
       8. Registro de auditoría de la operación
       ============================================================ */

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AUDITORIA_FACTURA
        WHERE id_factura = @id_factura
          AND accion = 'ALTA_FACTURA_CRUD'
    )
    BEGIN
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
            'ALTA_FACTURA_CRUD',
            GETDATE(),
            'Factura de demostración creada mediante operación INSERT.'
        );
    END

    COMMIT TRANSACTION;

    PRINT 'Script INSERT ejecutado correctamente.';

    SELECT
        f.id_factura,
        f.numero_factura,
        c.numero_documento,
        c.razon_social,
        f.total_neto,
        f.total_impuestos,
        f.total,
        ef.estado AS estado_factura
    FROM dbo.FACTURAS f
    INNER JOIN dbo.CLIENTES c
        ON c.id_cliente = f.id_cliente
    INNER JOIN dbo.ESTADOS_FACTURA ef
        ON ef.id_estado_factura = f.id_estado_factura
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
