/* ============================================================
   02_delete_productos_servicios.sql
   Bloque: 05_CRUD / 04_Delete

   Objetivo:
   - Demostrar baja logica de productos/servicios.
   - Demostrar DELETE fisico controlado sobre un producto temporal sin detalles de factura.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

DECLARE
    @id_categoria INT,
    @id_impuesto INT,
    @id_producto_temporal INT;

SELECT TOP 1 @id_categoria = id_categoria
FROM dbo.CATEGORIAS_PRODUCTO
WHERE activo = 1
ORDER BY id_categoria;

SELECT TOP 1 @id_impuesto = id_impuesto
FROM dbo.IMPUESTOS
WHERE activo = 1
ORDER BY id_impuesto;

/* 1) Baja logica de producto/servicio de negocio */
UPDATE dbo.PRODUCTOS_SERVICIOS
SET activo = 0
WHERE nombre = 'Servicio Soporte Tecnico CRUD';

/* 2) DELETE fisico controlado de producto temporal sin relaciones */
IF @id_categoria IS NOT NULL
   AND @id_impuesto IS NOT NULL
   AND NOT EXISTS
   (
       SELECT 1
       FROM dbo.PRODUCTOS_SERVICIOS
       WHERE nombre = 'Producto Temporal Delete CRUD'
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
        @id_impuesto,
        'Producto Temporal Delete CRUD',
        'Producto temporal creado solo para demostrar DELETE fisico.',
        1000.00,
        1,
        1
    );
END;

SELECT @id_producto_temporal = id_producto_servicio
FROM dbo.PRODUCTOS_SERVICIOS
WHERE nombre = 'Producto Temporal Delete CRUD';

DELETE FROM dbo.PRODUCTOS_SERVICIOS
WHERE id_producto_servicio = @id_producto_temporal
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.DETALLES_FACTURA
      WHERE id_producto_servicio = @id_producto_temporal
  );

SELECT
    ps.id_producto_servicio,
    ps.nombre,
    ps.precio_unitario_actual,
    ps.stock_actual,
    ps.activo
FROM dbo.PRODUCTOS_SERVICIOS ps
WHERE ps.nombre IN ('Servicio Soporte Tecnico CRUD', 'Producto Temporal Delete CRUD')
ORDER BY ps.id_producto_servicio;
GO
