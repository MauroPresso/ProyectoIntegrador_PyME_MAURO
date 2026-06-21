/* ============================================================
   04_sp_reportes_consultas.sql
   Proyecto Integrador BDD - PyME Generica
   Bloque: 05_CRUD / 05_Stored_Procedures

   Procedimientos incluidos:
   - dbo.usp_Reportes_Total_Facturado_Mes
   - dbo.usp_Reportes_Productos_Mas_Vendidos
   - dbo.usp_Reportes_Clientes_Mas_Compras
   - dbo.usp_Reportes_Facturas_Por_Estado
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Reportes_Total_Facturado_Mes
    @anio INT,
    @mes INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @mes < 1 OR @mes > 12
        THROW 64001, 'El mes debe estar entre 1 y 12.', 1;

    SELECT
        @anio AS anio,
        @mes AS mes,
        COUNT(f.id_factura) AS cantidad_facturas_pagadas,
        COALESCE(SUM(f.total_neto), 0) AS total_neto,
        COALESCE(SUM(f.total_impuestos), 0) AS total_impuestos,
        COALESCE(SUM(f.total_descuentos), 0) AS total_descuentos,
        COALESCE(SUM(f.total_recargos), 0) AS total_recargos,
        COALESCE(SUM(f.total), 0) AS total_facturado
    FROM dbo.FACTURAS f
    INNER JOIN dbo.ESTADOS_FACTURA ef
        ON f.id_estado_factura = ef.id_estado_factura
    WHERE
        ef.estado = 'Pagada'
        AND YEAR(f.fecha_emision) = @anio
        AND MONTH(f.fecha_emision) = @mes;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Reportes_Productos_Mas_Vendidos
    @top INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    IF @top <= 0
        THROW 64002, 'El valor de @top debe ser mayor a cero.', 1;

    SELECT TOP (@top)
        ps.id_producto_servicio,
        ps.nombre AS producto_servicio,
        cp.nombre AS categoria,
        SUM(d.cantidad) AS cantidad_vendida,
        SUM(d.subtotal_neto) AS total_neto_vendido,
        SUM(d.importe_impuesto) AS total_impuestos,
        SUM(d.subtotal_con_impuesto) AS total_con_impuestos
    FROM dbo.DETALLES_FACTURA d
    INNER JOIN dbo.PRODUCTOS_SERVICIOS ps
        ON d.id_producto_servicio = ps.id_producto_servicio
    INNER JOIN dbo.CATEGORIAS_PRODUCTO cp
        ON ps.id_categoria = cp.id_categoria
    INNER JOIN dbo.FACTURAS f
        ON d.id_factura = f.id_factura
    INNER JOIN dbo.ESTADOS_FACTURA ef
        ON f.id_estado_factura = ef.id_estado_factura
    WHERE ef.estado <> 'Anulada'
    GROUP BY
        ps.id_producto_servicio,
        ps.nombre,
        cp.nombre
    ORDER BY cantidad_vendida DESC, total_con_impuestos DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Reportes_Clientes_Mas_Compras
    @top INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    IF @top <= 0
        THROW 64003, 'El valor de @top debe ser mayor a cero.', 1;

    SELECT TOP (@top)
        c.id_cliente,
        CASE
            WHEN c.tipo_persona = 'F'
                THEN c.nombre + ' ' + c.apellido
            ELSE c.razon_social
        END AS cliente,
        c.numero_documento,
        COUNT(f.id_factura) AS cantidad_facturas,
        COALESCE(SUM(f.total), 0) AS total_comprado
    FROM dbo.CLIENTES c
    INNER JOIN dbo.FACTURAS f
        ON c.id_cliente = f.id_cliente
    INNER JOIN dbo.ESTADOS_FACTURA ef
        ON f.id_estado_factura = ef.id_estado_factura
    WHERE ef.estado <> 'Anulada'
    GROUP BY
        c.id_cliente,
        c.tipo_persona,
        c.nombre,
        c.apellido,
        c.razon_social,
        c.numero_documento
    ORDER BY total_comprado DESC, cantidad_facturas DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Reportes_Facturas_Por_Estado
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ef.estado AS estado_factura,
        COUNT(f.id_factura) AS cantidad_facturas,
        COALESCE(SUM(f.total), 0) AS total_acumulado
    FROM dbo.ESTADOS_FACTURA ef
    LEFT JOIN dbo.FACTURAS f
        ON ef.id_estado_factura = f.id_estado_factura
    GROUP BY ef.estado
    ORDER BY ef.estado;
END;
GO
