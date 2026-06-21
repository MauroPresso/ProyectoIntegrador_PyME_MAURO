/* ============================================================
   01_insert_clientes.sql
   Bloque: 05_CRUD / 01_Create_Insert

   Objetivo:
   - Insertar clientes de prueba para demostrar CREATE / INSERT.
   - Usar claves foraneas reales por busqueda en catalogos.
   - Evitar duplicados con IF NOT EXISTS.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

DECLARE
    @id_localidad INT,
    @id_tipo_cliente_consumidor_final INT,
    @id_tipo_cliente_responsable_inscripto INT,
    @id_tipo_documento_cuit INT,
    @id_estado_cliente_activo INT;

SELECT TOP 1 @id_localidad = id_localidad
FROM dbo.LOCALIDADES
ORDER BY id_localidad;

SELECT @id_tipo_cliente_consumidor_final = id_tipo_cliente
FROM dbo.TIPOS_CLIENTE
WHERE tipo = 'Consumidor Final';

SELECT @id_tipo_cliente_responsable_inscripto = id_tipo_cliente
FROM dbo.TIPOS_CLIENTE
WHERE tipo = 'Responsable Inscripto';

SELECT @id_tipo_documento_cuit = id_tipo_documento
FROM dbo.TIPOS_DOCUMENTO
WHERE tipo = 'CUIT';

SELECT @id_estado_cliente_activo = id_estado_cliente
FROM dbo.ESTADOS_CLIENTES
WHERE estado = 'Activo';

IF @id_localidad IS NULL
    THROW 60001, 'No existen localidades cargadas. Ejecutar primero los inserts del modelo fisico.', 1;

IF @id_tipo_cliente_consumidor_final IS NULL
    THROW 60002, 'No existe el tipo de cliente Consumidor Final.', 1;

IF @id_tipo_cliente_responsable_inscripto IS NULL
    THROW 60003, 'No existe el tipo de cliente Responsable Inscripto.', 1;

IF @id_tipo_documento_cuit IS NULL
    THROW 60004, 'No existe el tipo de documento CUIT.', 1;

IF @id_estado_cliente_activo IS NULL
    THROW 60005, 'No existe el estado de cliente Activo.', 1;

/* Cliente persona fisica */
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.CLIENTES
    WHERE numero_documento = '20999000111'
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
        @id_tipo_cliente_consumidor_final,
        @id_tipo_documento_cuit,
        @id_estado_cliente_activo,
        'F',
        '20999000111',
        'Cliente',
        'CRUD Fisico',
        NULL,
        'Calle CRUD 123',
        '2990001111',
        'cliente.crud.fisico@mail.com'
    );
END;

/* Cliente persona juridica */
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.CLIENTES
    WHERE numero_documento = '30709990001'
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
        @id_tipo_cliente_responsable_inscripto,
        @id_tipo_documento_cuit,
        @id_estado_cliente_activo,
        'J',
        '30709990001',
        NULL,
        NULL,
        'Empresa CRUD SRL',
        'Av. CRUD 456',
        '2990002222',
        'empresa.crud@mail.com'
    );
END;

SELECT
    c.id_cliente,
    c.tipo_persona,
    c.numero_documento,
    c.nombre,
    c.apellido,
    c.razon_social,
    ec.estado AS estado_cliente,
    tc.tipo AS tipo_cliente,
    td.tipo AS tipo_documento,
    l.nombre AS localidad
FROM dbo.CLIENTES c
INNER JOIN dbo.ESTADOS_CLIENTES ec
    ON c.id_estado_cliente = ec.id_estado_cliente
INNER JOIN dbo.TIPOS_CLIENTE tc
    ON c.id_tipo_cliente = tc.id_tipo_cliente
INNER JOIN dbo.TIPOS_DOCUMENTO td
    ON c.id_tipo_documento = td.id_tipo_documento
INNER JOIN dbo.LOCALIDADES l
    ON c.id_localidad = l.id_localidad
WHERE c.numero_documento IN ('20999000111', '30709990001')
ORDER BY c.id_cliente;
GO
