/* ============================================================
   SCRIPT 01 - CREAR TABLAS
   Proyecto Integrador BDD - PyME Genérica
   Motor: Microsoft SQL Server
   Base de datos: BaseDeDatos_PyME

   Descripción:
   Crea las tablas principales del modelo físico.
   El script es universal porque no usa rutas físicas locales.
   Además, verifica si cada tabla existe antes de crearla.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

/* ============================================================
   TABLA: ROLES
   ============================================================ */

IF OBJECT_ID(N'dbo.ROLES', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ROLES
    (
        id_rol INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(50) NOT NULL,
        descripcion VARCHAR(200) NULL,
        activo BIT NOT NULL CONSTRAINT DF_ROLES_activo DEFAULT (1),

        CONSTRAINT PK_ROLES 
            PRIMARY KEY (id_rol),

        CONSTRAINT UQ_ROLES_nombre 
            UNIQUE (nombre),

        CONSTRAINT CK_ROLES_nombre_no_vacio
            CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
    );

    PRINT 'Tabla dbo.ROLES creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.ROLES ya existe.';
END
GO

/* ============================================================
   TABLA: LOCALIDADES
   ============================================================ */

IF OBJECT_ID(N'dbo.LOCALIDADES', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LOCALIDADES
    (
        id_localidad INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        codigo_postal VARCHAR(20) NOT NULL,
        provincia VARCHAR(100) NOT NULL,

        CONSTRAINT PK_LOCALIDADES 
            PRIMARY KEY (id_localidad),

        CONSTRAINT UQ_LOCALIDADES_nombre_cp_provincia
            UNIQUE (nombre, codigo_postal, provincia),

        CONSTRAINT CK_LOCALIDADES_nombre_no_vacio
            CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),

        CONSTRAINT CK_LOCALIDADES_codigo_postal_no_vacio
            CHECK (LEN(LTRIM(RTRIM(codigo_postal))) > 0),

        CONSTRAINT CK_LOCALIDADES_provincia_no_vacia
            CHECK (LEN(LTRIM(RTRIM(provincia))) > 0)
    );

    PRINT 'Tabla dbo.LOCALIDADES creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.LOCALIDADES ya existe.';
END
GO

/* ============================================================
   TABLA: CATEGORIAS_PRODUCTO
   ============================================================ */

IF OBJECT_ID(N'dbo.CATEGORIAS_PRODUCTO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CATEGORIAS_PRODUCTO
    (
        id_categoria INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(200) NULL,
        activo BIT NOT NULL CONSTRAINT DF_CATEGORIAS_PRODUCTO_activo DEFAULT (1),

        CONSTRAINT PK_CATEGORIAS_PRODUCTO 
            PRIMARY KEY (id_categoria),

        CONSTRAINT UQ_CATEGORIAS_PRODUCTO_nombre
            UNIQUE (nombre),

        CONSTRAINT CK_CATEGORIAS_PRODUCTO_nombre_no_vacio
            CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
    );

    PRINT 'Tabla dbo.CATEGORIAS_PRODUCTO creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.CATEGORIAS_PRODUCTO ya existe.';
END
GO

/* ============================================================
   TABLA: FORMAS_PAGO
   ============================================================ */

IF OBJECT_ID(N'dbo.FORMAS_PAGO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FORMAS_PAGO
    (
        id_forma_pago INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(50) NOT NULL,
        descripcion VARCHAR(150) NULL,
        activo BIT NOT NULL CONSTRAINT DF_FORMAS_PAGO_activo DEFAULT (1),

        CONSTRAINT PK_FORMAS_PAGO 
            PRIMARY KEY (id_forma_pago),

        CONSTRAINT UQ_FORMAS_PAGO_nombre
            UNIQUE (nombre),

        CONSTRAINT CK_FORMAS_PAGO_nombre_no_vacio
            CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
    );

    PRINT 'Tabla dbo.FORMAS_PAGO creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.FORMAS_PAGO ya existe.';
END
GO

/* ============================================================
   TABLA: ESTADOS_FACTURA
   ============================================================ */

IF OBJECT_ID(N'dbo.ESTADOS_FACTURA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ESTADOS_FACTURA
    (
        id_estado_factura INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(50) NOT NULL,
        descripcion VARCHAR(150) NULL,

        CONSTRAINT PK_ESTADOS_FACTURA 
            PRIMARY KEY (id_estado_factura),

        CONSTRAINT UQ_ESTADOS_FACTURA_nombre
            UNIQUE (nombre),

        CONSTRAINT CK_ESTADOS_FACTURA_nombre_no_vacio
            CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
    );

    PRINT 'Tabla dbo.ESTADOS_FACTURA creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.ESTADOS_FACTURA ya existe.';
END
GO

/* ============================================================
   TABLA: USUARIOS
   Relación:
   ROLES 1 ---- N USUARIOS
   ============================================================ */

IF OBJECT_ID(N'dbo.USUARIOS', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.USUARIOS
    (
        id_usuario INT IDENTITY(1,1) NOT NULL,
        id_rol INT NOT NULL,
        nombre VARCHAR(80) NOT NULL,
        apellido VARCHAR(80) NOT NULL,
        email VARCHAR(100) NOT NULL,
        nombre_usuario VARCHAR(50) NOT NULL,
        clave_hash VARCHAR(255) NOT NULL,
        activo BIT NOT NULL CONSTRAINT DF_USUARIOS_activo DEFAULT (1),

        CONSTRAINT PK_USUARIOS 
            PRIMARY KEY (id_usuario),

        CONSTRAINT UQ_USUARIOS_email
            UNIQUE (email),

        CONSTRAINT UQ_USUARIOS_nombre_usuario
            UNIQUE (nombre_usuario),

        CONSTRAINT FK_USUARIOS_ROLES
            FOREIGN KEY (id_rol)
            REFERENCES dbo.ROLES(id_rol),

        CONSTRAINT CK_USUARIOS_nombre_no_vacio
            CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),

        CONSTRAINT CK_USUARIOS_apellido_no_vacio
            CHECK (LEN(LTRIM(RTRIM(apellido))) > 0),

        CONSTRAINT CK_USUARIOS_email_no_vacio
            CHECK (LEN(LTRIM(RTRIM(email))) > 0),

        CONSTRAINT CK_USUARIOS_nombre_usuario_no_vacio
            CHECK (LEN(LTRIM(RTRIM(nombre_usuario))) > 0),

        CONSTRAINT CK_USUARIOS_clave_hash_no_vacia
            CHECK (LEN(LTRIM(RTRIM(clave_hash))) > 0)
    );

    PRINT 'Tabla dbo.USUARIOS creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.USUARIOS ya existe.';
END
GO

/* ============================================================
   TABLA: CLIENTES
   Relación:
   LOCALIDADES 1 ---- N CLIENTES
   ============================================================ */

IF OBJECT_ID(N'dbo.CLIENTES', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CLIENTES
    (
        id_cliente INT IDENTITY(1,1) NOT NULL,
        id_localidad INT NOT NULL,
        nombre_razon_social VARCHAR(150) NOT NULL,
        documento_cuit VARCHAR(20) NOT NULL,
        direccion VARCHAR(150) NULL,
        telefono VARCHAR(30) NULL,
        email VARCHAR(100) NULL,
        activo BIT NOT NULL CONSTRAINT DF_CLIENTES_activo DEFAULT (1),

        CONSTRAINT PK_CLIENTES 
            PRIMARY KEY (id_cliente),

        CONSTRAINT UQ_CLIENTES_documento_cuit
            UNIQUE (documento_cuit),

        CONSTRAINT FK_CLIENTES_LOCALIDADES
            FOREIGN KEY (id_localidad)
            REFERENCES dbo.LOCALIDADES(id_localidad),

        CONSTRAINT CK_CLIENTES_nombre_razon_social_no_vacio
            CHECK (LEN(LTRIM(RTRIM(nombre_razon_social))) > 0),

        CONSTRAINT CK_CLIENTES_documento_cuit_no_vacio
            CHECK (LEN(LTRIM(RTRIM(documento_cuit))) > 0)
    );

    PRINT 'Tabla dbo.CLIENTES creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.CLIENTES ya existe.';
END
GO

/* ============================================================
   TABLA: PRODUCTOS_SERVICIOS
   Relación:
   CATEGORIAS_PRODUCTO 1 ---- N PRODUCTOS_SERVICIOS
   ============================================================ */

IF OBJECT_ID(N'dbo.PRODUCTOS_SERVICIOS', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PRODUCTOS_SERVICIOS
    (
        id_producto_servicio INT IDENTITY(1,1) NOT NULL,
        id_categoria INT NOT NULL,
        nombre VARCHAR(120) NOT NULL,
        descripcion VARCHAR(250) NULL,
        precio_unitario_actual DECIMAL(12,2) NOT NULL,
        activo BIT NOT NULL CONSTRAINT DF_PRODUCTOS_SERVICIOS_activo DEFAULT (1),

        CONSTRAINT PK_PRODUCTOS_SERVICIOS 
            PRIMARY KEY (id_producto_servicio),

        CONSTRAINT FK_PRODUCTOS_SERVICIOS_CATEGORIAS_PRODUCTO
            FOREIGN KEY (id_categoria)
            REFERENCES dbo.CATEGORIAS_PRODUCTO(id_categoria),

        CONSTRAINT CK_PRODUCTOS_SERVICIOS_nombre_no_vacio
            CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),

        CONSTRAINT CK_PRODUCTOS_SERVICIOS_precio_unitario_actual
            CHECK (precio_unitario_actual >= 0)
    );

    PRINT 'Tabla dbo.PRODUCTOS_SERVICIOS creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.PRODUCTOS_SERVICIOS ya existe.';
END
GO

/* ============================================================
   TABLA: FACTURAS
   Relaciones:
   CLIENTES 1 ---- N FACTURAS
   USUARIOS 1 ---- N FACTURAS
   FORMAS_PAGO 1 ---- N FACTURAS
   ESTADOS_FACTURA 1 ---- N FACTURAS
   ============================================================ */

IF OBJECT_ID(N'dbo.FACTURAS', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FACTURAS
    (
        id_factura INT IDENTITY(1,1) NOT NULL,
        id_cliente INT NOT NULL,
        id_usuario INT NOT NULL,
        id_forma_pago INT NOT NULL,
        id_estado_factura INT NOT NULL,
        numero_factura VARCHAR(30) NOT NULL,
        fecha_emision DATETIME NOT NULL CONSTRAINT DF_FACTURAS_fecha_emision DEFAULT (GETDATE()),
        total DECIMAL(12,2) NOT NULL CONSTRAINT DF_FACTURAS_total DEFAULT (0),
        observaciones VARCHAR(250) NULL,

        CONSTRAINT PK_FACTURAS 
            PRIMARY KEY (id_factura),

        CONSTRAINT UQ_FACTURAS_numero_factura
            UNIQUE (numero_factura),

        CONSTRAINT FK_FACTURAS_CLIENTES
            FOREIGN KEY (id_cliente)
            REFERENCES dbo.CLIENTES(id_cliente),

        CONSTRAINT FK_FACTURAS_USUARIOS
            FOREIGN KEY (id_usuario)
            REFERENCES dbo.USUARIOS(id_usuario),

        CONSTRAINT FK_FACTURAS_FORMAS_PAGO
            FOREIGN KEY (id_forma_pago)
            REFERENCES dbo.FORMAS_PAGO(id_forma_pago),

        CONSTRAINT FK_FACTURAS_ESTADOS_FACTURA
            FOREIGN KEY (id_estado_factura)
            REFERENCES dbo.ESTADOS_FACTURA(id_estado_factura),

        CONSTRAINT CK_FACTURAS_numero_factura_no_vacio
            CHECK (LEN(LTRIM(RTRIM(numero_factura))) > 0),

        CONSTRAINT CK_FACTURAS_total
            CHECK (total >= 0)
    );

    PRINT 'Tabla dbo.FACTURAS creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.FACTURAS ya existe.';
END
GO

/* ============================================================
   TABLA: DETALLES_FACTURA
   Relaciones:
   FACTURAS 1 ---- N DETALLES_FACTURA
   PRODUCTOS_SERVICIOS 1 ---- N DETALLES_FACTURA

   Nota:
   subtotal se define como columna calculada persistida.
   Esto evita inconsistencias, porque siempre será:
   cantidad * precio_unitario.
   ============================================================ */

IF OBJECT_ID(N'dbo.DETALLES_FACTURA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DETALLES_FACTURA
    (
        id_detalle_factura INT IDENTITY(1,1) NOT NULL,
        id_factura INT NOT NULL,
        id_producto_servicio INT NOT NULL,
        cantidad DECIMAL(12,2) NOT NULL,
        precio_unitario DECIMAL(12,2) NOT NULL,
        subtotal AS CAST(cantidad * precio_unitario AS DECIMAL(12,2)) PERSISTED,

        CONSTRAINT PK_DETALLES_FACTURA 
            PRIMARY KEY (id_detalle_factura),

        CONSTRAINT FK_DETALLES_FACTURA_FACTURAS
            FOREIGN KEY (id_factura)
            REFERENCES dbo.FACTURAS(id_factura),

        CONSTRAINT FK_DETALLES_FACTURA_PRODUCTOS_SERVICIOS
            FOREIGN KEY (id_producto_servicio)
            REFERENCES dbo.PRODUCTOS_SERVICIOS(id_producto_servicio),

        CONSTRAINT CK_DETALLES_FACTURA_cantidad
            CHECK (cantidad > 0),

        CONSTRAINT CK_DETALLES_FACTURA_precio_unitario
            CHECK (precio_unitario >= 0)
    );

    PRINT 'Tabla dbo.DETALLES_FACTURA creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.DETALLES_FACTURA ya existe.';
END
GO

/* ============================================================
   FIN DEL SCRIPT
   ============================================================ */

PRINT 'Proceso de creación de tablas finalizado.';
GO