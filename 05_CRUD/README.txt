05_CRUD - Scripts SQL corregidos

Orden de ejecucion recomendado:

1) 01_Create_Insert/01_insert_clientes.sql
2) 01_Create_Insert/02_insert_productos_servicios.sql
3) 01_Create_Insert/03_insert_facturas.sql
4) 02_Read_Select/01_select_clientes.sql
5) 02_Read_Select/02_select_productos_servicios.sql
6) 02_Read_Select/03_select_facturas.sql
7) 02_Read_Select/04_select_reportes_joins_agrupaciones.sql
8) 03_Update/01_update_clientes.sql
9) 03_Update/02_update_productos_servicios.sql
10) 03_Update/03_update_facturas.sql
11) 04_Delete/01_delete_clientes.sql
12) 04_Delete/02_delete_productos_servicios.sql
13) 04_Delete/03_delete_facturas.sql
14) 05_Stored_Procedures/01_sp_clientes.sql
15) 05_Stored_Procedures/02_sp_productos_servicios.sql
16) 05_Stored_Procedures/03_sp_facturas.sql
17) 05_Stored_Procedures/04_sp_reportes_consultas.sql
18) 05_Stored_Procedures/99_verificar_procedimientos.sql

Correcciones aplicadas:
- Se agregaron opciones SET requeridas para trabajar con indices filtrados de SQL Server.
- Se corrigio la busqueda de IVA 21 para no depender del nombre exacto del impuesto; ahora usa porcentaje = 21.00.
- Se corrigio el tipo de factura para aceptar el catalogo real del proyecto: 'B'.
- Se mantuvo la estructura local del repositorio: 05_CRUD/01_Create_Insert, 02_Read_Select, 03_Update, 04_Delete, 05_Stored_Procedures.

Instancia usada durante pruebas del usuario: .\SQLEXPRESS con Windows Authentication.
