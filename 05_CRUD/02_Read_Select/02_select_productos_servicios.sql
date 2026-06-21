/* ============================================================
   02_select_productos_servicios.sql
   Bloque: 05_CRUD / 02_Read_Select

   Objetivo:
   - Consultar productos/servicios con filtros.
   - Mostrar JOIN con categorias e impuestos.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

DECLARE
    @texto_busqueda VARCHAR(120) = 'CRUD',
    @solo_activos BIT = 0,
    @stock_minimo INT = 0;

SELECT
    ps.id_producto_servicio,
    ps.nombre,
    ps.descripcion,
    ps.precio_unitario_actual,
    ps.stock_actual,
    ps.activo,
    cp.nombre AS categoria,
    i.impuesto,
    i.porcentaje AS porcentaje_impuesto,
    ROUND(ps.precio_unitario_actual * (1 + i.porcentaje / 100), 2) AS precio_con_impuesto
FROM dbo.PRODUCTOS_SERVICIOS ps
INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
    ON ps.id_categoria = cp.id_categoria
INNER JOIN dbo.IMPUESTOS i
    ON ps.id_impuesto = i.id_impuesto
WHERE
    (
        @texto_busqueda IS NULL
        OR ps.nombre LIKE '%' + @texto_busqueda + '%'
        OR ps.descripcion LIKE '%' + @texto_busqueda + '%'
        OR cp.nombre LIKE '%' + @texto_busqueda + '%'
    )
    AND (@solo_activos = 0 OR ps.activo = 1)
    AND ps.stock_actual >= @stock_minimo
ORDER BY ps.nombre;
GO
