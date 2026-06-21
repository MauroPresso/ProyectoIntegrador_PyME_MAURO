/* ============================================================
   02_insert_productos_servicios.sql
   Bloque: 05_CRUD / 01_Create_Insert

   Objetivo:
   - Insertar productos/servicios de prueba para demostrar CREATE / INSERT.
   - Usar claves foraneas reales por busqueda en catalogos.
   - Evitar duplicados con IF NOT EXISTS.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

DECLARE
    @id_categoria INT,
    @id_impuesto_iva_21 INT;

SELECT TOP 1 @id_categoria = id_categoria
FROM dbo.CATEGORIAS_PRODUCTO
WHERE activo = 1
ORDER BY id_categoria;

SELECT @id_impuesto_iva_21 = id_impuesto
FROM dbo.IMPUESTOS
WHERE impuesto = 'IVA 21%'
  AND activo = 1;

IF @id_categoria IS NULL
    THROW 60101, 'No existen categorias activas cargadas. Ejecutar primero los inserts del modelo fisico.', 1;

IF @id_impuesto_iva_21 IS NULL
    THROW 60102, 'No existe el impuesto IVA 21% activo.', 1;

/* Producto de prueba */
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Monitor LED 24 CRUD'
)
BEGIN
    INSERT INTO dbo.PRODUCTOS_SERVICIOS
    (
        id_categoria,
        id_impuesto,
        nombre,
        descripcion,
        precio_unitario_actual,
        stock_actual,
        activo
    )
    VALUES
    (
        @id_categoria,
        @id_impuesto_iva_21,
        'Monitor LED 24 CRUD',
        'Producto de prueba para operaciones CRUD.',
        185000.00,
        25,
        1
    );
END;

/* Servicio de prueba */
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Servicio Soporte Tecnico CRUD'
)
BEGIN
    INSERT INTO dbo.PRODUCTOS_SERVICIOS
    (
        id_categoria,
        id_impuesto,
        nombre,
        descripcion,
        precio_unitario_actual,
        stock_actual,
        activo
    )
    VALUES
    (
        @id_categoria,
        @id_impuesto_iva_21,
        'Servicio Soporte Tecnico CRUD',
        'Servicio de prueba para operaciones CRUD.',
        45000.00,
        100,
        1
    );
END;

SELECT
    ps.id_producto_servicio,
    ps.nombre,
    ps.descripcion,
    ps.precio_unitario_actual,
    ps.stock_actual,
    ps.activo,
    cp.nombre AS categoria,
    i.impuesto,
    i.porcentaje
FROM dbo.PRODUCTOS_SERVICIOS ps
INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
    ON ps.id_categoria = cp.id_categoria
INNER JOIN dbo.IMPUESTOS i
    ON ps.id_impuesto = i.id_impuesto
WHERE ps.nombre IN ('Monitor LED 24 CRUD', 'Servicio Soporte Tecnico CRUD')
ORDER BY ps.id_producto_servicio;
GO
