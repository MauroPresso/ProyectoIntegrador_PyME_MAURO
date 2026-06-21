/* ============================================================
   INSERTS_DATOS_PRUEBA.SQL
   Ubicación: 04_SQLServer_Modelo_Fisico\05_Inserts
   ============================================================ */
USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* Opciones requeridas por SQL Server para operar con índices filtrados */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
GO

BEGIN TRY
BEGIN TRANSACTION;

/* Catálogos principales */
IF NOT EXISTS (SELECT 1 FROM dbo.PROVINCIAS WHERE nombre='Buenos Aires') INSERT INTO dbo.PROVINCIAS(nombre) VALUES('Buenos Aires');
IF NOT EXISTS (SELECT 1 FROM dbo.PROVINCIAS WHERE nombre='Córdoba') INSERT INTO dbo.PROVINCIAS(nombre) VALUES('Córdoba');
IF NOT EXISTS (SELECT 1 FROM dbo.PROVINCIAS WHERE nombre='Santa Fe') INSERT INTO dbo.PROVINCIAS(nombre) VALUES('Santa Fe');
IF NOT EXISTS (SELECT 1 FROM dbo.PROVINCIAS WHERE nombre='Neuquén') INSERT INTO dbo.PROVINCIAS(nombre) VALUES('Neuquén');
IF NOT EXISTS (SELECT 1 FROM dbo.PROVINCIAS WHERE nombre='Río Negro') INSERT INTO dbo.PROVINCIAS(nombre) VALUES('Río Negro');

IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre='CABA' AND codigo_postal='1000') INSERT INTO dbo.LOCALIDADES(id_provincia,nombre,codigo_postal) SELECT id_provincia,'CABA','1000' FROM dbo.PROVINCIAS WHERE nombre='Buenos Aires';
IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre='La Plata' AND codigo_postal='1900') INSERT INTO dbo.LOCALIDADES(id_provincia,nombre,codigo_postal) SELECT id_provincia,'La Plata','1900' FROM dbo.PROVINCIAS WHERE nombre='Buenos Aires';
IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre='Rosario' AND codigo_postal='2000') INSERT INTO dbo.LOCALIDADES(id_provincia,nombre,codigo_postal) SELECT id_provincia,'Rosario','2000' FROM dbo.PROVINCIAS WHERE nombre='Santa Fe';
IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre='Córdoba Capital' AND codigo_postal='5000') INSERT INTO dbo.LOCALIDADES(id_provincia,nombre,codigo_postal) SELECT id_provincia,'Córdoba Capital','5000' FROM dbo.PROVINCIAS WHERE nombre='Córdoba';
IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre='Neuquén' AND codigo_postal='8300') INSERT INTO dbo.LOCALIDADES(id_provincia,nombre,codigo_postal) SELECT id_provincia,'Neuquén','8300' FROM dbo.PROVINCIAS WHERE nombre='Neuquén';
IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE nombre='Cipolletti' AND codigo_postal='8324') INSERT INTO dbo.LOCALIDADES(id_provincia,nombre,codigo_postal) SELECT id_provincia,'Cipolletti','8324' FROM dbo.PROVINCIAS WHERE nombre='Río Negro';

IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE tipo='Consumidor Final') INSERT INTO dbo.TIPOS_CLIENTE(tipo,descripcion) VALUES('Consumidor Final','Persona física que compra para consumo final.');
IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE tipo='Responsable Inscripto') INSERT INTO dbo.TIPOS_CLIENTE(tipo,descripcion) VALUES('Responsable Inscripto','Persona o empresa inscripta en IVA.');
IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE tipo='Monotributista') INSERT INTO dbo.TIPOS_CLIENTE(tipo,descripcion) VALUES('Monotributista','Pequeño contribuyente.');
IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE tipo='Exento') INSERT INTO dbo.TIPOS_CLIENTE(tipo,descripcion) VALUES('Exento','Sujeto exento de IVA.');

IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_DOCUMENTO WHERE tipo='DNI') INSERT INTO dbo.TIPOS_DOCUMENTO(tipo,descripcion) VALUES('DNI','Documento Nacional de Identidad.');
IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_DOCUMENTO WHERE tipo='CUIT') INSERT INTO dbo.TIPOS_DOCUMENTO(tipo,descripcion) VALUES('CUIT','Clave Única de Identificación Tributaria.');
IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_DOCUMENTO WHERE tipo='CUIL') INSERT INTO dbo.TIPOS_DOCUMENTO(tipo,descripcion) VALUES('CUIL','Código Único de Identificación Laboral.');
IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_DOCUMENTO WHERE tipo='Pasaporte') INSERT INTO dbo.TIPOS_DOCUMENTO(tipo,descripcion) VALUES('Pasaporte','Documento de viaje extranjero.');

