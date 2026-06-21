/* ============================================================
   02_validar_tablas_principales.sql
   Proyecto Integrador BDD - PyME Generica

   Ubicacion:
   07_Pruebas_Optimizacion\Validaciones

   Objetivo:
   Validar que las tablas principales del modelo fisico existan,
   que tengan registros cargados y que no haya claves foraneas
   deshabilitadas o no confiables.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

DECLARE @tablas_esperadas TABLE
(
    nombre_tabla SYSNAME NOT NULL
);

INSERT INTO @tablas_esperadas (nombre_tabla)
VALUES
(N'dbo.PROVINCIAS'),
(N'dbo.LOCALIDADES'),
(N'dbo.TIPOS_CLIENTE'),
(N'dbo.TIPOS_DOCUMENTO'),
(N'dbo.ROLES'),
(N'dbo.ESTADOS_USUARIOS'),
(N'dbo.ESTADOS_CLIENTES'),
(N'dbo.CLIENTES'),
(N'dbo.USUARIOS'),
(N'dbo.FORMAS_PAGO'),
(N'dbo.ESTADOS_FACTURA'),
(N'dbo.TIPOS_FACTURA'),
(N'dbo.TIPOS_OPERACION_FACTURA'),
(N'dbo.CATEGORIAS_PRODUCTO'),
(N'dbo.IMPUESTOS'),
(N'dbo.PRODUCTOS_SERVICIOS'),
(N'dbo.FACTURAS'),
(N'dbo.DETALLES_FACTURA'),
(N'dbo.COMPROBANTES_PAGO'),
(N'dbo.AUDITORIA_FACTURA'),
(N'dbo.DESCUENTOS_FACTURA'),
(N'dbo.RECARGOS_FACTURA');

PRINT '1) Validacion de existencia de tablas principales';

SELECT
    nombre_tabla,
    CASE
        WHEN OBJECT_ID(nombre_tabla, N'U') IS NULL THEN 'FALTA'
        ELSE 'OK'
    END AS estado_validacion
FROM @tablas_esperadas
ORDER BY nombre_tabla;

IF EXISTS
(
    SELECT 1
    FROM @tablas_esperadas
    WHERE OBJECT_ID(nombre_tabla, N'U') IS NULL
)
BEGIN
    THROW 70001, 'Faltan tablas principales del modelo fisico.', 1;
END;

PRINT '2) Cantidad de registros por tabla';

SELECT
    s.name + '.' + t.name AS tabla,
    SUM(p.rows) AS cantidad_registros
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
INNER JOIN sys.partitions p
    ON t.object_id = p.object_id
WHERE
    p.index_id IN (0, 1)
    AND s.name + '.' + t.name IN
    (
        SELECT nombre_tabla
        FROM @tablas_esperadas
    )
GROUP BY
    s.name,
    t.name
ORDER BY
    tabla;

PRINT '3) Validacion de claves foraneas';

SELECT
    fk.name AS clave_foranea,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) + '.' + OBJECT_NAME(fk.parent_object_id) AS tabla_origen,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) + '.' + OBJECT_NAME(fk.referenced_object_id) AS tabla_referenciada,
    fk.is_disabled,
    fk.is_not_trusted
FROM sys.foreign_keys fk
WHERE
    fk.is_disabled = 1
    OR fk.is_not_trusted = 1
ORDER BY
    tabla_origen,
    clave_foranea;

IF EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE is_disabled = 1 OR is_not_trusted = 1
)
BEGIN
    THROW 70002, 'Existen claves foraneas deshabilitadas o no confiables.', 1;
END;

PRINT 'Validacion de tablas principales finalizada correctamente.';
GO
