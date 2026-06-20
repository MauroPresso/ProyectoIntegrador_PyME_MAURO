/* ============================================================
   RESTRICCIONES_INDICES.SQL
   Ubicación: 04_SQLServer_Modelo_Fisico\03_Restricciones
   ============================================================ */
USE BaseDeDatos_PyME;
GO
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CATEGORIAS_PRODUCTO_nombre_activo' AND object_id=OBJECT_ID('dbo.CATEGORIAS_PRODUCTO'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IX_CATEGORIAS_PRODUCTO_nombre_activo
    ON dbo.CATEGORIAS_PRODUCTO(nombre) WHERE activo = 1;
    PRINT 'Índice único filtrado de categorías creado.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PRODUCTOS_SERVICIOS_nombre_activo' AND object_id=OBJECT_ID('dbo.PRODUCTOS_SERVICIOS'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IX_PRODUCTOS_SERVICIOS_nombre_activo
    ON dbo.PRODUCTOS_SERVICIOS(nombre) WHERE activo = 1;
    PRINT 'Índice único filtrado de productos/servicios creado.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_FORMAS_PAGO_forma_pago_activo' AND object_id=OBJECT_ID('dbo.FORMAS_PAGO'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IX_FORMAS_PAGO_forma_pago_activo
    ON dbo.FORMAS_PAGO(forma_pago) WHERE activo = 1;
    PRINT 'Índice único filtrado de formas de pago creado.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IMPUESTOS_impuesto_activo' AND object_id=OBJECT_ID('dbo.IMPUESTOS'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IX_IMPUESTOS_impuesto_activo
    ON dbo.IMPUESTOS(impuesto) WHERE activo = 1;
    PRINT 'Índice único filtrado de impuestos creado.';
END
GO

PRINT 'Restricciones complementarias creadas correctamente.';
GO