IF NOT EXISTS (SELECT 1 FROM dbo.ROLES WHERE rol='Administrador') INSERT INTO dbo.ROLES(rol,descripcion) VALUES('Administrador','Acceso total al sistema.');
IF NOT EXISTS (SELECT 1 FROM dbo.ROLES WHERE rol='Vendedor') INSERT INTO dbo.ROLES(rol,descripcion) VALUES('Vendedor','Gestiona clientes, ventas y facturas.');
IF NOT EXISTS (SELECT 1 FROM dbo.ROLES WHERE rol='Auditor') INSERT INTO dbo.ROLES(rol,descripcion) VALUES('Auditor','Consulta reportes y auditoría.');

IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_USUARIOS WHERE estado='Activo') INSERT INTO dbo.ESTADOS_USUARIOS(estado,descripcion) VALUES('Activo','Usuario habilitado.');
IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_USUARIOS WHERE estado='Bloqueado') INSERT INTO dbo.ESTADOS_USUARIOS(estado,descripcion) VALUES('Bloqueado','Usuario bloqueado temporalmente.');
IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_USUARIOS WHERE estado='Inactivo') INSERT INTO dbo.ESTADOS_USUARIOS(estado,descripcion) VALUES('Inactivo','Usuario dado de baja.');

IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_CLIENTES WHERE estado='Activo') INSERT INTO dbo.ESTADOS_CLIENTES(estado,descripcion) VALUES('Activo','Cliente habilitado.');
IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_CLIENTES WHERE estado='Moroso') INSERT INTO dbo.ESTADOS_CLIENTES(estado,descripcion) VALUES('Moroso','Cliente con deuda pendiente.');
IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_CLIENTES WHERE estado='Inactivo') INSERT INTO dbo.ESTADOS_CLIENTES(estado,descripcion) VALUES('Inactivo','Cliente dado de baja.');

IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE forma_pago='Efectivo') INSERT INTO dbo.FORMAS_PAGO(forma_pago,descripcion,activo) VALUES('Efectivo','Pago en efectivo.',1);
IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE forma_pago='Tarjeta Crédito') INSERT INTO dbo.FORMAS_PAGO(forma_pago,descripcion,activo) VALUES('Tarjeta Crédito','Pago con tarjeta de crédito.',1);
IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE forma_pago='Tarjeta Débito') INSERT INTO dbo.FORMAS_PAGO(forma_pago,descripcion,activo) VALUES('Tarjeta Débito','Pago con tarjeta de débito.',1);
IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE forma_pago='Transferencia') INSERT INTO dbo.FORMAS_PAGO(forma_pago,descripcion,activo) VALUES('Transferencia','Pago mediante transferencia bancaria.',1);
IF NOT EXISTS (SELECT 1 FROM dbo.FORMAS_PAGO WHERE forma_pago='Mercado Pago') INSERT INTO dbo.FORMAS_PAGO(forma_pago,descripcion,activo) VALUES('Mercado Pago','Pago mediante billetera virtual.',1);

IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE estado='Emitida') INSERT INTO dbo.ESTADOS_FACTURA(estado,descripcion) VALUES('Emitida','Factura generada y pendiente de pago.');
IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE estado='Pagada') INSERT INTO dbo.ESTADOS_FACTURA(estado,descripcion) VALUES('Pagada','Factura abonada totalmente.');
IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_FACTURA WHERE estado='Anulada') INSERT INTO dbo.ESTADOS_FACTURA(estado,descripcion) VALUES('Anulada','Factura anulada.');

IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_FACTURA WHERE tipo='Factura A') INSERT INTO dbo.TIPOS_FACTURA(tipo,descripcion) VALUES('Factura A','Para responsable inscripto.');
IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_FACTURA WHERE tipo='Factura B') INSERT INTO dbo.TIPOS_FACTURA(tipo,descripcion) VALUES('Factura B','Para consumidor final.');
IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_FACTURA WHERE tipo='Factura C') INSERT INTO dbo.TIPOS_FACTURA(tipo,descripcion) VALUES('Factura C','Para monotributista.');

IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_OPERACION_FACTURA WHERE operacion='Venta') INSERT INTO dbo.TIPOS_OPERACION_FACTURA(operacion,descripcion) VALUES('Venta','Operación normal de venta.');
IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_OPERACION_FACTURA WHERE operacion='Nota de Crédito') INSERT INTO dbo.TIPOS_OPERACION_FACTURA(operacion,descripcion) VALUES('Nota de Crédito','Devolución, ajuste o anulación parcial.');

IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre='Electrónica') INSERT INTO dbo.CATEGORIAS_PRODUCTO(nombre,descripcion,activo) VALUES('Electrónica','Productos electrónicos e informáticos.',1);
IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre='Servicios') INSERT INTO dbo.CATEGORIAS_PRODUCTO(nombre,descripcion,activo) VALUES('Servicios','Servicios profesionales o técnicos.',1);
IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre='Insumos') INSERT INTO dbo.CATEGORIAS_PRODUCTO(nombre,descripcion,activo) VALUES('Insumos','Insumos administrativos y operativos.',1);
IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE nombre='Hogar') INSERT INTO dbo.CATEGORIAS_PRODUCTO(nombre,descripcion,activo) VALUES('Hogar','Productos generales para hogar u oficina.',1);

IF NOT EXISTS (SELECT 1 FROM dbo.IMPUESTOS WHERE impuesto='IVA 21%') INSERT INTO dbo.IMPUESTOS(impuesto,porcentaje,descripcion,activo) VALUES('IVA 21%',21.00,'Alícuota general de IVA.',1);
IF NOT EXISTS (SELECT 1 FROM dbo.IMPUESTOS WHERE impuesto='IVA 10.5%') INSERT INTO dbo.IMPUESTOS(impuesto,porcentaje,descripcion,activo) VALUES('IVA 10.5%',10.50,'Alícuota reducida de IVA.',1);
IF NOT EXISTS (SELECT 1 FROM dbo.IMPUESTOS WHERE impuesto='IVA 0%') INSERT INTO dbo.IMPUESTOS(impuesto,porcentaje,descripcion,activo) VALUES('IVA 0%',0.00,'Producto o servicio exento/no gravado.',1);

/* Usuarios */
IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE nombre_usuario='admin') INSERT INTO dbo.USUARIOS(id_rol,id_estado_usuario,nombre_usuario,clave_hash,nombre_completo,email) SELECT r.id_rol,eu.id_estado_usuario,'admin','hash_demo_admin','Administrador del Sistema','admin@pyme.com' FROM dbo.ROLES r CROSS JOIN dbo.ESTADOS_USUARIOS eu WHERE r.rol='Administrador' AND eu.estado='Activo';
IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE nombre_usuario='vendedor1') INSERT INTO dbo.USUARIOS(id_rol,id_estado_usuario,nombre_usuario,clave_hash,nombre_completo,email) SELECT r.id_rol,eu.id_estado_usuario,'vendedor1','hash_demo_vendedor1','Carlos Vendedor','carlos.vendedor@pyme.com' FROM dbo.ROLES r CROSS JOIN dbo.ESTADOS_USUARIOS eu WHERE r.rol='Vendedor' AND eu.estado='Activo';
IF NOT EXISTS (SELECT 1 FROM dbo.USUARIOS WHERE nombre_usuario='vendedor2') INSERT INTO dbo.USUARIOS(id_rol,id_estado_usuario,nombre_usuario,clave_hash,nombre_completo,email) SELECT r.id_rol,eu.id_estado_usuario,'vendedor2','hash_demo_vendedor2','Ana Vendedora','ana.vendedora@pyme.com' FROM dbo.ROLES r CROSS JOIN dbo.ESTADOS_USUARIOS eu WHERE r.rol='Vendedor' AND eu.estado='Activo';

