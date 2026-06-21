/* ============================================================
   01_sp_clientes.sql
   Proyecto Integrador BDD - PyME Generica
   Bloque: 05_CRUD / 05_Stored_Procedures

   Procedimientos incluidos:
   - dbo.usp_Clientes_Insertar
   - dbo.usp_Clientes_Seleccionar
   - dbo.usp_Clientes_Actualizar
   - dbo.usp_Clientes_Eliminar_Logico
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Clientes_Insertar
    @id_localidad INT,
    @id_tipo_cliente INT,
    @id_tipo_documento INT,
    @tipo_persona CHAR(1),
    @numero_documento VARCHAR(11),
    @nombre VARCHAR(80) = NULL,
    @apellido VARCHAR(80) = NULL,
    @razon_social VARCHAR(150) = NULL,
    @direccion VARCHAR(150) = NULL,
    @telefono VARCHAR(30) = NULL,
    @email VARCHAR(100) = NULL,
    @id_estado_cliente INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET @numero_documento = NULLIF(LTRIM(RTRIM(@numero_documento)), '');
        SET @tipo_persona = UPPER(LTRIM(RTRIM(@tipo_persona)));

        IF @id_estado_cliente IS NULL
        BEGIN
            SELECT @id_estado_cliente = id_estado_cliente
            FROM dbo.ESTADOS_CLIENTES
            WHERE estado = 'Activo';
        END;

        IF @numero_documento IS NULL
            THROW 61001, 'El numero_documento es obligatorio.', 1;

        IF @tipo_persona NOT IN ('F', 'J')
            THROW 61002, 'El tipo_persona debe ser F o J.', 1;

        IF @tipo_persona = 'F'
           AND
           (
                NULLIF(LTRIM(RTRIM(ISNULL(@nombre, ''))), '') IS NULL
                OR NULLIF(LTRIM(RTRIM(ISNULL(@apellido, ''))), '') IS NULL
                OR @razon_social IS NOT NULL
           )
            THROW 61003, 'Para persona fisica se requiere nombre y apellido, y razon_social debe ser NULL.', 1;

        IF @tipo_persona = 'J'
           AND
           (
                NULLIF(LTRIM(RTRIM(ISNULL(@razon_social, ''))), '') IS NULL
                OR @nombre IS NOT NULL
                OR @apellido IS NOT NULL
           )
            THROW 61004, 'Para persona juridica se requiere razon_social, y nombre/apellido deben ser NULL.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE id_localidad = @id_localidad)
            THROW 61005, 'La localidad indicada no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE id_tipo_cliente = @id_tipo_cliente)
            THROW 61006, 'El tipo de cliente indicado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_DOCUMENTO WHERE id_tipo_documento = @id_tipo_documento)
            THROW 61007, 'El tipo de documento indicado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_CLIENTES WHERE id_estado_cliente = @id_estado_cliente)
            THROW 61008, 'El estado de cliente indicado no existe.', 1;

        IF EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE numero_documento = @numero_documento)
            THROW 61009, 'Ya existe un cliente con ese numero_documento.', 1;

        BEGIN TRANSACTION;

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
            @tipo_persona,
            @numero_documento,
            @nombre,
            @apellido,
            @razon_social,
            @direccion,
            @telefono,
            @email
        );

        DECLARE @id_cliente_nuevo INT = CONVERT(INT, SCOPE_IDENTITY());

        COMMIT TRANSACTION;

        EXEC dbo.usp_Clientes_Seleccionar @id_cliente = @id_cliente_nuevo;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Clientes_Seleccionar
    @id_cliente INT = NULL,
    @numero_documento VARCHAR(11) = NULL,
    @texto VARCHAR(150) = NULL,
    @solo_activos BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id_cliente,
        c.tipo_persona,
        c.numero_documento,
        c.nombre,
        c.apellido,
        c.razon_social,
        c.direccion,
        c.telefono,
        c.email,
        tc.tipo AS tipo_cliente,
        td.tipo AS tipo_documento,
        ec.estado AS estado_cliente,
        l.nombre AS localidad,
        l.codigo_postal,
        p.nombre AS provincia
    FROM dbo.CLIENTES c
    INNER JOIN dbo.TIPOS_CLIENTE tc
        ON c.id_tipo_cliente = tc.id_tipo_cliente
    INNER JOIN dbo.TIPOS_DOCUMENTO td
        ON c.id_tipo_documento = td.id_tipo_documento
    INNER JOIN dbo.ESTADOS_CLIENTES ec
        ON c.id_estado_cliente = ec.id_estado_cliente
    INNER JOIN dbo.LOCALIDADES l
        ON c.id_localidad = l.id_localidad
    INNER JOIN dbo.PROVINCIAS p
        ON l.id_provincia = p.id_provincia
    WHERE
        (@id_cliente IS NULL OR c.id_cliente = @id_cliente)
        AND (@numero_documento IS NULL OR c.numero_documento = @numero_documento)
        AND
        (
            @texto IS NULL
            OR c.nombre LIKE '%' + @texto + '%'
            OR c.apellido LIKE '%' + @texto + '%'
            OR c.razon_social LIKE '%' + @texto + '%'
            OR c.email LIKE '%' + @texto + '%'
            OR c.numero_documento LIKE '%' + @texto + '%'
        )
        AND (@solo_activos = 0 OR ec.estado = 'Activo')
    ORDER BY c.id_cliente;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Clientes_Actualizar
    @id_cliente INT,
    @id_localidad INT = NULL,
    @id_tipo_cliente INT = NULL,
    @id_tipo_documento INT = NULL,
    @id_estado_cliente INT = NULL,
    @tipo_persona CHAR(1) = NULL,
    @numero_documento VARCHAR(11) = NULL,
    @nombre VARCHAR(80) = NULL,
    @apellido VARCHAR(80) = NULL,
    @razon_social VARCHAR(150) = NULL,
    @direccion VARCHAR(150) = NULL,
    @telefono VARCHAR(30) = NULL,
    @email VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE id_cliente = @id_cliente)
            THROW 61010, 'El cliente indicado no existe.', 1;

        DECLARE
            @id_localidad_final INT,
            @id_tipo_cliente_final INT,
            @id_tipo_documento_final INT,
            @id_estado_cliente_final INT,
            @tipo_persona_final CHAR(1),
            @numero_documento_final VARCHAR(11),
            @nombre_final VARCHAR(80),
            @apellido_final VARCHAR(80),
            @razon_social_final VARCHAR(150),
            @direccion_final VARCHAR(150),
            @telefono_final VARCHAR(30),
            @email_final VARCHAR(100);

        SELECT
            @id_localidad_final = COALESCE(@id_localidad, id_localidad),
            @id_tipo_cliente_final = COALESCE(@id_tipo_cliente, id_tipo_cliente),
            @id_tipo_documento_final = COALESCE(@id_tipo_documento, id_tipo_documento),
            @id_estado_cliente_final = COALESCE(@id_estado_cliente, id_estado_cliente),
            @tipo_persona_final = COALESCE(UPPER(LTRIM(RTRIM(@tipo_persona))), tipo_persona),
            @numero_documento_final = COALESCE(NULLIF(LTRIM(RTRIM(@numero_documento)), ''), numero_documento),
            @nombre_final = COALESCE(@nombre, nombre),
            @apellido_final = COALESCE(@apellido, apellido),
            @razon_social_final = COALESCE(@razon_social, razon_social),
            @direccion_final = COALESCE(@direccion, direccion),
            @telefono_final = COALESCE(@telefono, telefono),
            @email_final = COALESCE(@email, email)
        FROM dbo.CLIENTES
        WHERE id_cliente = @id_cliente;

        IF @tipo_persona_final NOT IN ('F', 'J')
            THROW 61011, 'El tipo_persona debe ser F o J.', 1;

        IF @tipo_persona_final = 'F'
        BEGIN
            SET @razon_social_final = NULL;

            IF NULLIF(LTRIM(RTRIM(ISNULL(@nombre_final, ''))), '') IS NULL
               OR NULLIF(LTRIM(RTRIM(ISNULL(@apellido_final, ''))), '') IS NULL
                THROW 61012, 'Para persona fisica se requiere nombre y apellido.', 1;
        END;

        IF @tipo_persona_final = 'J'
        BEGIN
            SET @nombre_final = NULL;
            SET @apellido_final = NULL;

            IF NULLIF(LTRIM(RTRIM(ISNULL(@razon_social_final, ''))), '') IS NULL
                THROW 61013, 'Para persona juridica se requiere razon_social.', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM dbo.LOCALIDADES WHERE id_localidad = @id_localidad_final)
            THROW 61014, 'La localidad indicada no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_CLIENTE WHERE id_tipo_cliente = @id_tipo_cliente_final)
            THROW 61015, 'El tipo de cliente indicado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.TIPOS_DOCUMENTO WHERE id_tipo_documento = @id_tipo_documento_final)
            THROW 61016, 'El tipo de documento indicado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.ESTADOS_CLIENTES WHERE id_estado_cliente = @id_estado_cliente_final)
            THROW 61017, 'El estado de cliente indicado no existe.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.CLIENTES
            WHERE numero_documento = @numero_documento_final
              AND id_cliente <> @id_cliente
        )
            THROW 61018, 'Ya existe otro cliente con ese numero_documento.', 1;

        BEGIN TRANSACTION;

        UPDATE dbo.CLIENTES
        SET
            id_localidad = @id_localidad_final,
            id_tipo_cliente = @id_tipo_cliente_final,
            id_tipo_documento = @id_tipo_documento_final,
            id_estado_cliente = @id_estado_cliente_final,
            tipo_persona = @tipo_persona_final,
            numero_documento = @numero_documento_final,
            nombre = @nombre_final,
            apellido = @apellido_final,
            razon_social = @razon_social_final,
            direccion = @direccion_final,
            telefono = @telefono_final,
            email = @email_final
        WHERE id_cliente = @id_cliente;

        COMMIT TRANSACTION;

        EXEC dbo.usp_Clientes_Seleccionar @id_cliente = @id_cliente;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Clientes_Eliminar_Logico
    @id_cliente INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        DECLARE @id_estado_inactivo INT;

        SELECT @id_estado_inactivo = id_estado_cliente
        FROM dbo.ESTADOS_CLIENTES
        WHERE estado = 'Inactivo';

        IF @id_estado_inactivo IS NULL
            THROW 61019, 'No existe el estado de cliente Inactivo.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTES WHERE id_cliente = @id_cliente)
            THROW 61020, 'El cliente indicado no existe.', 1;

        BEGIN TRANSACTION;

        UPDATE dbo.CLIENTES
        SET id_estado_cliente = @id_estado_inactivo
        WHERE id_cliente = @id_cliente;

        COMMIT TRANSACTION;

        EXEC dbo.usp_Clientes_Seleccionar @id_cliente = @id_cliente;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO
