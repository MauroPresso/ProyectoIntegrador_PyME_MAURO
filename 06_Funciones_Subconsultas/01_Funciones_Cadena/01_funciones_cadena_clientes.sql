/* ============================================================
   01_funciones_cadena_clientes.sql
   Bloque: 06_Funciones_Subconsultas / 01_Funciones_Cadena

   Objetivo:
   - Demostrar funciones de cadena solicitadas en la consigna:
     LTRIM y RTRIM.
   - Normalizar valores de texto para visualizacion y busqueda.
   - Mantener el script como consulta de solo lectura.

   Base de datos: BaseDeDatos_PyME
   Motor: SQL Server
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

PRINT '1) CLIENTES CON CAMPOS DE TEXTO LIMPIOS MEDIANTE LTRIM Y RTRIM';

SELECT
    c.id_cliente,
    c.tipo_persona,
    tc.tipo AS tipo_cliente,
    td.tipo AS tipo_documento,
    c.numero_documento AS numero_documento_original,
    LTRIM(RTRIM(c.numero_documento)) AS numero_documento_limpio,
    CASE
        WHEN c.tipo_persona = 'F' THEN
            LTRIM(RTRIM(COALESCE(c.nombre, ''))) + ' ' + LTRIM(RTRIM(COALESCE(c.apellido, '')))
        WHEN c.tipo_persona = 'J' THEN
            LTRIM(RTRIM(COALESCE(c.razon_social, '')))
    END AS cliente_limpio,
    LTRIM(RTRIM(COALESCE(c.direccion, ''))) AS direccion_limpia,
    LTRIM(RTRIM(COALESCE(c.telefono, ''))) AS telefono_limpio,
    LTRIM(RTRIM(COALESCE(c.email, ''))) AS email_limpio,
    LTRIM(RTRIM(l.nombre)) AS localidad_limpia,
    LTRIM(RTRIM(p.nombre)) AS provincia_limpia
FROM dbo.CLIENTES c
INNER JOIN dbo.TIPOS_CLIENTE tc
    ON c.id_tipo_cliente = tc.id_tipo_cliente
INNER JOIN dbo.TIPOS_DOCUMENTO td
    ON c.id_tipo_documento = td.id_tipo_documento
INNER JOIN dbo.LOCALIDADES l
    ON c.id_localidad = l.id_localidad
INNER JOIN dbo.PROVINCIAS p
    ON l.id_provincia = p.id_provincia
ORDER BY c.id_cliente;
GO

PRINT '2) CONTROL DE ESPACIOS SOBRANTES EN CLIENTES';

SELECT
    c.id_cliente,
    c.numero_documento,
    c.nombre,
    c.apellido,
    c.razon_social,
    c.email,
    LEN(COALESCE(c.nombre, '')) AS largo_nombre_original,
    LEN(LTRIM(RTRIM(COALESCE(c.nombre, '')))) AS largo_nombre_limpio,
    LEN(COALESCE(c.apellido, '')) AS largo_apellido_original,
    LEN(LTRIM(RTRIM(COALESCE(c.apellido, '')))) AS largo_apellido_limpio,
    LEN(COALESCE(c.razon_social, '')) AS largo_razon_social_original,
    LEN(LTRIM(RTRIM(COALESCE(c.razon_social, '')))) AS largo_razon_social_limpio,
    LEN(COALESCE(c.email, '')) AS largo_email_original,
    LEN(LTRIM(RTRIM(COALESCE(c.email, '')))) AS largo_email_limpio
FROM dbo.CLIENTES c
WHERE
    LEN(COALESCE(c.nombre, '')) <> LEN(LTRIM(RTRIM(COALESCE(c.nombre, ''))))
    OR LEN(COALESCE(c.apellido, '')) <> LEN(LTRIM(RTRIM(COALESCE(c.apellido, ''))))
    OR LEN(COALESCE(c.razon_social, '')) <> LEN(LTRIM(RTRIM(COALESCE(c.razon_social, ''))))
    OR LEN(COALESCE(c.email, '')) <> LEN(LTRIM(RTRIM(COALESCE(c.email, ''))))
ORDER BY c.id_cliente;
GO

PRINT '3) BUSQUEDA DE CLIENTES USANDO UNA VARIABLE LIMPIA CON LTRIM Y RTRIM';

DECLARE
    @texto_busqueda VARCHAR(100) = '   CRUD   ',
    @texto_busqueda_limpio VARCHAR(100);

SET @texto_busqueda_limpio = LTRIM(RTRIM(@texto_busqueda));

SELECT
    c.id_cliente,
    c.tipo_persona,
    c.numero_documento,
    CASE
        WHEN c.tipo_persona = 'F' THEN
            LTRIM(RTRIM(COALESCE(c.nombre, ''))) + ' ' + LTRIM(RTRIM(COALESCE(c.apellido, '')))
        WHEN c.tipo_persona = 'J' THEN
            LTRIM(RTRIM(COALESCE(c.razon_social, '')))
    END AS cliente_limpio,
    LTRIM(RTRIM(COALESCE(c.email, ''))) AS email_limpio
FROM dbo.CLIENTES c
WHERE
    LTRIM(RTRIM(COALESCE(c.nombre, ''))) LIKE '%' + @texto_busqueda_limpio + '%'
    OR LTRIM(RTRIM(COALESCE(c.apellido, ''))) LIKE '%' + @texto_busqueda_limpio + '%'
    OR LTRIM(RTRIM(COALESCE(c.razon_social, ''))) LIKE '%' + @texto_busqueda_limpio + '%'
    OR LTRIM(RTRIM(COALESCE(c.email, ''))) LIKE '%' + @texto_busqueda_limpio + '%'
ORDER BY c.id_cliente;
GO

PRINT '4) PRODUCTOS Y SERVICIOS CON NOMBRES LIMPIOS MEDIANTE LTRIM Y RTRIM';

SELECT
    ps.id_producto_servicio,
    ps.nombre AS nombre_original,
    LTRIM(RTRIM(ps.nombre)) AS nombre_limpio,
    ps.descripcion AS descripcion_original,
    LTRIM(RTRIM(COALESCE(ps.descripcion, ''))) AS descripcion_limpia,
    ps.precio_unitario_actual,
    ps.stock_actual,
    cp.nombre AS categoria_original,
    LTRIM(RTRIM(cp.nombre)) AS categoria_limpia
FROM dbo.PRODUCTOS_SERVICIOS ps
INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
    ON ps.id_categoria = cp.id_categoria
ORDER BY ps.id_producto_servicio;
GO

PRINT 'Script de funciones de cadena finalizado.';
GO
