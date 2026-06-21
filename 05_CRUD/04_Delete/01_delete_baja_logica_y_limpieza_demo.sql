/* ============================================================
   01_DELETE_BAJA_LOGICA_Y_LIMPIEZA_DEMO.SQL
   Proyecto Integrador BDD - PyME Genérica
   Motor: SQL Server
   Base de datos: BaseDeDatos_PyME
   Ubicación sugerida:
   05_CRUD\04_Delete

   Objetivo:
   Demostrar operación DELETE del CRUD.

   Criterio aplicado:
   1. Baja lógica del cliente de demostración mediante cambio de estado.
   2. Eliminación física controlada únicamente de los datos creados
      por los scripts CRUD de demostración.

   Requisito previo recomendado:
   Haber ejecutado previamente:
   - 05_CRUD\01_Create_Insert\01_insert_cliente_producto_factura_demo.sql
   - opcionalmente 05_CRUD\03_Update\01_update_cliente_producto_factura_demo.sql
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @id_cliente INT;
    DECLARE @id_producto_servicio INT;
    DECLARE @id_factura INT;
    DECLARE @id_estado_cliente_inactivo INT;

    SELECT @id_cliente = id_cliente
    FROM dbo.CLIENTES
    WHERE numero_documento = '30999999999';

    SELECT @id_producto_servicio = id_producto_servicio
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Servicio de soporte técnico CRUD';

    SELECT @id_factura = id_factura
    FROM dbo.FACTURAS
    WHERE numero_factura = 'CRUD-0001';

    SELECT @id_estado_cliente_inactivo = id_estado_cliente
    FROM dbo.ESTADOS_CLIENTES
    WHERE estado = 'Inactivo';

    /* ============================================================
       1. Baja lógica del cliente demo
       ============================================================ */

    IF @id_cliente IS NOT NULL AND @id_estado_cliente_inactivo IS NOT NULL
    BEGIN
        UPDATE dbo.CLIENTES
        SET id_estado_cliente = @id_estado_cliente_inactivo
        WHERE id_cliente = @id_cliente;
    END

    /* ============================================================
       2. DELETE físico controlado de registros hijos
       Orden necesario por restricciones de clave foránea.
       ============================================================ */

    IF @id_factura IS NOT NULL
    BEGIN
        DELETE FROM dbo.COMPROBANTES_PAGO
        WHERE id_factura = @id_factura;

        DELETE FROM dbo.AUDITORIA_FACTURA
        WHERE id_factura = @id_factura;

        DELETE FROM dbo.DESCUENTOS_FACTURA
        WHERE id_factura = @id_factura;

        DELETE FROM dbo.RECARGOS_FACTURA
        WHERE id_factura = @id_factura;

        DELETE FROM dbo.DETALLES_FACTURA
        WHERE id_factura = @id_factura;

        DELETE FROM dbo.FACTURAS
        WHERE id_factura = @id_factura;
    END

    /* ============================================================
       3. DELETE físico del producto/servicio demo
       Solo se elimina si ya no está referenciado por detalles.
       ============================================================ */

    IF @id_producto_servicio IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM dbo.DETALLES_FACTURA
            WHERE id_producto_servicio = @id_producto_servicio
       )
    BEGIN
        DELETE FROM dbo.PRODUCTOS_SERVICIOS
        WHERE id_producto_servicio = @id_producto_servicio;
    END

    /* ============================================================
       4. DELETE físico del cliente demo
       Solo se elimina si ya no está referenciado por facturas.
       ============================================================ */

    IF @id_cliente IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM dbo.FACTURAS
            WHERE id_cliente = @id_cliente
       )
    BEGIN
        DELETE FROM dbo.CLIENTES
        WHERE id_cliente = @id_cliente;
    END

    COMMIT TRANSACTION;

    PRINT 'Script DELETE / baja lógica ejecutado correctamente.';

    SELECT
        'CLIENTE_DEMO' AS entidad,
        COUNT(*) AS registros_restantes
    FROM dbo.CLIENTES
    WHERE numero_documento = '30999999999'

    UNION ALL

    SELECT
        'PRODUCTO_SERVICIO_DEMO' AS entidad,
        COUNT(*) AS registros_restantes
    FROM dbo.PRODUCTOS_SERVICIOS
    WHERE nombre = 'Servicio de soporte técnico CRUD'

    UNION ALL

    SELECT
        'FACTURA_DEMO' AS entidad,
        COUNT(*) AS registros_restantes
    FROM dbo.FACTURAS
    WHERE numero_factura = 'CRUD-0001';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @mensaje_error NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @severidad INT = ERROR_SEVERITY();
    DECLARE @estado INT = ERROR_STATE();

    RAISERROR(@mensaje_error, @severidad, @estado);
END CATCH;
GO
