/* ============================================================
   03_select_facturas.sql
   Bloque: 05_CRUD / 02_Read_Select

   Objetivo:
   - Consultar facturas con filtros.
   - Mostrar cabecera, cliente, usuario, estado, tipo y detalle.
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

DECLARE
    @numero_factura VARCHAR(30) = 'F-CRUD-0001',
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL;

/* Cabecera de factura */
SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    ef.estado AS estado_factura,
    tf.tipo AS tipo_factura,
    tof.operacion AS tipo_operacion,
    CASE
        WHEN c.tipo_persona = 'F'
            THEN c.nombre + ' ' + c.apellido
        ELSE c.razon_social
    END AS cliente,
    c.numero_documento,
    u.nombre_usuario,
    f.total_neto,
    f.total_impuestos,
    f.total_descuentos,
    f.total_recargos,
    f.total,
    f.observaciones
FROM dbo.FACTURAS f
INNER JOIN dbo.ESTADOS_FACTURA ef
    ON f.id_estado_factura = ef.id_estado_factura
INNER JOIN dbo.TIPOS_FACTURA tf
    ON f.id_tipo_factura = tf.id_tipo_factura
INNER JOIN dbo.TIPOS_OPERACION_FACTURA tof
    ON f.id_tipo_operacion_factura = tof.id_tipo_operacion_factura
INNER JOIN dbo.CLIENTES c
    ON f.id_cliente = c.id_cliente
INNER JOIN dbo.USUARIOS u
    ON f.id_usuario = u.id_usuario
WHERE
    (@numero_factura IS NULL OR f.numero_factura = @numero_factura)
    AND (@fecha_desde IS NULL OR CONVERT(DATE, f.fecha_emision) >= @fecha_desde)
    AND (@fecha_hasta IS NULL OR CONVERT(DATE, f.fecha_emision) <= @fecha_hasta)
ORDER BY f.fecha_emision DESC, f.id_factura DESC;

/* Detalle de factura */
SELECT
    f.numero_factura,
    d.id_detalle_factura,
    ps.nombre AS producto_servicio,
    cp.nombre AS categoria,
    d.cantidad,
    d.precio_unitario_facturado,
    d.subtotal_neto,
    d.porcentaje_impuesto_facturado,
    d.importe_impuesto,
    d.subtotal_con_impuesto
FROM dbo.DETALLES_FACTURA d
INNER JOIN dbo.FACTURAS f
    ON d.id_factura = f.id_factura
INNER JOIN dbo.PRODUCTOS_SERVICIOS ps
    ON d.id_producto_servicio = ps.id_producto_servicio
INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
    ON ps.id_categoria = cp.id_categoria
WHERE (@numero_factura IS NULL OR f.numero_factura = @numero_factura)
ORDER BY f.numero_factura, d.id_detalle_factura;
GO
