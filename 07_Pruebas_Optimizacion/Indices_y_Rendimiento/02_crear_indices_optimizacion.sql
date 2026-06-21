/* ============================================================
   02_crear_indices_optimizacion.sql
   Proyecto Integrador BDD - PyME Generica

   Ubicacion:
   07_Pruebas_Optimizacion\Indices_y_Rendimiento

   Objetivo:
   Crear indices no clusterizados para optimizar consultas,
   joins, filtros por estado, fecha, cliente, producto y forma
   de pago.

   Importante:
   Estos indices son de rendimiento. No reemplazan claves
   primarias, claves foraneas ni restricciones del modelo fisico.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_estado_fecha' AND object_id = OBJECT_ID('dbo.FACTURAS'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURAS_estado_fecha
    ON dbo.FACTURAS (id_estado_factura, fecha_emision)
    INCLUDE (total_neto, total_impuestos, total_descuentos, total_recargos, total);

    PRINT 'Indice IX_FACTURAS_estado_fecha creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_cliente_estado' AND object_id = OBJECT_ID('dbo.FACTURAS'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURAS_cliente_estado
    ON dbo.FACTURAS (id_cliente, id_estado_factura)
    INCLUDE (fecha_emision, total);

    PRINT 'Indice IX_FACTURAS_cliente_estado creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_usuario' AND object_id = OBJECT_ID('dbo.FACTURAS'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURAS_usuario
    ON dbo.FACTURAS (id_usuario);

    PRINT 'Indice IX_FACTURAS_usuario creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_tipo_factura' AND object_id = OBJECT_ID('dbo.FACTURAS'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURAS_tipo_factura
    ON dbo.FACTURAS (id_tipo_factura);

    PRINT 'Indice IX_FACTURAS_tipo_factura creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACTURAS_tipo_operacion' AND object_id = OBJECT_ID('dbo.FACTURAS'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FACTURAS_tipo_operacion
    ON dbo.FACTURAS (id_tipo_operacion_factura);

    PRINT 'Indice IX_FACTURAS_tipo_operacion creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DETALLES_FACTURA_factura' AND object_id = OBJECT_ID('dbo.DETALLES_FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DETALLES_FACTURA_factura
    ON dbo.DETALLES_FACTURA (id_factura)
    INCLUDE (cantidad, subtotal_neto, importe_impuesto, subtotal_con_impuesto);

    PRINT 'Indice IX_DETALLES_FACTURA_factura creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DETALLES_FACTURA_producto' AND object_id = OBJECT_ID('dbo.DETALLES_FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DETALLES_FACTURA_producto
    ON dbo.DETALLES_FACTURA (id_producto_servicio)
    INCLUDE (cantidad, subtotal_neto, importe_impuesto, subtotal_con_impuesto);

    PRINT 'Indice IX_DETALLES_FACTURA_producto creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_COMPROBANTES_PAGO_forma_pago' AND object_id = OBJECT_ID('dbo.COMPROBANTES_PAGO'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_COMPROBANTES_PAGO_forma_pago
    ON dbo.COMPROBANTES_PAGO (id_forma_pago)
    INCLUDE (fecha_pago, monto);

    PRINT 'Indice IX_COMPROBANTES_PAGO_forma_pago creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_COMPROBANTES_PAGO_fecha' AND object_id = OBJECT_ID('dbo.COMPROBANTES_PAGO'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_COMPROBANTES_PAGO_fecha
    ON dbo.COMPROBANTES_PAGO (fecha_pago);

    PRINT 'Indice IX_COMPROBANTES_PAGO_fecha creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AUDITORIA_FACTURA_factura_fecha' AND object_id = OBJECT_ID('dbo.AUDITORIA_FACTURA'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_AUDITORIA_FACTURA_factura_fecha
    ON dbo.AUDITORIA_FACTURA (id_factura, fecha)
    INCLUDE (id_usuario, accion);

    PRINT 'Indice IX_AUDITORIA_FACTURA_factura_fecha creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PRODUCTOS_SERVICIOS_categoria_activo' AND object_id = OBJECT_ID('dbo.PRODUCTOS_SERVICIOS'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_PRODUCTOS_SERVICIOS_categoria_activo
    ON dbo.PRODUCTOS_SERVICIOS (id_categoria, activo)
    INCLUDE (nombre, precio_unitario_actual, stock_actual);

    PRINT 'Indice IX_PRODUCTOS_SERVICIOS_categoria_activo creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PRODUCTOS_SERVICIOS_impuesto' AND object_id = OBJECT_ID('dbo.PRODUCTOS_SERVICIOS'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_PRODUCTOS_SERVICIOS_impuesto
    ON dbo.PRODUCTOS_SERVICIOS (id_impuesto);

    PRINT 'Indice IX_PRODUCTOS_SERVICIOS_impuesto creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CLIENTES_localidad' AND object_id = OBJECT_ID('dbo.CLIENTES'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_CLIENTES_localidad
    ON dbo.CLIENTES (id_localidad);

    PRINT 'Indice IX_CLIENTES_localidad creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CLIENTES_tipo_cliente' AND object_id = OBJECT_ID('dbo.CLIENTES'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_CLIENTES_tipo_cliente
    ON dbo.CLIENTES (id_tipo_cliente);

    PRINT 'Indice IX_CLIENTES_tipo_cliente creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CLIENTES_estado' AND object_id = OBJECT_ID('dbo.CLIENTES'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_CLIENTES_estado
    ON dbo.CLIENTES (id_estado_cliente);

    PRINT 'Indice IX_CLIENTES_estado creado.';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_LOCALIDADES_provincia' AND object_id = OBJECT_ID('dbo.LOCALIDADES'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_LOCALIDADES_provincia
    ON dbo.LOCALIDADES (id_provincia);

    PRINT 'Indice IX_LOCALIDADES_provincia creado.';
END;
GO

PRINT 'Creacion de indices de optimizacion finalizada.';
GO
