05_CRUD - Scripts definitivos del bloque CRUD
Proyecto Integrador BDD - PyME Generica
Motor: SQL Server
Base de datos: BaseDeDatos_PyME

Orden sugerido de ejecucion:

1) Primero debe estar creado y cargado el modelo fisico:
   04_SQLServer_Modelo_Fisico/01_Crear_Base_Datos
   04_SQLServer_Modelo_Fisico/02_Creacion_de_tablas
   04_SQLServer_Modelo_Fisico/03_Restricciones
   04_SQLServer_Modelo_Fisico/05_Inserts

2) Luego ejecutar estos scripts directos:
   05_CRUD/01_Create_Insert/01_insert_clientes.sql
   05_CRUD/01_Create_Insert/02_insert_productos_servicios.sql
   05_CRUD/01_Create_Insert/03_insert_facturas.sql

   05_CRUD/02_Read_Select/01_select_clientes.sql
   05_CRUD/02_Read_Select/02_select_productos_servicios.sql
   05_CRUD/02_Read_Select/03_select_facturas.sql
   05_CRUD/02_Read_Select/04_select_reportes_joins_agrupaciones.sql

   05_CRUD/03_Update/01_update_clientes.sql
   05_CRUD/03_Update/02_update_productos_servicios.sql
   05_CRUD/03_Update/03_update_facturas.sql

   05_CRUD/04_Delete/01_delete_clientes.sql
   05_CRUD/04_Delete/02_delete_productos_servicios.sql
   05_CRUD/04_Delete/03_delete_facturas.sql

3) Finalmente ejecutar los Stored Procedures:
   05_CRUD/05_Stored_Procedures/01_sp_clientes.sql
   05_CRUD/05_Stored_Procedures/02_sp_productos_servicios.sql
   05_CRUD/05_Stored_Procedures/03_sp_facturas.sql
   05_CRUD/05_Stored_Procedures/04_sp_reportes_consultas.sql
   05_CRUD/05_Stored_Procedures/99_verificar_procedimientos.sql

Criterio de eliminacion:
- Para tablas de negocio se usa baja logica cuando corresponde:
  CLIENTES -> estado Inactivo
  PRODUCTOS_SERVICIOS -> activo = 0
  FACTURAS -> estado Anulada
- Ademas, los scripts de la carpeta 04_Delete incluyen ejemplos controlados de DELETE fisico
  sobre registros temporales sin dependencias, para demostrar la operacion DELETE.
