/* ============================================================
   01_select_clientes.sql
   Bloque: 05_CRUD / 02_Read_Select

   Objetivo:
   - Consultar clientes con filtros.
   - Mostrar JOINs contra catalogos y tablas geograficas.
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
    @texto_busqueda VARCHAR(150) = 'CRUD',
    @solo_activos BIT = 0;

SELECT
    c.id_cliente,
    c.tipo_persona,
    CASE
        WHEN c.tipo_persona = 'F'
            THEN c.nombre + ' ' + c.apellido
        ELSE c.razon_social
    END AS cliente,
    c.numero_documento,
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
    (
        @texto_busqueda IS NULL
        OR c.numero_documento LIKE '%' + @texto_busqueda + '%'
        OR c.nombre LIKE '%' + @texto_busqueda + '%'
        OR c.apellido LIKE '%' + @texto_busqueda + '%'
        OR c.razon_social LIKE '%' + @texto_busqueda + '%'
        OR c.email LIKE '%' + @texto_busqueda + '%'
    )
    AND (@solo_activos = 0 OR ec.estado = 'Activo')
ORDER BY c.id_cliente;
GO