/* Clientes */
IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE numero_documento='30123456789') INSERT INTO dbo.CLIENTES(id_localidad,id_tipo_cliente,id_tipo_documento,id_estado_cliente,tipo_persona,numero_documento,razon_social,direccion,telefono,email) SELECT l.id_localidad,tc.id_tipo_cliente,td.id_tipo_documento,ec.id_estado_cliente,'J','30123456789','Distribuidora del Centro SRL','Av. Corrientes 3456','1123456789','administracion@distribuidoracentro.com' FROM dbo.LOCALIDADES l CROSS JOIN dbo.TIPOS_CLIENTE tc CROSS JOIN dbo.TIPOS_DOCUMENTO td CROSS JOIN dbo.ESTADOS_CLIENTES ec WHERE l.nombre='CABA' AND tc.tipo='Responsable Inscripto' AND td.tipo='CUIT' AND ec.estado='Activo';
IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE numero_documento='30234567890') INSERT INTO dbo.CLIENTES(id_localidad,id_tipo_cliente,id_tipo_documento,id_estado_cliente,tipo_persona,numero_documento,razon_social,direccion,telefono,email) SELECT l.id_localidad,tc.id_tipo_cliente,td.id_tipo_documento,ec.id_estado_cliente,'J','30234567890','Tecno Sur SA','Av. Colón 567','3512345678','ventas@tecnosur.com' FROM dbo.LOCALIDADES l CROSS JOIN dbo.TIPOS_CLIENTE tc CROSS JOIN dbo.TIPOS_DOCUMENTO td CROSS JOIN dbo.ESTADOS_CLIENTES ec WHERE l.nombre='Córdoba Capital' AND tc.tipo='Responsable Inscripto' AND td.tipo='CUIT' AND ec.estado='Activo';
IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE numero_documento='20345678') INSERT INTO dbo.CLIENTES(id_localidad,id_tipo_cliente,id_tipo_documento,id_estado_cliente,tipo_persona,numero_documento,nombre,apellido,direccion,telefono,email) SELECT l.id_localidad,tc.id_tipo_cliente,td.id_tipo_documento,ec.id_estado_cliente,'F','20345678','Carlos','Gómez','Av. Rivadavia 1234','1122334455','carlos.gomez@mail.com' FROM dbo.LOCALIDADES l CROSS JOIN dbo.TIPOS_CLIENTE tc CROSS JOIN dbo.TIPOS_DOCUMENTO td CROSS JOIN dbo.ESTADOS_CLIENTES ec WHERE l.nombre='CABA' AND tc.tipo='Consumidor Final' AND td.tipo='DNI' AND ec.estado='Activo';
IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE numero_documento='27456789') INSERT INTO dbo.CLIENTES(id_localidad,id_tipo_cliente,id_tipo_documento,id_estado_cliente,tipo_persona,numero_documento,nombre,apellido,direccion,telefono,email) SELECT l.id_localidad,tc.id_tipo_cliente,td.id_tipo_documento,ec.id_estado_cliente,'F','27456789','Ana','Martínez','Calle 12 N° 345','2212345678','ana.martinez@mail.com' FROM dbo.LOCALIDADES l CROSS JOIN dbo.TIPOS_CLIENTE tc CROSS JOIN dbo.TIPOS_DOCUMENTO td CROSS JOIN dbo.ESTADOS_CLIENTES ec WHERE l.nombre='La Plata' AND tc.tipo='Consumidor Final' AND td.tipo='DNI' AND ec.estado='Activo';

/* Productos/servicios */
IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre='Mouse Inalámbrico' AND activo=1) INSERT INTO dbo.PRODUCTOS_SERVICIOS(id_categoria,id_impuesto,nombre,descripcion,precio_unitario_actual,stock_actual,activo) SELECT c.id_categoria,i.id_impuesto,'Mouse Inalámbrico','Mouse óptico inalámbrico USB.',5500.00,100,1 FROM dbo.CATEGORIAS_PRODUCTO c CROSS JOIN dbo.IMPUESTOS i WHERE c.nombre='Electrónica' AND i.impuesto='IVA 21%';
IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre='Teclado Mecánico' AND activo=1) INSERT INTO dbo.PRODUCTOS_SERVICIOS(id_categoria,id_impuesto,nombre,descripcion,precio_unitario_actual,stock_actual,activo) SELECT c.id_categoria,i.id_impuesto,'Teclado Mecánico','Teclado mecánico para oficina.',25000.00,50,1 FROM dbo.CATEGORIAS_PRODUCTO c CROSS JOIN dbo.IMPUESTOS i WHERE c.nombre='Electrónica' AND i.impuesto='IVA 21%';
IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre='Notebook Oficina' AND activo=1) INSERT INTO dbo.PRODUCTOS_SERVICIOS(id_categoria,id_impuesto,nombre,descripcion,precio_unitario_actual,stock_actual,activo) SELECT c.id_categoria,i.id_impuesto,'Notebook Oficina','Notebook para tareas administrativas.',850000.00,10,1 FROM dbo.CATEGORIAS_PRODUCTO c CROSS JOIN dbo.IMPUESTOS i WHERE c.nombre='Electrónica' AND i.impuesto='IVA 21%';
IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre='Servicio de Soporte Técnico' AND activo=1) INSERT INTO dbo.PRODUCTOS_SERVICIOS(id_categoria,id_impuesto,nombre,descripcion,precio_unitario_actual,stock_actual,activo) SELECT c.id_categoria,i.id_impuesto,'Servicio de Soporte Técnico','Servicio técnico facturado por hora.',12000.00,0,1 FROM dbo.CATEGORIAS_PRODUCTO c CROSS JOIN dbo.IMPUESTOS i WHERE c.nombre='Servicios' AND i.impuesto='IVA 21%';
IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre='Consultoría Funcional' AND activo=1) INSERT INTO dbo.PRODUCTOS_SERVICIOS(id_categoria,id_impuesto,nombre,descripcion,precio_unitario_actual,stock_actual,activo) SELECT c.id_categoria,i.id_impuesto,'Consultoría Funcional','Servicio profesional de consultoría.',35000.00,0,1 FROM dbo.CATEGORIAS_PRODUCTO c CROSS JOIN dbo.IMPUESTOS i WHERE c.nombre='Servicios' AND i.impuesto='IVA 21%';
IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTOS_SERVICIOS WHERE nombre='Pack Insumos Oficina' AND activo=1) INSERT INTO dbo.PRODUCTOS_SERVICIOS(id_categoria,id_impuesto,nombre,descripcion,precio_unitario_actual,stock_actual,activo) SELECT c.id_categoria,i.id_impuesto,'Pack Insumos Oficina','Pack básico de insumos administrativos.',8500.00,80,1 FROM dbo.CATEGORIAS_PRODUCTO c CROSS JOIN dbo.IMPUESTOS i WHERE c.nombre='Insumos' AND i.impuesto='IVA 10.5%';

/* Facturas */
IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura='F-0001-00000001') INSERT INTO dbo.FACTURAS(id_cliente,id_usuario,id_estado_factura,id_tipo_factura,id_tipo_operacion_factura,numero_factura,fecha_emision,observaciones) SELECT cl.id_cliente,u.id_usuario,ef.id_estado_factura,tf.id_tipo_factura,tof.id_tipo_operacion_factura,'F-0001-00000001','2026-06-06T10:00:00','Factura pagada de prueba.' FROM dbo.CLIENTES cl CROSS JOIN dbo.USUARIOS u CROSS JOIN dbo.ESTADOS_FACTURA ef CROSS JOIN dbo.TIPOS_FACTURA tf CROSS JOIN dbo.TIPOS_OPERACION_FACTURA tof WHERE cl.numero_documento='30123456789' AND u.nombre_usuario='vendedor1' AND ef.estado='Pagada' AND tf.tipo='Factura A' AND tof.operacion='Venta';
IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura='F-0001-00000002') INSERT INTO dbo.FACTURAS(id_cliente,id_usuario,id_estado_factura,id_tipo_factura,id_tipo_operacion_factura,numero_factura,fecha_emision,observaciones) SELECT cl.id_cliente,u.id_usuario,ef.id_estado_factura,tf.id_tipo_factura,tof.id_tipo_operacion_factura,'F-0001-00000002','2026-06-07T11:30:00','Factura emitida de prueba.' FROM dbo.CLIENTES cl CROSS JOIN dbo.USUARIOS u CROSS JOIN dbo.ESTADOS_FACTURA ef CROSS JOIN dbo.TIPOS_FACTURA tf CROSS JOIN dbo.TIPOS_OPERACION_FACTURA tof WHERE cl.numero_documento='20345678' AND u.nombre_usuario='vendedor1' AND ef.estado='Emitida' AND tf.tipo='Factura B' AND tof.operacion='Venta';
IF NOT EXISTS (SELECT 1 FROM dbo.FACTURAS WHERE numero_factura='F-0001-00000003') INSERT INTO dbo.FACTURAS(id_cliente,id_usuario,id_estado_factura,id_tipo_factura,id_tipo_operacion_factura,numero_factura,fecha_emision,observaciones) SELECT cl.id_cliente,u.id_usuario,ef.id_estado_factura,tf.id_tipo_factura,tof.id_tipo_operacion_factura,'F-0001-00000003','2026-06-08T12:15:00','Factura pagada con recargo.' FROM dbo.CLIENTES cl CROSS JOIN dbo.USUARIOS u CROSS JOIN dbo.ESTADOS_FACTURA ef CROSS JOIN dbo.TIPOS_FACTURA tf CROSS JOIN dbo.TIPOS_OPERACION_FACTURA tof WHERE cl.numero_documento='30234567890' AND u.nombre_usuario='vendedor2' AND ef.estado='Pagada' AND tf.tipo='Factura A' AND tof.operacion='Venta';

