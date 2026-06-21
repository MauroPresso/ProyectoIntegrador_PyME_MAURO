/* ============================================================
   02_update_productos_servicios.sql
   Bloque: 05_CRUD / 03_Update

   Objetivo:
   - Actualizar precio, descripcion y stock de productos/servicios.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

UPDATE dbo.PRODUCTOS_SERVICIOS
SET
    precio_unitario_actual = 195000.00,
    stock_actual = stock_actual + 5,
    descripcion = 'Producto de prueba CRUD con precio y stock actualizados.'
WHERE nombre = 'Monitor LED 24 CRUD';

UPDATE dbo.PRODUCTOS_SERVICIOS
SET
    precio_unitario_actual = 50000.00,
    descripcion = 'Servicio CRUD actualizado.'
WHERE nombre = 'Servicio Soporte Tecnico CRUD';

SELECT
    ps.id_producto_servicio,
    ps.nombre,
    ps.descripcion,
    ps.precio_unitario_actual,
    ps.stock_actual,
    ps.activo,
    cp.nombre AS categoria,
    i.impuesto
FROM dbo.PRODUCTOS_SERVICIOS ps
INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
    ON ps.id_categoria = cp.id_categoria
INNER JOIN dbo.IMPUESTOS i
    ON ps.id_impuesto = i.id_impuesto
WHERE ps.nombre IN ('Monitor LED 24 CRUD', 'Servicio Soporte Tecnico CRUD')
ORDER BY ps.id_producto_servicio;
GO
