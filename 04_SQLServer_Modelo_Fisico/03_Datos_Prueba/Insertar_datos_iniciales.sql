/* ============================================================
   INSERTAR_DATOS_INICIALES.SQL
   Proyecto Integrador BDD - PyME Generica
   Motor: Microsoft SQL Server
   Base de datos: BaseDeDatos_PyME
   Ubicacion: 04_SQLServer_Modelo_Fisico\03_Datos_Prueba

   Script corregido para coincidir con:
   04_SQLServer_Modelo_Fisico\01_Creacion_de_tablas\Crear_tablas.sql
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* 1. PROVINCIAS */
    IF NOT EXISTS (SELECT 1 FROM dbo.PROVINCIAS WHERE nombre = 'Neuquen')
        INSERT INTO dbo.PROVINCIAS (nombre) VALUES ('Neuquen');

    IF NOT EXISTS (SELECT 1 FROM dbo.PROVINCIAS WHERE nombre = 'Rio Negro')
        INSERT INTO dbo.PROVINCIAS (nombre) VALUES ('Rio Negro');

    IF NOT EXISTS (SELECT 1 FROM dbo.PROVINCIAS WHERE nombre = 'Buenos Aires')
        INSERT INTO dbo.PROVINCIAS (nombre) VALUES ('Buenos Aires');

    DECLARE @id_provincia_neuquen INT,
            @id_provincia_rio_negro INT,
            @id_provincia_buenos_aires INT;

    SELECT @id_provincia_neuquen = id_provincia
    FROM dbo.PROVINCIAS
    WHERE nombre = 'Neuquen';

    SELECT @id_provincia_rio_negro = id_provincia
    FROM dbo.PROVINCIAS
    WHERE nombre = 'Rio Negro';

    SELECT @id_provincia_buenos_aires = id_provincia
    FROM dbo.PROVINCIAS
    WHERE nombre = 'Buenos Aires';

    /* 2. LOCALIDADES */
    IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre = 'Neuquen' AND codigo_postal = '8300')
        INSERT INTO dbo.LOCALIDADES (id_provincia, nombre, codigo_postal)
        VALUES (@id_provincia_neuquen, 'Neuquen', '8300');

    IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre = 'Plottier' AND codigo_postal = '8316')
        INSERT INTO dbo.LOCALIDADES (id_provincia, nombre, codigo_postal)
        VALUES (@id_provincia_neuquen, 'Plottier', '8316');

    IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre = 'Cipolletti' AND codigo_postal = '8324')
        INSERT INTO dbo.LOCALIDADES (id_provincia, nombre, codigo_postal)
        VALUES (@id_provincia_rio_negro, 'Cipolletti', '8324');

    IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre = 'Bahia Blanca' AND codigo_postal = '8000')
        INSERT INTO dbo.LOCALIDADES (id_provincia, nombre, codigo_postal)
        VALUES (@id_provincia_buenos_aires, 'Bahia Blanca', '8000');

    /* 3. TIPOS_CLIENTE */
    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE tipo = 'Responsable Inscripto')
        INSERT INTO dbo.TIPOS_CLIENTE (tipo, descripcion)
        VALUES ('Responsable Inscripto', 'Cliente registrado como responsable inscripto.');

    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE tipo = 'Monotributista')
        INSERT INTO dbo.TIPOS_CLIENTE (tipo, descripcion)
        VALUES ('Monotributista', 'Cliente registrado como monotributista.');

    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE tipo = 'Consumidor Final')
        INSERT INTO dbo.TIPOS_CLIENTE (tipo, descripcion)
        VALUES ('Consumidor Final', 'Cliente consumidor final.');

    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE tipo = 'Exento IVA')
        INSERT INTO dbo.TIPOS_CLIENTE (tipo, descripcion)
        VALUES ('Exento IVA', 'Cliente exento de IVA.');

    /* 4. TIPOS_DOCUMENTO */
    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_DOCUMENTO WHERE tipo = 'CUIT')
        INSERT INTO dbo.TIPOS_DOCUMENTO (tipo, descripcion)
        VALUES ('CUIT', 'Clave Unica de Identificacion Tributaria.');

    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_DOCUMENTO WHERE tipo = 'CUIL')
        INSERT INTO dbo.TIPOS_DOCUMENTO (tipo, descripcion)
        VALUES ('CUIL', 'Codigo Unico de Identificacion Laboral.');

    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_DOCUMENTO WHERE tipo = 'DNI')
        INSERT INTO dbo.TIPOS_DOCUMENTO (tipo, descripcion)
        VALUES ('DNI', 'Documento Nacional de Identidad.');

    /* 5. ROLES */
    IF NOT EXISTS (SELECT 1 FROM dbo.ROLES WHERE rol = 'Administrador')
        INSERT INTO dbo.ROLES (rol, descripcion)
        VALUES ('Administrador', 'Usuario con acceso completo al sistema.');

    IF NOT EXISTS (SELECT 1 FROM dbo.ROLES WHERE rol = 'Vendedor')
        INSERT INTO dbo.ROLES (rol, descripcion)
        VALUES ('Vendedor', 'Usuario encargado de registrar ventas y facturas.');

    IF NOT EXISTS (SELECT 1 FROM dbo.ROLES WHERE rol = 'Supervisor')
        INSERT INTO dbo.ROLES (rol, descripcion)
        VALUES ('Supervisor', 'Usuario encargado de revisar operaciones comerciales.');

    /* 6. ESTADOS_USUARIOS */
    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_USUARIOS WHERE estado = 'Activo')
        INSERT INTO dbo.ESTADOS_USUARIOS (estado, descripcion)
        VALUES ('Activo', 'Usuario habilitado para operar el sistema.');

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_USUARIOS WHERE estado = 'Inactivo')
        INSERT INTO dbo.ESTADOS_USUARIOS (estado, descripcion)
        VALUES ('Inactivo', 'Usuario no habilitado para operar el sistema.');

    /* 7. ESTADOS_CLIENTES */
    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_CLIENTES WHERE estado = 'Activo')
        INSERT INTO dbo.ESTADOS_CLIENTES (estado, descripcion)
        VALUES ('Activo', 'Cliente habilitado para operar.');

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_CLIENTES WHERE estado = 'Inactivo')
        INSERT INTO dbo.ESTADOS_CLIENTES (estado, descripcion)
        VALUES ('Inactivo', 'Cliente dado de baja o deshabilitado.');

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_CLIENTES WHERE estado = 'Suspendido')
        INSERT INTO dbo.ESTADOS_CLIENTES (estado, descripcion)
        VALUES ('Suspendido', 'Cliente temporalmente suspendido.');

    /* 8. FORMAS_PAGO */
    IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE forma_pago = 'Efectivo')
        INSERT INTO dbo.FORMAS_PAGO (forma_pago, descripcion, activo)
        VALUES ('Efectivo', 'Pago realizado en efectivo.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE forma_pago = 'Transferencia bancaria')
        INSERT INTO dbo.FORMAS_PAGO (forma_pago, descripcion, activo)
        VALUES ('Transferencia bancaria', 'Pago realizado mediante transferencia bancaria.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE forma_pago = 'Tarjeta de debito')
        INSERT INTO dbo.FORMAS_PAGO (forma_pago, descripcion, activo)
        VALUES ('Tarjeta de debito', 'Pago realizado con tarjeta de debito.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE forma_pago = 'Tarjeta de credito')
        INSERT INTO dbo.FORMAS_PAGO (forma_pago, descripcion, activo)
        VALUES ('Tarjeta de credito', 'Pago realizado con tarjeta de credito.', 1);

    /* 9. ESTADOS_FACTURA */
    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE estado = 'Emitida')
        INSERT INTO dbo.ESTADOS_FACTURA (estado, descripcion)
        VALUES ('Emitida', 'Factura emitida correctamente.');

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE estado = 'Pagada')
        INSERT INTO dbo.ESTADOS_FACTURA (estado, descripcion)
        VALUES ('Pagada', 'Factura abonada por el cliente.');

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE estado = 'Pendiente')
        INSERT INTO dbo.ESTADOS_FACTURA (estado, descripcion)
        VALUES ('Pendiente', 'Factura pendiente de pago.');

    IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE estado = 'Anulada')
        INSERT INTO dbo.ESTADOS_FACTURA (estado, descripcion)
        VALUES ('Anulada', 'Factura anulada.');

    /* 10. TIPOS_FACTURA */
    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_FACTURA WHERE tipo = 'A')
        INSERT INTO dbo.TIPOS_FACTURA (tipo, descripcion)
        VALUES ('A', 'Factura A.');

    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_FACTURA WHERE tipo = 'B')
        INSERT INTO dbo.TIPOS_FACTURA (tipo, descripcion)
        VALUES ('B', 'Factura B.');

    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_FACTURA WHERE tipo = 'C')
        INSERT INTO dbo.TIPOS_FACTURA (tipo, descripcion)
        VALUES ('C', 'Factura C.');

    /* 11. TIPOS_OPERACION_FACTURA */
    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_OPERACION_FACTURA WHERE operacion = 'Venta')
        INSERT INTO dbo.TIPOS_OPERACION_FACTURA (operacion, descripcion)
        VALUES ('Venta', 'Operacion de venta de productos o servicios.');

    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_OPERACION_FACTURA WHERE operacion = 'Nota de credito')
        INSERT INTO dbo.TIPOS_OPERACION_FACTURA (operacion, descripcion)
        VALUES ('Nota de credito', 'Operacion utilizada para anular o corregir una venta.');

    IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_OPERACION_FACTURA WHERE operacion = 'Nota de debito')
        INSERT INTO dbo.TIPOS_OPERACION_FACTURA (operacion, descripcion)
        VALUES ('Nota de debito', 'Operacion utilizada para registrar un ajuste a favor de la PyME.');

    /* 12. CATEGORIAS_PRODUCTO */
    IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Productos generales')
        INSERT INTO dbo.CATEGORIAS_PRODUCTO (nombre, descripcion, activo)
        VALUES ('Productos generales', 'Productos comercializados por la PyME.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Servicios profesionales')
        INSERT INTO dbo.CATEGORIAS_PRODUCTO (nombre, descripcion, activo)
        VALUES ('Servicios profesionales', 'Servicios prestados por la PyME.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Insumos administrativos')
        INSERT INTO dbo.CATEGORIAS_PRODUCTO (nombre, descripcion, activo)
        VALUES ('Insumos administrativos', 'Insumos de uso general para clientes.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Soporte tecnico')
        INSERT INTO dbo.CATEGORIAS_PRODUCTO (nombre, descripcion, activo)
        VALUES ('Soporte tecnico', 'Servicios de asistencia tecnica y mantenimiento.', 1);

    /* 13. IMPUESTOS */
    IF NOT EXISTS (SELECT 1 FROM dbo.IMPUESTOS WHERE impuesto = 'IVA 21')
        INSERT INTO dbo.IMPUESTOS (impuesto, porcentaje, descripcion, activo)
        VALUES ('IVA 21', 21.00, 'Impuesto al valor agregado al 21%.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.IMPUESTOS WHERE impuesto = 'IVA 10.5')
        INSERT INTO dbo.IMPUESTOS (impuesto, porcentaje, descripcion, activo)
        VALUES ('IVA 10.5', 10.50, 'Impuesto al valor agregado al 10.5%.', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.IMPUESTOS WHERE impuesto = 'Exento')
        INSERT INTO dbo.IMPUESTOS (impuesto, porcentaje, descripcion, activo)
        VALUES ('Exento', 0.00, 'Operacion sin impuesto aplicado.', 1);

    /* 14. USUARIOS */
    DECLARE @id_rol_admin INT,
            @id_rol_vendedor INT,
            @id_rol_supervisor INT,
            @id_estado_usuario_activo INT;

    SELECT @id_rol_admin = id_rol FROM dbo.ROLES WHERE rol = 'Administrador';
    SELECT @id_rol_vendedor = id_rol FROM dbo.ROLES WHERE rol = 'Vendedor';
    SELECT @id_rol_supervisor = id_rol FROM dbo.ROLES WHERE rol = 'Supervisor';
    SELECT @id_estado_usuario_activo = id_estado_usuario FROM dbo.ESTADOS_USUARIOS WHERE estado = 'Activo';

    IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE nombre_usuario = 'admin')
        INSERT INTO dbo.USUARIOS (id_rol, id_estado_usuario, nombre_usuario, clave_hash, nombre_completo, email)
        VALUES (@id_rol_admin, @id_estado_usuario_activo, 'admin', 'hash_demo_admin_123', 'Administrador Sistema', 'admin@pyme.com');

    IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE nombre_usuario = 'vendedor.demo')
        INSERT INTO dbo.USUARIOS (id_rol, id_estado_usuario, nombre_usuario, clave_hash, nombre_completo, email)
        VALUES (@id_rol_vendedor, @id_estado_usuario_activo, 'vendedor.demo', 'hash_demo_vendedor_123', 'Vendedor Demo', 'ventas@pyme.com');

    IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE nombre_usuario = 'supervisor.demo')
        INSERT INTO dbo.USUARIOS (id_rol, id_estado_usuario, nombre_usuario, clave_hash, nombre_completo, email)
        VALUES (@id_rol_supervisor, @id_estado_usuario_activo, 'supervisor.demo', 'hash_demo_supervisor_123', 'Supervisor Demo', 'supervisor@pyme.com');

    /* 15. CLIENTES */
    DECLARE @id_localidad_neuquen INT,
            @id_localidad_plottier INT,
            @id_localidad_cipolletti INT,
            @id_tipo_cliente_ri INT,
            @id_tipo_cliente_mono INT,
            @id_tipo_cliente_cf INT,
            @id_tipo_documento_cuit INT,
            @id_tipo_documento_dni INT,
            @id_estado_cliente_activo INT;

    SELECT @id_localidad_neuquen = id_localidad FROM dbo.LOCALIDADES WHERE nombre = 'Neuquen' AND codigo_postal = '8300';
    SELECT @id_localidad_plottier = id_localidad FROM dbo.LOCALIDADES WHERE nombre = 'Plottier' AND codigo_postal = '8316';
    SELECT @id_localidad_cipolletti = id_localidad FROM dbo.LOCALIDADES WHERE nombre = 'Cipolletti' AND codigo_postal = '8324';
    SELECT @id_tipo_cliente_ri = id_tipo_cliente FROM dbo.TIPOS_CLIENTE WHERE tipo = 'Responsable Inscripto';
    SELECT @id_tipo_cliente_mono = id_tipo_cliente FROM dbo.TIPOS_CLIENTE WHERE tipo = 'Monotributista';
    SELECT @id_tipo_cliente_cf = id_tipo_cliente FROM dbo.TIPOS_CLIENTE WHERE tipo = 'Consumidor Final';
    SELECT @id_tipo_documento_cuit = id_tipo_documento FROM dbo.TIPOS_DOCUMENTO WHERE tipo = 'CUIT';
    SELECT @id_tipo_documento_dni = id_tipo_documento FROM dbo.TIPOS_DOCUMENTO WHERE tipo = 'DNI';
    SELECT @id_estado_cliente_activo = id_estado_cliente FROM dbo.ESTADOS_CLIENTES WHERE estado = 'Activo';

    IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE numero_documento = '30700000011')
        INSERT INTO dbo.CLIENTES
        (
            id_localidad, id_tipo_cliente, id_tipo_documento, id_estado_cliente,
            tipo_persona, numero_documento, nombre, apellido, razon_social,
            direccion, telefono, email
        )
        VALUES
        (
            @id_localidad_neuquen, @id_tipo_cliente_ri, @id_tipo_documento_cuit, @id_estado_cliente_activo,
            'J', '30700000011', NULL, NULL, 'Cliente Demo S.A.',
            'Av. Argentina 100', '2994000001', 'contacto@clientedemo.com'
        );

    IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE numero_documento = '30700000022')
        INSERT INTO dbo.CLIENTES
        (
            id_localidad, id_tipo_cliente, id_tipo_documento, id_estado_cliente,
            tipo_persona, numero_documento, nombre, apellido, razon_social,
            direccion, telefono, email
        )
        VALUES
        (
            @id_localidad_plottier, @id_tipo_cliente_mono, @id_tipo_documento_cuit, @id_estado_cliente_activo,
            'J', '30700000022', NULL, NULL, 'Servicios del Sur S.R.L.',
            'San Martin 250', '2994000002', 'administracion@serviciosdelsur.com'
        );

    IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE numero_documento = '30400000033')
        INSERT INTO dbo.CLIENTES
        (
            id_localidad, id_tipo_cliente, id_tipo_documento, id_estado_cliente,
            tipo_persona, numero_documento, nombre, apellido, razon_social,
            direccion, telefono, email
        )
        VALUES
        (
            @id_localidad_cipolletti, @id_tipo_cliente_ri, @id_tipo_documento_cuit, @id_estado_cliente_activo,
            'J', '30400000033', NULL, NULL, 'Comercial Andina',
            'Roca 450', '2994000003', 'ventas@comercialandina.com'
        );

    IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE numero_documento = '34999888')
        INSERT INTO dbo.CLIENTES
        (
            id_localidad, id_tipo_cliente, id_tipo_documento, id_estado_cliente,
            tipo_persona, numero_documento, nombre, apellido, razon_social,
            direccion, telefono, email
        )
        VALUES
        (
            @id_localidad_neuquen, @id_tipo_cliente_cf, @id_tipo_documento_dni, @id_estado_cliente_activo,
            'F', '34999888', 'Laura', 'Gomez', NULL,
            'Belgrano 500', '2994000004', 'laura.gomez@email.com'
        );

    /* 16. PRODUCTOS_SERVICIOS */
    DECLARE @id_cat_productos INT,
            @id_cat_servicios INT,
            @id_cat_insumos INT,
            @id_cat_soporte INT,
            @id_iva21 INT,
            @id_iva105 INT,
            @id_exento INT;

    SELECT @id_cat_productos = id_categoria FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Productos generales';
    SELECT @id_cat_servicios = id_categoria FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Servicios profesionales';
    SELECT @id_cat_insumos = id_categoria FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Insumos administrativos';
    SELECT @id_cat_soporte = id_categoria FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre = 'Soporte tecnico';
    SELECT @id_iva21 = id_impuesto FROM dbo.IMPUESTOS WHERE impuesto = 'IVA 21';
    SELECT @id_iva105 = id_impuesto FROM dbo.IMPUESTOS WHERE impuesto = 'IVA 10.5';
    SELECT @id_exento = id_impuesto FROM dbo.IMPUESTOS WHERE impuesto = 'Exento';

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Producto estandar A')
        INSERT INTO dbo.PRODUCTOS_SERVICIOS (id_categoria, id_impuesto, nombre, descripcion, precio_unitario_actual, stock_actual, activo)
        VALUES (@id_cat_productos, @id_iva21, 'Producto estandar A', 'Producto generico de venta habitual.', 15000.00, 100, 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Producto estandar B')
        INSERT INTO dbo.PRODUCTOS_SERVICIOS (id_categoria, id_impuesto, nombre, descripcion, precio_unitario_actual, stock_actual, activo)
        VALUES (@id_cat_productos, @id_iva21, 'Producto estandar B', 'Producto generico de venta habitual.', 8500.00, 80, 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Servicio de consultoria')
        INSERT INTO dbo.PRODUCTOS_SERVICIOS (id_categoria, id_impuesto, nombre, descripcion, precio_unitario_actual, stock_actual, activo)
        VALUES (@id_cat_servicios, @id_iva21, 'Servicio de consultoria', 'Servicio profesional por hora.', 45000.00, 0, 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Insumo administrativo')
        INSERT INTO dbo.PRODUCTOS_SERVICIOS (id_categoria, id_impuesto, nombre, descripcion, precio_unitario_actual, stock_actual, activo)
        VALUES (@id_cat_insumos, @id_iva105, 'Insumo administrativo', 'Insumo de oficina para clientes.', 3200.00, 250, 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Soporte tecnico mensual')
        INSERT INTO dbo.PRODUCTOS_SERVICIOS (id_categoria, id_impuesto, nombre, descripcion, precio_unitario_actual, stock_actual, activo)
        VALUES (@id_cat_soporte, @id_exento, 'Soporte tecnico mensual', 'Abono mensual de soporte tecnico.', 120000.00, 0, 1);

    /* 17. FACTURAS */
    DECLARE @id_cliente_demo INT,
            @id_cliente_sur INT,
            @id_cliente_andina INT,
            @id_usuario_vendedor INT,
            @id_usuario_supervisor INT,
            @id_estado_pagada INT,
            @id_estado_pendiente INT,
            @id_tipo_factura_a INT,
            @id_tipo_factura_b INT,
            @id_operacion_venta INT;

    SELECT @id_cliente_demo = id_cliente FROM dbo.CLIENTES WHERE numero_documento = '30700000011';
    SELECT @id_cliente_sur = id_cliente FROM dbo.CLIENTES WHERE numero_documento = '30700000022';
    SELECT @id_cliente_andina = id_cliente FROM dbo.CLIENTES WHERE numero_documento = '30400000033';
    SELECT @id_usuario_vendedor = id_usuario FROM dbo.USUARIOS WHERE nombre_usuario = 'vendedor.demo';
    SELECT @id_usuario_supervisor = id_usuario FROM dbo.USUARIOS WHERE nombre_usuario = 'supervisor.demo';
    SELECT @id_estado_pagada = id_estado_factura FROM dbo.ESTADOS_FACTURA WHERE estado = 'Pagada';
    SELECT @id_estado_pendiente = id_estado_factura FROM dbo.ESTADOS_FACTURA WHERE estado = 'Pendiente';
    SELECT @id_tipo_factura_a = id_tipo_factura FROM dbo.TIPOS_FACTURA WHERE tipo = 'A';
    SELECT @id_tipo_factura_b = id_tipo_factura FROM dbo.TIPOS_FACTURA WHERE tipo = 'B';
    SELECT @id_operacion_venta = id_tipo_operacion_factura FROM dbo.TIPOS_OPERACION_FACTURA WHERE operacion = 'Venta';

    IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura = 'A-0001-00000001')
        INSERT INTO dbo.FACTURAS
        (
            id_cliente, id_usuario, id_estado_factura, id_tipo_factura, id_tipo_operacion_factura,
            numero_factura, fecha_emision, total_neto, total_impuestos, total_descuentos,
            total_recargos, total, observaciones
        )
        VALUES
        (
            @id_cliente_demo, @id_usuario_vendedor, @id_estado_pagada, @id_tipo_factura_a, @id_operacion_venta,
            'A-0001-00000001', '2026-06-01T10:00:00', 75000.00, 15750.00, 0.00,
            0.00, 90750.00, 'Factura demo pagada.'
        );

    IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura = 'A-0001-00000002')
        INSERT INTO dbo.FACTURAS
        (
            id_cliente, id_usuario, id_estado_factura, id_tipo_factura, id_tipo_operacion_factura,
            numero_factura, fecha_emision, total_neto, total_impuestos, total_descuentos,
            total_recargos, total, observaciones
        )
        VALUES
        (
            @id_cliente_sur, @id_usuario_vendedor, @id_estado_pendiente, @id_tipo_factura_a, @id_operacion_venta,
            'A-0001-00000002', '2026-06-05T11:30:00', 25500.00, 5355.00, 0.00,
            0.00, 30855.00, 'Factura demo pendiente.'
        );

    IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura = 'B-0001-00000003')
        INSERT INTO dbo.FACTURAS
        (
            id_cliente, id_usuario, id_estado_factura, id_tipo_factura, id_tipo_operacion_factura,
            numero_factura, fecha_emision, total_neto, total_impuestos, total_descuentos,
            total_recargos, total, observaciones
        )
        VALUES
        (
            @id_cliente_andina, @id_usuario_supervisor, @id_estado_pagada, @id_tipo_factura_b, @id_operacion_venta,
            'B-0001-00000003', '2026-06-10T15:15:00', 120000.00, 0.00, 5000.00,
            2500.00, 117500.00, 'Factura demo con descuento y recargo.'
        );

    /* 18. DETALLES_FACTURA */
    DECLARE @id_factura_1 INT,
            @id_factura_2 INT,
            @id_factura_3 INT,
            @id_producto_a INT,
            @id_producto_b INT,
            @id_servicio_consultoria INT,
            @id_soporte_mensual INT;

    SELECT @id_factura_1 = id_factura FROM dbo.FACTURAS WHERE numero_factura = 'A-0001-00000001';
    SELECT @id_factura_2 = id_factura FROM dbo.FACTURAS WHERE numero_factura = 'A-0001-00000002';
    SELECT @id_factura_3 = id_factura FROM dbo.FACTURAS WHERE numero_factura = 'B-0001-00000003';
    SELECT @id_producto_a = id_producto_servicio FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Producto estandar A';
    SELECT @id_producto_b = id_producto_servicio FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Producto estandar B';
    SELECT @id_servicio_consultoria = id_producto_servicio FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Servicio de consultoria';
    SELECT @id_soporte_mensual = id_producto_servicio FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre = 'Soporte tecnico mensual';

    IF NOT EXISTS (SELECT 1 FROM dbo.DETALLES_FACTURA WHERE id_factura = @id_factura_1 AND id_producto_servicio = @id_producto_a)
        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura, id_producto_servicio, cantidad, precio_unitario_facturado, subtotal_neto,
            porcentaje_impuesto_facturado, importe_impuesto, subtotal_con_impuesto
        )
        VALUES (@id_factura_1, @id_producto_a, 2.00, 15000.00, 30000.00, 21.00, 6300.00, 36300.00);

    IF NOT EXISTS (SELECT 1 FROM dbo.DETALLES_FACTURA WHERE id_factura = @id_factura_1 AND id_producto_servicio = @id_servicio_consultoria)
        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura, id_producto_servicio, cantidad, precio_unitario_facturado, subtotal_neto,
            porcentaje_impuesto_facturado, importe_impuesto, subtotal_con_impuesto
        )
        VALUES (@id_factura_1, @id_servicio_consultoria, 1.00, 45000.00, 45000.00, 21.00, 9450.00, 54450.00);

    IF NOT EXISTS (SELECT 1 FROM dbo.DETALLES_FACTURA WHERE id_factura = @id_factura_2 AND id_producto_servicio = @id_producto_b)
        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura, id_producto_servicio, cantidad, precio_unitario_facturado, subtotal_neto,
            porcentaje_impuesto_facturado, importe_impuesto, subtotal_con_impuesto
        )
        VALUES (@id_factura_2, @id_producto_b, 3.00, 8500.00, 25500.00, 21.00, 5355.00, 30855.00);

    IF NOT EXISTS (SELECT 1 FROM dbo.DETALLES_FACTURA WHERE id_factura = @id_factura_3 AND id_producto_servicio = @id_soporte_mensual)
        INSERT INTO dbo.DETALLES_FACTURA
        (
            id_factura, id_producto_servicio, cantidad, precio_unitario_facturado, subtotal_neto,
            porcentaje_impuesto_facturado, importe_impuesto, subtotal_con_impuesto
        )
        VALUES (@id_factura_3, @id_soporte_mensual, 1.00, 120000.00, 120000.00, 0.00, 0.00, 120000.00);

    /* 19. COMPROBANTES_PAGO */
    DECLARE @id_forma_transferencia INT,
            @id_forma_efectivo INT;

    SELECT @id_forma_transferencia = id_forma_pago FROM dbo.FORMAS_PAGO WHERE forma_pago = 'Transferencia bancaria';
    SELECT @id_forma_efectivo = id_forma_pago FROM dbo.FORMAS_PAGO WHERE forma_pago = 'Efectivo';

    IF NOT EXISTS (SELECT 1 FROM dbo.COMPROBANTES_PAGO WHERE id_factura = @id_factura_1)
        INSERT INTO dbo.COMPROBANTES_PAGO
        (
            id_factura, id_forma_pago, fecha_pago, monto, numero_referencia, observaciones
        )
        VALUES
        (
            @id_factura_1, @id_forma_transferencia, '2026-06-02T09:00:00', 90750.00,
            'TRF-000001', 'Pago total de factura demo.'
        );

    IF NOT EXISTS (SELECT 1 FROM dbo.COMPROBANTES_PAGO WHERE id_factura = @id_factura_3)
        INSERT INTO dbo.COMPROBANTES_PAGO
        (
            id_factura, id_forma_pago, fecha_pago, monto, numero_referencia, observaciones
        )
        VALUES
        (
            @id_factura_3, @id_forma_efectivo, '2026-06-11T16:30:00', 117500.00,
            'EFE-000003', 'Pago total de factura con descuento y recargo.'
        );

    /* 20. AUDITORIA_FACTURA */
    IF NOT EXISTS (SELECT 1 FROM dbo.AUDITORIA_FACTURA WHERE id_factura = @id_factura_1 AND accion = 'ALTA_FACTURA')
        INSERT INTO dbo.AUDITORIA_FACTURA (id_factura, id_usuario, accion, fecha, detalle)
        VALUES (@id_factura_1, @id_usuario_vendedor, 'ALTA_FACTURA', '2026-06-01T10:00:00', 'Factura creada desde script de datos iniciales.');

    IF NOT EXISTS (SELECT 1 FROM dbo.AUDITORIA_FACTURA WHERE id_factura = @id_factura_2 AND accion = 'ALTA_FACTURA')
        INSERT INTO dbo.AUDITORIA_FACTURA (id_factura, id_usuario, accion, fecha, detalle)
        VALUES (@id_factura_2, @id_usuario_vendedor, 'ALTA_FACTURA', '2026-06-05T11:30:00', 'Factura creada desde script de datos iniciales.');

    IF NOT EXISTS (SELECT 1 FROM dbo.AUDITORIA_FACTURA WHERE id_factura = @id_factura_3 AND accion = 'ALTA_FACTURA')
        INSERT INTO dbo.AUDITORIA_FACTURA (id_factura, id_usuario, accion, fecha, detalle)
        VALUES (@id_factura_3, @id_usuario_supervisor, 'ALTA_FACTURA', '2026-06-10T15:15:00', 'Factura creada desde script de datos iniciales.');

    /* 21. DESCUENTOS_FACTURA Y RECARGOS_FACTURA */
    IF NOT EXISTS (SELECT 1 FROM dbo.DESCUENTOS_FACTURA WHERE id_factura = @id_factura_3 AND descripcion = 'Descuento comercial')
        INSERT INTO dbo.DESCUENTOS_FACTURA (id_factura, descripcion, porcentaje, monto)
        VALUES (@id_factura_3, 'Descuento comercial', NULL, 5000.00);

    IF NOT EXISTS (SELECT 1 FROM dbo.RECARGOS_FACTURA WHERE id_factura = @id_factura_3 AND descripcion = 'Recargo administrativo')
        INSERT INTO dbo.RECARGOS_FACTURA (id_factura, descripcion, porcentaje, monto)
        VALUES (@id_factura_3, 'Recargo administrativo', NULL, 2500.00);

    COMMIT TRANSACTION;

    PRINT 'Datos iniciales insertados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

    SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO

/* Verificacion final */
SELECT 'PROVINCIAS' AS tabla, COUNT(*) AS cantidad FROM dbo.PROVINCIAS
UNION ALL
SELECT 'LOCALIDADES', COUNT(*) FROM dbo.LOCALIDADES
UNION ALL
SELECT 'CLIENTES', COUNT(*) FROM dbo.CLIENTES
UNION ALL
SELECT 'USUARIOS', COUNT(*) FROM dbo.USUARIOS
UNION ALL
SELECT 'PRODUCTOS_SERVICIOS', COUNT(*) FROM dbo.PRODUCTOS_SERVICIOS
UNION ALL
SELECT 'FACTURAS', COUNT(*) FROM dbo.FACTURAS
UNION ALL
SELECT 'DETALLES_FACTURA', COUNT(*) FROM dbo.DETALLES_FACTURA
UNION ALL
SELECT 'COMPROBANTES_PAGO', COUNT(*) FROM dbo.COMPROBANTES_PAGO;
GO