/* Detalles */
IF NOT EXISTS (SELECT 1 FROM dbo.DETALLES_FACTURA df JOIN dbo.FACTURAS f ON f.id_factura=df.id_factura JOIN dbo.PRODUCTOS_SERVICIOS p ON p.id_producto_servicio=df.id_producto_servicio WHERE f.numero_factura='F-0001-00000001' AND p.nombre='Mouse Inalámbrico') INSERT INTO dbo.DETALLES_FACTURA(id_factura,id_producto_servicio,cantidad,precio_unitario_facturado,subtotal_neto,porcentaje_impuesto_facturado,importe_impuesto,subtotal_con_impuesto) SELECT f.id_factura,p.id_producto_servicio,2.00,p.precio_unitario_actual,CAST(2*p.precio_unitario_actual AS DECIMAL(12,2)),i.porcentaje,CAST((2*p.precio_unitario_actual)*i.porcentaje/100 AS DECIMAL(12,2)),CAST((2*p.precio_unitario_actual)*(1+i.porcentaje/100) AS DECIMAL(12,2)) FROM dbo.FACTURAS f JOIN dbo.PRODUCTOS_SERVICIOS p ON p.nombre='Mouse Inalámbrico' JOIN dbo.IMPUESTOS i ON i.id_impuesto=p.id_impuesto WHERE f.numero_factura='F-0001-00000001';
IF NOT EXISTS (SELECT 1 FROM dbo.DETALLES_FACTURA df JOIN dbo.FACTURAS f ON f.id_factura=df.id_factura JOIN dbo.PRODUCTOS_SERVICIOS p ON p.id_producto_servicio=df.id_producto_servicio WHERE f.numero_factura='F-0001-00000001' AND p.nombre='Consultoría Funcional') INSERT INTO dbo.DETALLES_FACTURA(id_factura,id_producto_servicio,cantidad,precio_unitario_facturado,subtotal_neto,porcentaje_impuesto_facturado,importe_impuesto,subtotal_con_impuesto) SELECT f.id_factura,p.id_producto_servicio,1.00,p.precio_unitario_actual,CAST(p.precio_unitario_actual AS DECIMAL(12,2)),i.porcentaje,CAST(p.precio_unitario_actual*i.porcentaje/100 AS DECIMAL(12,2)),CAST(p.precio_unitario_actual*(1+i.porcentaje/100) AS DECIMAL(12,2)) FROM dbo.FACTURAS f JOIN dbo.PRODUCTOS_SERVICIOS p ON p.nombre='Consultoría Funcional' JOIN dbo.IMPUESTOS i ON i.id_impuesto=p.id_impuesto WHERE f.numero_factura='F-0001-00000001';
IF NOT EXISTS (SELECT 1 FROM dbo.DETALLES_FACTURA df JOIN dbo.FACTURAS f ON f.id_factura=df.id_factura JOIN dbo.PRODUCTOS_SERVICIOS p ON p.id_producto_servicio=df.id_producto_servicio WHERE f.numero_factura='F-0001-00000002' AND p.nombre='Pack Insumos Oficina') INSERT INTO dbo.DETALLES_FACTURA(id_factura,id_producto_servicio,cantidad,precio_unitario_facturado,subtotal_neto,porcentaje_impuesto_facturado,importe_impuesto,subtotal_con_impuesto) SELECT f.id_factura,p.id_producto_servicio,3.00,p.precio_unitario_actual,CAST(3*p.precio_unitario_actual AS DECIMAL(12,2)),i.porcentaje,CAST((3*p.precio_unitario_actual)*i.porcentaje/100 AS DECIMAL(12,2)),CAST((3*p.precio_unitario_actual)*(1+i.porcentaje/100) AS DECIMAL(12,2)) FROM dbo.FACTURAS f JOIN dbo.PRODUCTOS_SERVICIOS p ON p.nombre='Pack Insumos Oficina' JOIN dbo.IMPUESTOS i ON i.id_impuesto=p.id_impuesto WHERE f.numero_factura='F-0001-00000002';
IF NOT EXISTS (SELECT 1 FROM dbo.DETALLES_FACTURA df JOIN dbo.FACTURAS f ON f.id_factura=df.id_factura JOIN dbo.PRODUCTOS_SERVICIOS p ON p.id_producto_servicio=df.id_producto_servicio WHERE f.numero_factura='F-0001-00000003' AND p.nombre='Notebook Oficina') INSERT INTO dbo.DETALLES_FACTURA(id_factura,id_producto_servicio,cantidad,precio_unitario_facturado,subtotal_neto,porcentaje_impuesto_facturado,importe_impuesto,subtotal_con_impuesto) SELECT f.id_factura,p.id_producto_servicio,1.00,p.precio_unitario_actual,CAST(p.precio_unitario_actual AS DECIMAL(12,2)),i.porcentaje,CAST(p.precio_unitario_actual*i.porcentaje/100 AS DECIMAL(12,2)),CAST(p.precio_unitario_actual*(1+i.porcentaje/100) AS DECIMAL(12,2)) FROM dbo.FACTURAS f JOIN dbo.PRODUCTOS_SERVICIOS p ON p.nombre='Notebook Oficina' JOIN dbo.IMPUESTOS i ON i.id_impuesto=p.id_impuesto WHERE f.numero_factura='F-0001-00000003';
IF NOT EXISTS (SELECT 1 FROM dbo.DETALLES_FACTURA df JOIN dbo.FACTURAS f ON f.id_factura=df.id_factura JOIN dbo.PRODUCTOS_SERVICIOS p ON p.id_producto_servicio=df.id_producto_servicio WHERE f.numero_factura='F-0001-00000003' AND p.nombre='Servicio de Soporte Técnico') INSERT INTO dbo.DETALLES_FACTURA(id_factura,id_producto_servicio,cantidad,precio_unitario_facturado,subtotal_neto,porcentaje_impuesto_facturado,importe_impuesto,subtotal_con_impuesto) SELECT f.id_factura,p.id_producto_servicio,4.00,p.precio_unitario_actual,CAST(4*p.precio_unitario_actual AS DECIMAL(12,2)),i.porcentaje,CAST((4*p.precio_unitario_actual)*i.porcentaje/100 AS DECIMAL(12,2)),CAST((4*p.precio_unitario_actual)*(1+i.porcentaje/100) AS DECIMAL(12,2)) FROM dbo.FACTURAS f JOIN dbo.PRODUCTOS_SERVICIOS p ON p.nombre='Servicio de Soporte Técnico' JOIN dbo.IMPUESTOS i ON i.id_impuesto=p.id_impuesto WHERE f.numero_factura='F-0001-00000003';

