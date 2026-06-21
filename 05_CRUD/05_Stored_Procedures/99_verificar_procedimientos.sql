/* ============================================================
   99_verificar_procedimientos.sql
   Bloque: 05_CRUD / 05_Stored_Procedures

   Objetivo:
   - Verificar que los Stored Procedures del bloque CRUD existan.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SELECT
    name AS procedimiento,
    create_date,
    modify_date
FROM sys.procedures
WHERE name LIKE 'usp_%'
ORDER BY name;
GO
