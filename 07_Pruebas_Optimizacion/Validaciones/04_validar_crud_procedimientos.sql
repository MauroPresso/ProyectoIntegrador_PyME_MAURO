/* ============================================================
   04_validar_crud_procedimientos.sql
   Proyecto Integrador BDD - PyME Generica

   Ubicacion:
   07_Pruebas_Optimizacion\Validaciones

   Objetivo:
   Validar que existan los procedimientos almacenados principales
   del bloque CRUD y reportes. Ejecuta solamente procedimientos
   de lectura/reporte. No modifica datos.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

DECLARE @procedimientos TABLE
(
    nombre_procedimiento SYSNAME NOT NULL
);

INSERT INTO @procedimientos (nombre_procedimiento)
VALUES
(N'dbo.usp_Clientes_Insertar'),
(N'dbo.usp_Clientes_Seleccionar'),
(N'dbo.usp_Clientes_Actualizar'),
(N'dbo.usp_Clientes_Eliminar_Logico'),
(N'dbo.usp_ProductosServicios_Insertar'),
(N'dbo.usp_ProductosServicios_Seleccionar'),
(N'dbo.usp_ProductosServicios_Actualizar'),
(N'dbo.usp_ProductosServicios_Ajustar_Stock'),
(N'dbo.usp_ProductosServicios_Eliminar_Logico'),
(N'dbo.usp_Facturas_Crear_Cabecera'),
(N'dbo.usp_Facturas_Recalcular_Totales'),
(N'dbo.usp_Facturas_Agregar_Detalle'),
(N'dbo.usp_Facturas_Registrar_Descuento'),
(N'dbo.usp_Facturas_Registrar_Recargo'),
(N'dbo.usp_Facturas_Registrar_Pago'),
(N'dbo.usp_Facturas_Anular'),
(N'dbo.usp_Facturas_Eliminar_Logico'),
(N'dbo.usp_Facturas_Seleccionar'),
(N'dbo.usp_Reportes_Total_Facturado_Mes'),
(N'dbo.usp_Reportes_Productos_Mas_Vendidos'),
(N'dbo.usp_Reportes_Clientes_Mas_Compras'),
(N'dbo.usp_Reportes_Facturas_Por_Estado');

PRINT '1) Validacion de existencia de procedimientos almacenados';

SELECT
    nombre_procedimiento,
    CASE
        WHEN OBJECT_ID(nombre_procedimiento, N'P') IS NULL THEN 'FALTA'
        ELSE 'OK'
    END AS estado_validacion
FROM @procedimientos
ORDER BY nombre_procedimiento;

IF EXISTS
(
    SELECT 1
    FROM @procedimientos
    WHERE OBJECT_ID(nombre_procedimiento, N'P') IS NULL
)
BEGIN
    THROW 70003, 'Faltan procedimientos almacenados esperados.', 1;
END;

PRINT '2) Ejecucion de procedimientos de lectura';

EXEC dbo.usp_Clientes_Seleccionar
    @solo_activos = 0;

EXEC dbo.usp_ProductosServicios_Seleccionar
    @solo_activos = 0;

EXEC dbo.usp_Facturas_Seleccionar;

EXEC dbo.usp_Reportes_Productos_Mas_Vendidos
    @top = 5;

EXEC dbo.usp_Reportes_Clientes_Mas_Compras
    @top = 5;

EXEC dbo.usp_Reportes_Facturas_Por_Estado;

DECLARE @anio_actual INT = YEAR(GETDATE());
DECLARE @mes_actual INT = MONTH(GETDATE());

EXEC dbo.usp_Reportes_Total_Facturado_Mes
    @anio = @anio_actual,
    @mes = @mes_actual;

PRINT 'Validacion de CRUD y procedimientos finalizada.';
GO