/* Descuento y recargo */
IF NOT EXISTS (SELECT 1 FROM dbo.DESCUENTOS_FACTURA d JOIN dbo.FACTURAS f ON f.id_factura=d.id_factura WHERE f.numero_factura='F-0001-00000001' AND d.descripcion='Bonificación comercial') INSERT INTO dbo.DESCUENTOS_FACTURA(id_factura,descripcion,porcentaje,monto) SELECT id_factura,'Bonificación comercial',NULL,2000.00 FROM dbo.FACTURAS WHERE numero_factura='F-0001-00000001';
IF NOT EXISTS (SELECT 1 FROM dbo.RECARGOS_FACTURA r JOIN dbo.FACTURAS f ON f.id_factura=r.id_factura WHERE f.numero_factura='F-0001-00000003' AND r.descripcion='Recargo por financiación') INSERT INTO dbo.RECARGOS_FACTURA(id_factura,descripcion,porcentaje,monto) SELECT id_factura,'Recargo por financiación',NULL,15000.00 FROM dbo.FACTURAS WHERE numero_factura='F-0001-00000003';

/* Actualización de totales */
UPDATE f
SET total_neto=ISNULL(t.total_neto,0),
    total_impuestos=ISNULL(t.total_impuestos,0),
    total_descuentos=ISNULL(d.total_descuentos,0),
    total_recargos=ISNULL(r.total_recargos,0),
    total=ISNULL(t.total_neto,0)+ISNULL(t.total_impuestos,0)-ISNULL(d.total_descuentos,0)+ISNULL(r.total_recargos,0)
