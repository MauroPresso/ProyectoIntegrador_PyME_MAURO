06_Funciones_Subconsultas

Objetivo del bloque:
- Demostrar el uso de funciones de cadena y fecha solicitadas en la consigna:
  LTRIM, RTRIM, GETDATE y DATEDIFF.
- Incluir subconsultas para resolver consultas de forma mas clara y eficiente.
- Mantener coherencia con la base real del proyecto: BaseDeDatos_PyME.
- No crear tablas nuevas ni modificar datos: todos los scripts de este bloque son de solo lectura.

Orden de ejecucion recomendado:

1) 01_Funciones_Cadena/01_funciones_cadena_clientes.sql
2) 02_Funciones_Fecha/01_funciones_fecha_facturas.sql
3) 03_Subconsultas/01_subconsultas_reportes.sql

Dependencias:
- Ejecutar antes el modelo fisico.
- Ejecutar antes los datos iniciales del modelo fisico.
- Para ver resultados mas completos, ejecutar antes el bloque 05_CRUD, especialmente:
  05_CRUD/01_Create_Insert/01_insert_clientes.sql
  05_CRUD/01_Create_Insert/02_insert_productos_servicios.sql
  05_CRUD/01_Create_Insert/03_insert_facturas.sql

Criterio aplicado:
- Se usan los nombres reales del repositorio actual:
  06_Funciones_Subconsultas
  01_Funciones_Cadena
  02_Funciones_Fecha
  03_Subconsultas
- Se usa la base real del proyecto:
  BaseDeDatos_PyME
- Se usan tablas reales del modelo:
  dbo.CLIENTES
  dbo.PRODUCTOS_SERVICIOS
  dbo.FACTURAS
  dbo.DETALLES_FACTURA
  dbo.COMPROBANTES_PAGO
  dbo.ESTADOS_FACTURA
  dbo.TIPOS_CLIENTE
  dbo.TIPOS_DOCUMENTO
  dbo.LOCALIDADES
  dbo.PROVINCIAS
