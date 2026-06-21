/* ============================================================
   01_eliminar_indices_optimizacion.sql
   Proyecto Integrador BDD - PyME Generica

   Ubicacion:
   07_Pruebas_Optimizacion\Indices_y_Rendimiento

   Objetivo:
   Eliminar solamente los indices de rendimiento creados para
   pruebas de optimizacion.

   Importante:
   No elimina indices unicos filtrados del modelo fisico.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_estado_fecha' AND object_id = OBJECT_ID('dbo.FACTURAS'))
    DROP INDEX IX_FACTURAS_estado_fecha ON dbo.FACTURAS;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_cliente_estado' AND object_id = OBJECT_ID('dbo.FACTURAS'))
    DROP INDEX IX_FACTURAS_cliente_estado ON dbo.FACTURAS;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_usuario' AND object_id = OBJECT_ID('dbo.FACTURAS'))
    DROP INDEX IX_FACTURAS_usuario ON dbo.FACTURAS;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_tipo_factura' AND object_id = OBJECT_ID('dbo.FACTURAS'))
    DROP INDEX IX_FACTURAS_tipo_factura ON dbo.FACTURAS;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_tipo_operacion' AND object_id = OBJECT_ID('dbo.FACTURAS'))
    DROP INDEX IX_FACTURAS_tipo_operacion ON dbo.FACTURAS;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DETALLES_FACTURA_factura' AND object_id = OBJECT_ID('dbo.DETALLES_FACTURA'))
    DROP INDEX IX_DETALLES_FACTURA_factura ON dbo.DETALLES_FACTURA;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DETALLES_FACTURA_producto' AND object_id = OBJECT_ID('dbo.DETALLES_FACTURA'))
    DROP INDEX IX_DETALLES_FACTURA_producto ON dbo.DETALLES_FACTURA;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_COMPROBANTES_PAGO_forma_pago' AND object_id = OBJECT_ID('dbo.COMPROBANTES_PAGO'))
    DROP INDEX IX_COMPROBANTES_PAGO_forma_pago ON dbo.COMPROBANTES_PAGO;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_COMPROBANTES_PAGO_fecha' AND object_id = OBJECT_ID('dbo.COMPROBANTES_PAGO'))
    DROP INDEX IX_COMPROBANTES_PAGO_fecha ON dbo.COMPROBANTES_PAGO;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AUDITORIA_FACTURA_factura_fecha' AND object_id = OBJECT_ID('dbo.AUDITORIA_FACTURA'))
    DROP INDEX IX_AUDITORIA_FACTURA_factura_fecha ON dbo.AUDITORIA_FACTURA;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PRODUCTOS_SERVICIOS_categoria_activo' AND object_id = OBJECT_ID('dbo.PRODUCTOS_SERVICIOS'))
    DROP INDEX IX_PRODUCTOS_SERVICIOS_categoria_activo ON dbo.PRODUCTOS_SERVICIOS;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PRODUCTOS_SERVICIOS_impuesto' AND object_id = OBJECT_ID('dbo.PRODUCTOS_SERVICIOS'))
    DROP INDEX IX_PRODUCTOS_SERVICIOS_impuesto ON dbo.PRODUCTOS_SERVICIOS;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CLIENTES_localidad' AND object_id = OBJECT_ID('dbo.CLIENTES'))
    DROP INDEX IX_CLIENTES_localidad ON dbo.CLIENTES;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CLIENTES_tipo_cliente' AND object_id = OBJECT_ID('dbo.CLIENTES'))
    DROP INDEX IX_CLIENTES_tipo_cliente ON dbo.CLIENTES;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CLIENTES_estado' AND object_id = OBJECT_ID('dbo.CLIENTES'))
    DROP INDEX IX_CLIENTES_estado ON dbo.CLIENTES;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_LOCALIDADES_provincia' AND object_id = OBJECT_ID('dbo.LOCALIDADES'))
    DROP INDEX IX_LOCALIDADES_provincia ON dbo.LOCALIDADES;
GO

PRINT 'Indices de optimizacion eliminados correctamente.';
GO
