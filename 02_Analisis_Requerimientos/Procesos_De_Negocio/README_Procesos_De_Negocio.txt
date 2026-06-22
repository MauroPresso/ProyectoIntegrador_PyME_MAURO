README - PROCESOS DE NEGOCIO
============================

Proyecto: ProyectoIntegrador_PyME_MAURO
Carpeta: 02_Analisis_Requerimientos/Procesos_De_Negocio


1. Objetivo
-----------

Esta carpeta contiene los diagramas de procesos de negocio correspondientes al analisis de la
problematica de la PyME generica.

Los diagramas se ubican en 02_Analisis_Requerimientos porque representan procesos del negocio y
forman parte del analisis del sistema. No se ubican en 03_Modelado porque esa carpeta se reserva
para el modelado de datos: modelo conceptual, modelo logico, DER y diccionario minimo.


2. Archivos incluidos
---------------------

- Diagrama_Proceso_Negocio_AS_IS.png
  Representa la situacion actual de la PyME antes de la solucion propuesta. Muestra una operatoria
  manual o dispersa, con busqueda en archivos separados, carga manual, calculos manuales,
  registro separado de pagos y reportes lentos.

- Diagrama_Proceso_Negocio_TO_BE.png
  Representa la situacion propuesta luego de implementar la base de datos BaseDeDatos_PyME.
  Muestra una operatoria centralizada, con validaciones, integridad referencial, facturacion,
  pagos asociados, auditoria y reportes.

- README_Procesos_De_Negocio.txt
  Explica el proposito de esta carpeta y el uso de los diagramas.


3. Criterio aplicado
--------------------

Se utiliza un enfoque AS-IS / TO-BE:

- AS-IS: describe como funciona actualmente el proceso o como funcionaria una PyME sin una base de
datos centralizada.

- TO-BE: describe como deberia funcionar el proceso con la solucion propuesta, utilizando una base
de datos relacional en SQL Server.


4. Relacion con el proyecto de base de datos
--------------------------------------------

El proceso TO-BE se relaciona directamente con los objetos desarrollados en la base BaseDeDatos_PyME:

- CLIENTES
- PRODUCTOS_SERVICIOS
- FACTURAS
- DETALLES_FACTURA
- COMPROBANTES_PAGO
- DESCUENTOS_FACTURA
- RECARGOS_FACTURA
- USUARIOS
- AUDITORIA_FACTURA

Tambien se apoya en tablas de catalogo como:

- PROVINCIAS
- LOCALIDADES
- TIPOS_CLIENTE
- TIPOS_DOCUMENTO
- ESTADOS_CLIENTES
- ROLES
- ESTADOS_USUARIOS
- ESTADOS_FACTURA
- TIPOS_FACTURA
- TIPOS_OPERACION_FACTURA
- CATEGORIAS_PRODUCTO
- IMPUESTOS
- FORMAS_PAGO


5. Uso en la presentacion
-------------------------

Estos diagramas pueden utilizarse para explicar:

- La problematica actual de la PyME.
- Las debilidades de la gestion manual o dispersa.
- La mejora propuesta mediante una base de datos centralizada.
- La relacion entre analisis de sistemas y diseno de base de datos.
