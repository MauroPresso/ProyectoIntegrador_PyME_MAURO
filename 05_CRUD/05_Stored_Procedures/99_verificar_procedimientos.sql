/* ============================================================
   99_verificar_procedimientos.sql
   Bloque: 05_CRUD / 05_Stored_Procedures

   Objetivo:
   - Verificar que los Stored Procedures del bloque CRUD existan.
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

SELECT
    name AS procedimiento,
    create_date,
    modify_date
FROM sys.procedures
WHERE name LIKE 'usp_%'
ORDER BY name;
GO
