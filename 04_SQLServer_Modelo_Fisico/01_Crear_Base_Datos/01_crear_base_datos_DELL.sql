/* ============================================================
   PROYECTO INTEGRADOR BDD
   CREACION DE BASE DE DATOS - DELL

   Base de datos: BaseDeDatos_PyME
   Motor: SQL Server
   Ejecutar una sola vez en la computadora DELL
   ============================================================ */

CREATE DATABASE BaseDeDatos_PyME
ON PRIMARY
(
    NAME = N'BaseDeDatos_PyME_Data',
    FILENAME = N'D:\Mauro\Facultad\IFES\Materias\1erCuatri2doAnio\BasesDeDatos\DataBase101\ProyectoIntegrador_PyME_MAURO\_LOCAL_SQLSERVER_DATA\BaseDeDatos_PyME.mdf',
    SIZE = 10MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 10MB
)
LOG ON
(
    NAME = N'BaseDeDatos_PyME_Log',
    FILENAME = N'D:\Mauro\Facultad\IFES\Materias\1erCuatri2doAnio\BasesDeDatos\DataBase101\ProyectoIntegrador_PyME_MAURO\_LOCAL_SQLSERVER_DATA\BaseDeDatos_PyME_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 5MB
);
GO

ALTER DATABASE BaseDeDatos_PyME SET RECOVERY SIMPLE;
GO

USE BaseDeDatos_PyME;
GO

PRINT 'Base de datos BaseDeDatos_PyME creada correctamente en la DELL.';
GO
