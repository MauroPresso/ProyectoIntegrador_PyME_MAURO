/* ============================================================
   PROYECTO INTEGRADOR BDD
   VALIDACION DE CREACION DE BASE DE DATOS

   Base de datos: BaseDeDatos_PyME
   Sirve para verificar que la base fue creada correctamente
   y que los archivos fisicos .mdf y .ldf estan en la ruta esperada.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SELECT DB_NAME() AS base_actual;
GO

SELECT 
    name AS nombre_logico,
    physical_name AS ruta_fisica
FROM sys.database_files;
GO

SELECT 
    name,
    database_id,
    create_date
FROM sys.databases
WHERE name = 'BaseDeDatos_PyME';
GO
