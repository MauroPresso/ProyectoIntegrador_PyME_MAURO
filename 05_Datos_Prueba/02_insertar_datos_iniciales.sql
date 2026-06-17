/* ============================================================
   SCRIPT 02 - INSERTAR DATOS INICIALES / DATOS DE PRUEBA
   Proyecto Integrador BDD - PyME Genérica
   Motor: Microsoft SQL Server
   Base de datos: BaseDeDatos_PyME

   Ubicación sugerida:
   05_Datos_Prueba\02_insertar_datos_iniciales.sql

   Descripción:
   Inserta datos mínimos para probar el funcionamiento del modelo:
   roles, localidades, categorías, formas de pago, estados,
   usuarios, clientes, productos/servicios, facturas y detalles.

   El script evita duplicados usando IF NOT EXISTS.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* ========================================================
       1. ROLES
       ======================================================== */

    IF NOT EXISTS (SELECT 1 FROM dbo.ROLES WHERE nombre = 'Administrador')
    BEGIN
        INSERT INTO dbo.ROLES (nombre, descripcion, activo)
        VALUES ('Administrador', 'Usuario con acceso completo al sistema.', 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.ROLES WHERE nombre = 'Vendedor')
    BEGIN
        INSERT INTO dbo.ROLES (nombre, descripcion, activo)
        VALUES ('Vendedor', 'Usuario encargado de registrar ventas y facturas.', 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.ROLES WHERE nombre = 'Supervisor')
    BEGIN
        INSERT INTO dbo.ROLES (nombre, descripcion, activo)
        VALUES ('Supervisor', 'Usuario encargado de supervisar operaciones comerciales.', 1);
    END;


    /* ========================================================
       2. LOCALIDADES
       ======================================================== */

    IF NOT EXISTS (
        SELECT 1 FROM dbo.LOCALIDADES
        WHERE nombre = 'Neuquén' AND codigo_postal = '8300' AND provincia = 'Neuquén'
    )
    BEGIN
        INSERT INTO dbo.LOCALIDADES (nombre, codigo_postal, provincia)
        VALUES ('Neuquén', '8300', 'Neuquén');
    END;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.LOCALIDADES
        WHERE nombre = 'Plottier' AND codigo_postal = '8316' AND provincia = 'Neuquén'
    )
    BEGIN
        INSERT INTO dbo.LOCALIDADES (nombre, codigo_postal, provincia)
        VALUES ('Plottier', '8316', 'Neuquén');
    END;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.LOCALIDADES
        WHERE nombre = 'Cipolletti' AND codigo_postal = '8324' AND provincia = 'Río Negro'
    )
    BEGIN
        INSERT INTO dbo.LOCALIDADES (nombre, codigo_postal, provincia)
        VALUES ('Cipolletti', '8324', 'Río Negro');
    END;


    /* ========================================================
       3. CATEGORIAS_PRODUCTO
       ======================================================== */

    IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Productos generales')
    BEGIN
        INSERT INTO dbo.CATEGORIAS_PRODUCTO (nombre, descripcion, activo)
        VALUES ('Productos generales', 'Productos comercializados por la PyME.', 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Servicios profesionales')
    BEGIN
        INSERT INTO dbo.CATEGORIAS_PRODUCTO (nombre, descripcion, activo)
        VALUES ('Servicios profesionales', 'Servicios prestados por la PyME.', 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Insumos administrativos')
    BEGIN
        INSERT INTO dbo.CATEGORIAS_PRODUCTO (nombre, descripcion, activo)
        VALUES ('Insumos administrativos', 'Insumos de uso general para clientes.', 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Soporte técnico')
    BEGIN
        INSERT INTO dbo.CATEGORIAS_PRODUCTO (nombre, descripcion, activo)
        VALUES ('Soporte técnico', 'Servicios de asistencia técnica y mantenimiento.', 1);
    END;


    /* ========================================================
       4. FORMAS_PAGO
       ======================================================== */

    IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE nombre = 'Efectivo')
    BEGIN
        INSERT INTO dbo.FORMAS_PAGO (nombre, descripcion, activo)
        VALUES ('Efectivo', 'Pago realizado en efectivo.', 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE nombre = 'Transferencia bancaria')
    BEGIN
        INSERT INTO dbo.FORMAS_PAGO (nombre, descripcion, activo)
        VALUES ('Transferencia bancaria', 'Pago realizado mediante transferencia bancaria.', 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE nombre = 'Tarjeta de débito')
    BEGIN
        INSERT INTO dbo.FORMAS_PAGO (nombre, descripcion, activo)
        VALUES ('Tarjeta de débito', 'Pago realizado con tarjeta de débito.', 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE nombre = 'Tarjeta de crédito')
    BEGIN
        INSERT INTO dbo.FORMAS_PAGO (nombre, descripcion, activo)
        VALUES ('Tarjeta de crédito', 'Pago realizado con tarjeta de crédito.', 1);
    END;


    /* ========================================================
       5. ESTADOS_FACTURA
       ======================================================== */

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE nombre = 'Emitida')
    BEGIN
        INSERT INTO dbo.ESTADOS_FACTURA (nombre, descripcion)
        VALUES ('Emitida', 'Factura emitida correctamente.');
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE nombre = 'Pagada')
    BEGIN
        INSERT INTO dbo.ESTADOS_FACTURA (nombre, descripcion)
        VALUES ('Pagada', 'Factura abonada por el cliente.');
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE nombre = 'Pendiente')
    BEGIN
        INSERT INTO dbo.ESTADOS_FACTURA (nombre, descripcion)
        VALUES ('Pendiente', 'Factura pendiente de pago.');
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE nombre = 'Anulada')
    BEGIN
        INSERT INTO dbo.ESTADOS_FACTURA (nombre, descripcion)
        VALUES ('Anulada', 'Factura anulada.');
    END;


    /* ========================================================
       6. USUARIOS
       ======================================================== */

    DECLARE @id_rol_admin INT;
    DECLARE @id_rol_vendedor INT;

    SELECT @id_rol_admin = id_rol
    FROM dbo.ROLES
    WHERE nombre = 'Administrador';

    SELECT @id_rol_vendedor = id_rol
    FROM dbo.ROLES
    WHERE nombre = 'Vendedor';

    IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE nombre_usuario = 'admin')
    BEGIN
        INSERT INTO dbo.USUARIOS
        (
            id_rol,
            nombre,
            apellido,
            email,
            nombre_usuario,
            clave_hash,
            activo
        )
        VALUES
        (
            @id_rol_admin,
            'Administrador',
            'Sistema',
            'admin@pyme.com',
            'admin',
            'hash_demo_admin_123',
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE nombre_usuario = 'vendedor.demo')
    BEGIN
        INSERT INTO dbo.USUARIOS
        (
            id_rol,
            nombre,
            apellido,
            email,
            nombre_usuario,
            clave_hash,
            activo
        )
        VALUES
        (
            @id_rol_vendedor,
            'Vendedor',
            'Demo',
            'ventas@pyme.com',
            'vendedor.demo',
            'hash_demo_vendedor_123',
            1
        );
    END;


    /* ========================================================
       7. CLIENTES
       ======================================================== */

    DECLARE @id_localidad_neuquen INT;
    DECLARE @id_localidad_plottier INT;
    DECLARE @id_localidad_cipolletti INT;

    SELECT @id_localidad_neuquen = id_localidad
    FROM dbo.LOCALIDADES
    WHERE nombre = 'Neuquén' AND codigo_postal = '8300' AND provincia = 'Neuquén';

    SELECT @id_localidad_plottier = id_localidad
    FROM dbo.LOCALIDADES
    WHERE nombre = 'Plottier' AND codigo_postal = '8316' AND provincia = 'Neuquén';

    SELECT @id_localidad_cipolletti = id_localidad
    FROM dbo.LOCALIDADES
    WHERE nombre = 'Cipolletti' AND codigo_postal = '8324' AND provincia = 'Río Negro';

    IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE documento_cuit = '30-70000001-1')
    BEGIN
        INSERT INTO dbo.CLIENTES
        (
            id_localidad,
            nombre_razon_social,
            documento_cuit,
            direccion,
            telefono,
            email,
            activo
        )
        VALUES
        (
            @id_localidad_neuquen,
            'Cliente Demo S.A.',
            '30-70000001-1',
            'Av. Argentina 100',
            '2994000001',
            'contacto@clientedemo.com',
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE documento_cuit = '30-70000002-2')
    BEGIN
        INSERT INTO dbo.CLIENTES
        (
            id_localidad,
            nombre_razon_social,
            documento_cuit,
            direccion,
            telefono,
            email,
            activo
        )
        VALUES
        (
            @id_localidad_plottier,
            'Servicios del Sur S.R.L.',
            '30-70000002-2',
            'San Martín 250',
            '2994000002',
            'administracion@serviciosdelsur.com',
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE documento_cuit = '30-70000003-3')
    BEGIN
        INSERT INTO dbo.CLIENTES
        (
            id_localidad,
            nombre_razon_social,
            documento_cuit,
            direccion,
            telefono,
            email,
            activo
        )
        VALUES
        (
            @id_localidad_cipolletti,
            'Comercial Andina',
            '30-70000003-3',
            'Roca 450',
            '2994000003',
            'ventas@comercialandina.com',
            1
        );
    END;


    /* ========================================================
       8. PRODUCTOS_SERVICIOS
       ======================================================== */

    DECLARE @id_cat_productos INT;
    DECLARE @id_cat_servicios INT;
    DECLARE @id_cat_insumos INT;
    DECLARE @id_cat_soporte INT;

    SELECT @id_cat_productos = id_categoria
    FROM dbo.CATEGORIAS_PRODUCTO
    WHERE nombre = 'Productos generales';

    SELECT @id_cat_servicios = id_categoria
    FROM dbo.CATEGORIAS_PRODUCTO
    WHERE nombre = 'Servicios profesionales';

    SELECT @id_cat_insumos = id_categoria
    FROM dbo.CATEGORIAS_PRODUCTO
    WHERE nombre = 'Insumos administrativos';

    SELECT @id_cat_soporte = id_categoria
    FROM dbo.CATEGORIAS_PRODUCTO
    WHERE nombre = 'Soporte técnico';

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Producto estándar A')
    BEGIN
        INSERT INTO dbo.PRODUCTOS_SERVICIOS
        (
            id_categoria,
            nombre,
            descripcion,
            precio_unitario_actual,
            activo
        )
        VALUES
        (
            @id_cat_productos,
            'Producto estándar A',
            'Producto genérico de venta habitual.',
            15000.00,
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Producto estándar B')
    BEGIN
        INSERT INTO dbo.PRODUCTOS_SERVICIOS
        (
            id_categoria,
            nombre,
            descripcion,
            precio_unitario_actual,
            activo
        )
        VALUES
        (
            @id_cat_productos,
            'Producto estándar B',
            'Producto genérico complementario.',
            22500.00,
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Servicio de consultoría')
    BEGIN
        INSERT INTO dbo.PRODUCTOS_SERVICIOS
        (
            id_categoria,
            nombre,
            descripcion,
            precio_unitario_actual,
            activo
        )
        VALUES
        (
            @id_cat_servicios,
            'Servicio de consultoría',
            'Servicio profesional brindado al cliente.',
            35000.00,
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Hora soporte técnico')
    BEGIN
        INSERT INTO dbo.PRODUCTOS_SERVICIOS
        (
            id_categoria,
            nombre,
            descripcion,
            precio_unitario_actual,
            activo
        )
        VALUES
        (
            @id_cat_soporte,
            'Hora soporte técnico',
            'Servicio técnico facturado por hora.',
            12000.00,
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Pack insumos oficina')
    BEGIN
        INSERT INTO dbo.PRODUCTOS_SERVICIOS
        (
            id_categoria,
            nombre,
            descripcion,
            precio_unitario_actual,
            activo
        )
        VALUES
        (
            @id_cat_insumos,
            'Pack insumos oficina',
            'Conjunto básico de insumos administrativos.',
            8500.00,
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Mantenimiento mensual')
    BEGIN
        INSERT INTO dbo.PRODUCTOS_SERVICIOS
        (
            id_categoria,
            nombre,
            descripcion,
            precio_unitario_actual,
            activo
        )
        VALUES
        (
            @id_cat_soporte,
            'Mantenimiento mensual',
            'Servicio mensual de mantenimiento preventivo.',
            45000.00,
            1
        );
    END;


    /* ========================================================
       9. FACTURAS
       ======================================================== */

    DECLARE @id_cliente_demo INT;
    DECLARE @id_cliente_sur INT;
    DECLARE @id_cliente_andina INT;
    DECLARE @id_usuario_vendedor INT;
    DECLARE @id_forma_transferencia INT;
    DECLARE @id_forma_efectivo INT;
    DECLARE @id_forma_debito INT;
    DECLARE @id_estado_emitida INT;
    DECLARE @id_estado_pagada INT;
    DECLARE @id_estado_pendiente INT;

    SELECT @id_cliente_demo = id_cliente
    FROM dbo.CLIENTES
    WHERE documento_cuit = '30-70000001-1';

    SELECT @id_cliente_sur = id_cliente
    FROM dbo.CLIENTES
    WHERE documento_cuit = '30-70000002-2';

    SELECT @id_cliente_andina = id_cliente
    FROM dbo.CLIENTES
    WHERE documento_cuit = '30-70000003-3';

    SELECT @id_usuario_vendedor = id_usuario
    FROM dbo.USUARIOS
    WHERE nombre_usuario = 'vendedor.demo';

    SELECT @id_forma_transferencia = id_forma_pago
    FROM dbo.FORMAS_PAGO
    WHERE nombre = 'Transferencia bancaria';

    SELECT @id_forma_efectivo = id_forma_pago
    FROM dbo.FORMAS_PAGO
    WHERE nombre = 'Efectivo';

    SELECT @id_forma_debito = id_forma_pago
    FROM dbo.FORMAS_PAGO
    WHERE nombre = 'Tarjeta de débito';

    SELECT @id_estado_emitida = id_estado_factura
    FROM dbo.ESTADOS_FACTURA
    WHERE nombre = 'Emitida';

    SELECT @id_estado_pagada = id_estado_factura
    FROM dbo.ESTADOS_FACTURA
    WHERE nombre = 'Pagada';

    SELECT @id_estado_pendiente = id_estado_factura
    FROM dbo.ESTADOS_FACTURA
    WHERE nombre = 'Pendiente';

    IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura = 'F-0001-00000001')
    BEGIN
        INSERT INTO dbo.FACTURAS
        (
            id_cliente,
            id_usuario,
            id_forma_pago,
            id_estado_factura,
            numero_factura,
            fecha_emision,
            total,
            observaciones
        )
        VALUES
        (
            @id_cliente_demo,
            @id_usuario_vendedor,
            @id_forma_transferencia,
            @id_estado_pagada,
            'F-0001-00000001',
            '2026-06-06T10:00:00',
            0,
            'Factura de prueba pagada.'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura = 'F-0001-00000002')
    BEGIN
        INSERT INTO dbo.FACTURAS
        (
            id_cliente,
            id_usuario,
            id_forma_pago,
            id_estado_factura,
            numero_factura,
            fecha_emision,
            total,
            observaciones
        )
        VALUES
        (
            @id_cliente_sur,
            @id_usuario_vendedor,
            @id_forma_efectivo,
            @id_estado_emitida,
            'F-0001-00000002',
            '2026-06-06T11:30:00',
            0,
            'Factura de prueba emitida.'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura = 'F-0001-00000003')
    BEGIN
        INSERT INTO dbo.FACTURAS
        (
            id_cliente,
            id_usuario,
            id_forma_pago,
            id_estado_factura,
            numero_factura,
            fecha_emision,
            total,
            observaciones
        )
        VALUES
        (
            @id_cliente_andina,
            @id_usuario_vendedor,
            @id_forma_debito,
            @id_estado_pendiente,
            'F-0001-00000003',
            '2026-06-06T12:15:00',
            0,
            'Factura de prueba pendiente.'
        );
    END;


    /* ========================================================
       10. DETALLES_FACTURA
       Nota:
       No se inserta subtotal porque es columna calculada.
       subtotal = cantidad * precio_unitario
       ======================================================== */

    DECLARE @id_factura_1 INT;
    DECLARE @id_factura_2 INT;
    DECLARE @id_factura_3 INT;

    DECLARE @id_producto_a INT;
    DECLARE @id_servicio_consultoria INT;
    DECLARE @id_hora_soporte INT;
    DECLARE @id_pack_insumos INT;
    DECLARE @id_mantenimiento INT;

    SELECT @id_factura_1 = id_factura
    FROM dbo.FACTURAS
    WHERE numero_factura = 'F-0001-00000001';

    SELECT @id_factura_2 = id_factura
    FROM dbo.FACTURAS
    WHERE numero_factura = 'F-0001-00000002';

    SELECT @id_factura_3 = id_factura
    FROM dbo.FACTURAS
    WHERE numero_factura = 'F-0001-00000003';

    SELECT @id_producto_a = id_producto_servicio
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Producto estándar A';

    SELECT @id_servicio_consultoria = id_producto_servicio
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Servicio de consultoría';

    SELECT @id_hora_soporte = id_producto_servicio
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Hora soporte técnico';

    SELECT @id_pack_insumos = id_producto_servicio
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Pack insumos oficina';

    SELECT @id_mantenimiento = id_producto_servicio
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Mantenimiento mensual';

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.DETALLES_FACTURA
        WHERE id_factura = @id_factura_1
          AND id_producto_servicio = @id_producto_a
    )
    BEGIN
        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura,
            id_producto_servicio,
            cantidad,
            precio_unitario
        )
        VALUES
        (
            @id_factura_1,
            @id_producto_a,
            2,
            15000.00
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.DETALLES_FACTURA
        WHERE id_factura = @id_factura_1
          AND id_producto_servicio = @id_servicio_consultoria
    )
    BEGIN
        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura,
            id_producto_servicio,
            cantidad,
            precio_unitario
        )
        VALUES
        (
            @id_factura_1,
            @id_servicio_consultoria,
            1,
            35000.00
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.DETALLES_FACTURA
        WHERE id_factura = @id_factura_2
          AND id_producto_servicio = @id_hora_soporte
    )
    BEGIN
        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura,
            id_producto_servicio,
            cantidad,
            precio_unitario
        )
        VALUES
        (
            @id_factura_2,
            @id_hora_soporte,
            3,
            12000.00
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.DETALLES_FACTURA
        WHERE id_factura = @id_factura_2
          AND id_producto_servicio = @id_pack_insumos
    )
    BEGIN
        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura,
            id_producto_servicio,
            cantidad,
            precio_unitario
        )
        VALUES
        (
            @id_factura_2,
            @id_pack_insumos,
            2,
            8500.00
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.DETALLES_FACTURA
        WHERE id_factura = @id_factura_3
          AND id_producto_servicio = @id_mantenimiento
    )
    BEGIN
        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura,
            id_producto_servicio,
            cantidad,
            precio_unitario
        )
        VALUES
        (
            @id_factura_3,
            @id_mantenimiento,
            1,
            45000.00
        );
    END;


    /* ========================================================
       11. ACTUALIZAR TOTAL DE FACTURAS
       El total se calcula desde los subtotales de sus detalles.
       ======================================================== */

    UPDATE f
    SET total = ISNULL(t.total_calculado, 0)
    FROM dbo.FACTURAS f
    OUTER APPLY
    (
        SELECT SUM(df.subtotal) AS total_calculado
        FROM dbo.DETALLES_FACTURA df
        WHERE df.id_factura = f.id_factura
    ) t
    WHERE f.numero_factura IN
    (
        'F-0001-00000001',
        'F-0001-00000002',
        'F-0001-00000003'
    );

    COMMIT TRANSACTION;

    PRINT 'Datos iniciales insertados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    PRINT 'Error al insertar datos iniciales.';
    THROW;
END CATCH;
GO