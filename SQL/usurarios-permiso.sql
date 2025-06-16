-- Active: 1750072773908@@127.0.0.1@3307@pizzas
CREATE USER 'vendedor'@'localhost' IDENTIFIED BY 'v3bD3d0r.';
CREATE USER 'nalista'@'localhost' IDENTIFIED WITH sha256_password BY 'aN@lista'

--aca verificamos si el usuario no tiene permiso para utilizar las tablas 
SHOW GRANTS FOR 'vendedor'@'localhost';

--como asignar un permiso
GRANT SELECT ON pizzas.* TO 'vendedor'@'localhost';
FLUSH PRIVILEGES;
SHOW GRANTS FOR  'vendedor'@'localhost'


--ver cuales permisos tiene el vendedor para actualizar
    REMOVE INSERT, UPDATE ON pizzas.* TO 'vendedor'@'localhost';
    GRANT INSERT, UPDATE ON pizzas. TO 'vendedor'@'localhost';
    GRANT INSERT, UPDATE ON pizzas.* TO 'vendedor'@'localhost';
    GRANT INSERT, UPDATE ON pizzas.* TO 'vendedor'@'localhost';
    GRANT INSERT, UPDATE ON pizzas.* TO 'vendedor'@'localhost';
    GRANT INSERT, UPDATE ON pizzas.* TO 'vendedor'@'localhost';
    GRANT INSERT, UPDATE ON pizzas.* TO 'vendedor'@'localhost';
    GRANT INSERT, UPDATE ON pizzas.* TO 'vendedor'@'localhost';
    GRANT INSERT, UPDATE ON pizzas.* TO 'vendedor'@'localhost';

--para dar permiso de crear una funcion



SHOW TABLES;
GRANT EXECUTE ON PROCEDURE pizza.ps_actualizar_precio_producto TO 'vendedor'@'vendedor'
GRANT EXECUTE ON FUNCTION pizzas.fn_calcular_subtotal_pedido TO 'vendedor'@'vendedor'
