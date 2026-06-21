/* ============================================================
   01_delete_clientes.sql
   Bloque: 05_CRUD / 04_Delete

   Objetivo:
   - Demostrar eliminacion logica de clientes de negocio.
   - Demostrar DELETE fisico controlado sobre un cliente temporal sin facturas.
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

DECLARE
    @id_estado_inactivo INT,
    @id_localidad INT,
    @id_tipo_cliente INT,
    @id_tipo_documento INT,
    @id_estado_activo INT,
    @id_cliente_temporal INT;

SELECT @id_estado_inactivo = id_estado_cliente
FROM dbo.ESTADOS_CLIENTES
WHERE estado = 'Inactivo';

SELECT @id_estado_activo = id_estado_cliente
FROM dbo.ESTADOS_CLIENTES
WHERE estado = 'Activo';

SELECT TOP 1 @id_localidad = id_localidad
FROM dbo.LOCALIDADES
ORDER BY id_localidad;

SELECT @id_tipo_cliente = id_tipo_cliente
FROM dbo.TIPOS_CLIENTE
WHERE tipo = 'Consumidor Final';

SELECT @id_tipo_documento = id_tipo_documento
FROM dbo.TIPOS_DOCUMENTO
WHERE tipo = 'CUIT';

IF @id_estado_inactivo IS NULL
    THROW 60401, 'No existe el estado de cliente Inactivo.', 1;

/* 1) Baja logica de cliente de negocio */
UPDATE dbo.CLIENTES
SET id_estado_cliente = @id_estado_inactivo
WHERE numero_documento = '30709990001';

/* 2) DELETE fisico controlado de cliente temporal sin relaciones */
IF @id_localidad IS NOT NULL
   AND @id_tipo_cliente IS NOT NULL
   AND @id_tipo_documento IS NOT NULL
   AND @id_estado_activo IS NOT NULL
   AND NOT EXISTS
   (
       SELECT 1
       FROM dbo.CLIENTES
       WHERE numero_documento = '20999000999'
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
        @id_estado_activo,
        'F',
        '20999000999',
        'Temporal',
        'Delete',
        NULL,
        'Temporal 1',
        '2999999999',
        'temporal.delete@mail.com'
    );
END;

SELECT @id_cliente_temporal = id_cliente
FROM dbo.CLIENTES
WHERE numero_documento = '20999000999';

DELETE FROM dbo.CLIENTES
WHERE id_cliente = @id_cliente_temporal
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.FACTURAS
      WHERE id_cliente = @id_cliente_temporal
  );

SELECT
    c.id_cliente,
    c.numero_documento,
    c.nombre,
    c.apellido,
    c.razon_social,
    ec.estado AS estado_cliente
FROM dbo.CLIENTES c
INNER JOIN dbo.ESTADOS_CLIENTES ec
    ON c.id_estado_cliente = ec.id_estado_cliente
WHERE c.numero_documento IN ('30709990001', '20999000999')
ORDER BY c.id_cliente;
GO