FROM dbo.FACTURAS f
OUTER APPLY (SELECT SUM(subtotal_neto) total_neto, SUM(importe_impuesto) total_impuestos FROM dbo.DETALLES_FACTURA df WHERE df.id_factura=f.id_factura) t
OUTER APPLY (SELECT SUM(monto) total_descuentos FROM dbo.DESCUENTOS_FACTURA x WHERE x.id_factura=f.id_factura) d
OUTER APPLY (SELECT SUM(monto) total_recargos FROM dbo.RECARGOS_FACTURA x WHERE x.id_factura=f.id_factura) r;

/* Comprobantes de pago 1 a 1 */
IF NOT EXISTS (SELECT 1 FROM dbo.COMPROBANTES_PAGO cp JOIN dbo.FACTURAS f ON f.id_factura=cp.id_factura WHERE f.numero_factura='F-0001-00000001') INSERT INTO dbo.COMPROBANTES_PAGO(id_factura,id_forma_pago,fecha_pago,monto,numero_referencia,observaciones) SELECT f.id_factura,fp.id_forma_pago,'2026-06-06T10:20:00',f.total,'TR-0001','Comprobante único asociado a la factura.' FROM dbo.FACTURAS f CROSS JOIN dbo.FORMAS_PAGO fp WHERE f.numero_factura='F-0001-00000001' AND fp.forma_pago='Transferencia';
IF NOT EXISTS (SELECT 1 FROM dbo.COMPROBANTES_PAGO cp JOIN dbo.FACTURAS f ON f.id_factura=cp.id_factura WHERE f.numero_factura='F-0001-00000002') INSERT INTO dbo.COMPROBANTES_PAGO(id_factura,id_forma_pago,fecha_pago,monto,numero_referencia,observaciones) SELECT f.id_factura,fp.id_forma_pago,'2026-06-07T11:45:00',f.total,'EF-0002','Comprobante único asociado a la factura.' FROM dbo.FACTURAS f CROSS JOIN dbo.FORMAS_PAGO fp WHERE f.numero_factura='F-0001-00000002' AND fp.forma_pago='Efectivo';
IF NOT EXISTS (SELECT 1 FROM dbo.COMPROBANTES_PAGO cp JOIN dbo.FACTURAS f ON f.id_factura=cp.id_factura WHERE f.numero_factura='F-0001-00000003') INSERT INTO dbo.COMPROBANTES_PAGO(id_factura,id_forma_pago,fecha_pago,monto,numero_referencia,observaciones) SELECT f.id_factura,fp.id_forma_pago,'2026-06-08T12:30:00',f.total,'TC-0003','Comprobante único asociado a la factura.' FROM dbo.FACTURAS f CROSS JOIN dbo.FORMAS_PAGO fp WHERE f.numero_factura='F-0001-00000003' AND fp.forma_pago='Tarjeta Crédito';

/* Auditoría */
IF NOT EXISTS (SELECT 1 FROM dbo.AUDITORIA_FACTURA a JOIN dbo.FACTURAS f ON f.id_factura=a.id_factura WHERE f.numero_factura='F-0001-00000001' AND a.accion='EMISION') INSERT INTO dbo.AUDITORIA_FACTURA(id_factura,id_usuario,accion,fecha,detalle) SELECT f.id_factura,u.id_usuario,'EMISION','2026-06-06T10:00:00','Emisión de factura de prueba.' FROM dbo.FACTURAS f CROSS JOIN dbo.USUARIOS u WHERE f.numero_factura='F-0001-00000001' AND u.nombre_usuario='vendedor1';
IF NOT EXISTS (SELECT 1 FROM dbo.AUDITORIA_FACTURA a JOIN dbo.FACTURAS f ON f.id_factura=a.id_factura WHERE f.numero_factura='F-0001-00000003' AND a.accion='PAGO') INSERT INTO dbo.AUDITORIA_FACTURA(id_factura,id_usuario,accion,fecha,detalle) SELECT f.id_factura,u.id_usuario,'PAGO','2026-06-08T12:30:00','Registro de comprobante de pago.' FROM dbo.FACTURAS f CROSS JOIN dbo.USUARIOS u WHERE f.numero_factura='F-0001-00000003' AND u.nombre_usuario='vendedor2';

COMMIT TRANSACTION;
PRINT 'Datos de prueba insertados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error al insertar datos de prueba.';
    THROW;
END CATCH;
GO
