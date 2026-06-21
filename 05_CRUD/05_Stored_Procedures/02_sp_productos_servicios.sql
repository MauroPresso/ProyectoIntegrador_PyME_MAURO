/* ============================================================
   02_sp_productos_servicios.sql
   Proyecto Integrador BDD - PyME Generica
   Bloque: 05_CRUD / 05_Stored_Procedures

   Procedimientos incluidos:
   - dbo.usp_ProductosServicios_Insertar
   - dbo.usp_ProductosServicios_Seleccionar
   - dbo.usp_ProductosServicios_Actualizar
   - dbo.usp_ProductosServicios_Ajustar_Stock
   - dbo.usp_ProductosServicios_Eliminar_Logico
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

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ProductosServicios_Insertar
    @id_categoria INT,
    @id_impuesto INT,
    @nombre VARCHAR(120),
    @descripcion VARCHAR(250) = NULL,
    @precio_unitario_actual DECIMAL(12,2),
    @stock_actual INT = 0,
    @activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET @nombre = NULLIF(LTRIM(RTRIM(@nombre)), '');

        IF @nombre IS NULL
            THROW 62001, 'El nombre del producto/servicio es obligatorio.', 1;

        IF @precio_unitario_actual < 0
            THROW 62002, 'El precio_unitario_actual no puede ser negativo.', 1;

        IF @stock_actual < 0
            THROW 62003, 'El stock_actual no puede ser negativo.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE id_categoria = @id_categoria)
            THROW 62004, 'La categoria indicada no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.IMPUESTOS WHERE id_impuesto = @id_impuesto)
            THROW 62005, 'El impuesto indicado no existe.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.PRODUCTOS_SERVICIOS
            WHERE nombre = @nombre
              AND activo = 1
        )
            THROW 62006, 'Ya existe un producto/servicio activo con ese nombre.', 1;

        BEGIN TRANSACTION;

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
            @nombre,
            @descripcion,
            @precio_unitario_actual,
            @stock_actual,
            @activo
        );

        DECLARE @id_producto_servicio_nuevo INT = CONVERT(INT, SCOPE_IDENTITY());

        COMMIT TRANSACTION;

        EXEC dbo.usp_ProductosServicios_Seleccionar
            @id_producto_servicio = @id_producto_servicio_nuevo;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ProductosServicios_Seleccionar
    @id_producto_servicio INT = NULL,
    @id_categoria INT = NULL,
    @texto VARCHAR(120) = NULL,
    @solo_activos BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ps.id_producto_servicio,
        ps.nombre,
        ps.descripcion,
        ps.precio_unitario_actual,
        ps.stock_actual,
        ps.activo,
        cp.id_categoria,
        cp.nombre AS categoria,
        i.id_impuesto,
        i.impuesto,
        i.porcentaje AS porcentaje_impuesto
    FROM dbo.PRODUCTOS_SERVICIOS ps
    INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
        ON ps.id_categoria = cp.id_categoria
    INNER JOIN dbo.IMPUESTOS i
        ON ps.id_impuesto = i.id_impuesto
    WHERE
        (@id_producto_servicio IS NULL OR ps.id_producto_servicio = @id_producto_servicio)
        AND (@id_categoria IS NULL OR ps.id_categoria = @id_categoria)
        AND
        (
            @texto IS NULL
            OR ps.nombre LIKE '%' + @texto + '%'
            OR ps.descripcion LIKE '%' + @texto + '%'
            OR cp.nombre LIKE '%' + @texto + '%'
        )
        AND (@solo_activos = 0 OR ps.activo = 1)
    ORDER BY ps.id_producto_servicio;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ProductosServicios_Actualizar
    @id_producto_servicio INT,
    @id_categoria INT = NULL,
    @id_impuesto INT = NULL,
    @nombre VARCHAR(120) = NULL,
    @descripcion VARCHAR(250) = NULL,
    @precio_unitario_actual DECIMAL(12,2) = NULL,
    @stock_actual INT = NULL,
    @activo BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.PRODUCTOS_SERVICIOS
            WHERE id_producto_servicio = @id_producto_servicio
        )
            THROW 62007, 'El producto/servicio indicado no existe.', 1;

        DECLARE
            @id_categoria_final INT,
            @id_impuesto_final INT,
            @nombre_final VARCHAR(120),
            @descripcion_final VARCHAR(250),
            @precio_final DECIMAL(12,2),
            @stock_final INT,
            @activo_final BIT;

        SELECT
            @id_categoria_final = COALESCE(@id_categoria, id_categoria),
            @id_impuesto_final = COALESCE(@id_impuesto, id_impuesto),
            @nombre_final = COALESCE(NULLIF(LTRIM(RTRIM(@nombre)), ''), nombre),
            @descripcion_final = COALESCE(@descripcion, descripcion),
            @precio_final = COALESCE(@precio_unitario_actual, precio_unitario_actual),
            @stock_final = COALESCE(@stock_actual, stock_actual),
            @activo_final = COALESCE(@activo, activo)
        FROM dbo.PRODUCTOS_SERVICIOS
        WHERE id_producto_servicio = @id_producto_servicio;

        IF @precio_final < 0
            THROW 62008, 'El precio_unitario_actual no puede ser negativo.', 1;

        IF @stock_final < 0
            THROW 62009, 'El stock_actual no puede ser negativo.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIAS_PRODUCTO WHERE id_categoria = @id_categoria_final)
            THROW 62010, 'La categoria indicada no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.IMPUESTOS WHERE id_impuesto = @id_impuesto_final)
            THROW 62011, 'El impuesto indicado no existe.', 1;

        IF @activo_final = 1
           AND EXISTS
           (
               SELECT 1
               FROM dbo.PRODUCTOS_SERVICIOS
               WHERE nombre = @nombre_final
                 AND activo = 1
                 AND id_producto_servicio <> @id_producto_servicio
           )
            THROW 62012, 'Ya existe otro producto/servicio activo con ese nombre.', 1;

        BEGIN TRANSACTION;

        UPDATE dbo.PRODUCTOS_SERVICIOS
        SET
            id_categoria = @id_categoria_final,
            id_impuesto = @id_impuesto_final,
            nombre = @nombre_final,
            descripcion = @descripcion_final,
            precio_unitario_actual = @precio_final,
            stock_actual = @stock_final,
            activo = @activo_final
        WHERE id_producto_servicio = @id_producto_servicio;

        COMMIT TRANSACTION;

        EXEC dbo.usp_ProductosServicios_Seleccionar
            @id_producto_servicio = @id_producto_servicio;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ProductosServicios_Ajustar_Stock
    @id_producto_servicio INT,
    @movimiento_stock INT,
    @motivo VARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @movimiento_stock = 0
            THROW 62013, 'El movimiento de stock no puede ser cero.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.PRODUCTOS_SERVICIOS
            WHERE id_producto_servicio = @id_producto_servicio
        )
            THROW 62014, 'El producto/servicio indicado no existe.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.PRODUCTOS_SERVICIOS
            WHERE id_producto_servicio = @id_producto_servicio
              AND stock_actual + @movimiento_stock < 0
        )
            THROW 62015, 'El movimiento deja el stock en valor negativo.', 1;

        BEGIN TRANSACTION;

        UPDATE dbo.PRODUCTOS_SERVICIOS
        SET stock_actual = stock_actual + @movimiento_stock
        WHERE id_producto_servicio = @id_producto_servicio;

        COMMIT TRANSACTION;

        EXEC dbo.usp_ProductosServicios_Seleccionar
            @id_producto_servicio = @id_producto_servicio;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ProductosServicios_Eliminar_Logico
    @id_producto_servicio INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.PRODUCTOS_SERVICIOS
            WHERE id_producto_servicio = @id_producto_servicio
        )
            THROW 62016, 'El producto/servicio indicado no existe.', 1;

        BEGIN TRANSACTION;

        UPDATE dbo.PRODUCTOS_SERVICIOS
        SET activo = 0
        WHERE id_producto_servicio = @id_producto_servicio;

        COMMIT TRANSACTION;

        EXEC dbo.usp_ProductosServicios_Seleccionar
            @id_producto_servicio = @id_producto_servicio;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO
