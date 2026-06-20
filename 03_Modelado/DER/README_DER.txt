DER - Sistema de Ventas y Facturacion para PyME generica
Fecha de version: 2026-06-20

Esta carpeta contiene el Diagrama Entidad-Relacion final de la etapa de modelado.
La version esta ajustada al feedback del profesor de practica:

- Se elimina TIPOS_DOCUMENTO.
- En CLIENTES se usa cuil_cuit VARCHAR(11), sin guiones.
- Se agrega tipo_persona CHAR(1) con valores permitidos F o J.
- COMPROBANTES_PAGO se relaciona 1 a 1 con FACTURAS mediante id_factura UNIQUE.
- No se agregan nuevas entidades fuera del alcance actual.

Archivos incluidos:
- DER_PyME_Final.png: imagen del DER para insertar en documentacion o presentacion.
- DER_PyME_Final.pdf: version imprimible del DER.
- DER_PyME_Final.svg: version escalable del DER.
- DER_PyME_Final.dot: archivo fuente editable en Graphviz.
