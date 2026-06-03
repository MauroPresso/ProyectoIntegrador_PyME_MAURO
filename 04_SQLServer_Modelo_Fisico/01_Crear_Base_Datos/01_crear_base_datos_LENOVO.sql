/* ============================================================
   PROYECTO INTEGRADOR BDD
   CREACION DE BASE DE DATOS - LENOVO

   Base de datos: BaseDeDatos_PyME
   Motor: SQL Server
   Ejecutar una sola vez en la computadora Lenovo
   ============================================================ */

CREATE DATABASE BaseDeDatos_PyME
ON PRIMARY
(
    NAME = N'BaseDeDatos_PyME_Data',
    FILENAME = N'D:\IFES\Materias\1erCuatri2doAnio\BaseDeDatos\ProyectoIntegrador_PyME_MAURO\ProyectoIntegrador_PyME_MAURO\_LOCAL_SQLSERVER_DATA\BaseDeDatos_PyME.mdf',
    SIZE = 10MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 10MB
)
LOG ON
(
    NAME = N'BaseDeDatos_PyME_Log',
    FILENAME = N'D:\IFES\Materias\1erCuatri2doAnio\BaseDeDatos\ProyectoIntegrador_PyME_MAURO\ProyectoIntegrador_PyME_MAURO\_LOCAL_SQLSERVER_DATA\BaseDeDatos_PyME_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 5MB
);
GO

ALTER DATABASE BaseDeDatos_PyME SET RECOVERY SIMPLE;
GO

USE BaseDeDatos_PyME;
GO

PRINT 'Base de datos BaseDeDatos_PyME creada correctamente en la Lenovo.';
GO
