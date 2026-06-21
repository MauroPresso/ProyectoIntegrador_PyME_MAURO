/* ============================================================
   01_update_clientes.sql
   Bloque: 05_CRUD / 03_Update

   Objetivo:
   - Actualizar datos de clientes de prueba.
   ============================================================ */

USE BaseDeDatos_PyME;
GO

SET NOCOUNT ON;
GO

UPDATE dbo.CLIENTES
SET
    telefono = '2991112222',
    email = 'cliente.crud.fisico.actualizado@mail.com',
    direccion = 'Calle CRUD Actualizada 789'
WHERE numero_documento = '20999000111';

UPDATE dbo.CLIENTES
SET
    telefono = '2993334444',
    email = 'empresa.crud.actualizada@mail.com',
    direccion = 'Av. CRUD Actualizada 987'
WHERE numero_documento = '30709990001';

SELECT
    c.id_cliente,
    c.tipo_persona,
    c.numero_documento,
    c.nombre,
    c.apellido,
    c.razon_social,
    c.direccion,
    c.telefono,
    c.email,
    ec.estado AS estado_cliente
FROM dbo.CLIENTES c
INNER JOIN dbo.ESTADOS_CLIENTES ec
    ON c.id_estado_cliente = ec.id_estado_cliente
WHERE c.numero_documento IN ('20999000111', '30709990001')
ORDER BY c.id_cliente;
GO
