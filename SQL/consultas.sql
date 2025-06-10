-- Insertar métodos de pago (deben ir primero)
INSERT INTO `metodo_pago`(nombre)
VALUES('nequi'),
      ('Bancolombia'),
      ('Daviplata'),
      ('Efectivo'),
      ('Tarjeta de crédito'),
      ('Tarjeta de débito'),
      ('PayPal'),
      ('Transferencia bancaria');

-- Insertar tipos de productos
INSERT INTO `tipo_producto`(nombre)
VALUES('pizzas'),
      ('bebidas'),
      ('postres'),
      ('aperitivos');

-- Insertar presentaciones
INSERT INTO `presentacion`(nombre)
VALUES('individual'),
      ('mediana'),
      ('familiar'),
      ('gigante');

-- Insertar clientes
INSERT INTO `cliente` (nombre, telefono, direccion)
VALUES ('Juan Pérez', '3198564542', 'Av. Siempre Viva 123'),
       ('meliza', '3163580535', 'calle 52'),
       ('kevin', '3183179090', 'calle 65');

-- Insertar productos
INSERT INTO `producto`(nombre, tipo_producto_id)
VALUES('Pizza Margarita', 1),
      ('Coca Cola', 2),
      ('Brownie', 3),
      ('Alitas BBQ', 4),
      ('Nachos con Queso', 4),
      ('Agua Mineral', 2);

-- Insertar combos
INSERT INTO `combo`(nombre, precio)
VALUES('El Combo Gigante', 50000),
      ('La Feriada delicias', 80000),
      ('cajita feliz', 60000);

-- Insertar ingredientes
INSERT INTO `ingrediente`(nombre)
VALUES('queso'),
      ('jamón'),
      ('pepperoni'),
      ('piña'),
      ('champiñones'),
      ('tocino'),
      ('cebolla'),
      ('pimiento'),
      ('aceitunas'),
      ('albahaca'),
      ('tomate'),
      ('atún'),
      ('pollo'),
      ('carne molida'),
      ('salchicha');

-- Insertar pedidos
INSERT INTO `pedido`(fecha_recogida, total, cliente_id, metodo_pago_id)
VALUES('2023-10-01', 150000, 1, 1),
      ('2023-10-02', 200000, 2, 2),
      ('2023-10-03', 250000, 3, 1);

-- Insertar detalle de pedidos
INSERT INTO `detalle_pedido`(cantidad, pedido_id, producto_id)
VALUES(2, 1, 1),
      (1, 2, 1),
      (3, 3, 2),
      (1, 1, 2),
      (5, 2, 3),
      (2, 3, 3);

-- Insertar ingredientes extra
INSERT INTO `ingrediente_extra`(cantidad, detalle_pedido_id, ingrediente_id)
VALUES(1, 1, 1),
      (2, 2, 2),
      (1, 3, 3),
      (3, 4, 4),
      (2, 5, 5);

-- Insertar facturas
INSERT INTO `factura`(cliente, fecha, pedido_id, total, cliente_id)
VALUES('Juan Pérez', '2023-10-01', 1, 150000, 1),
      ('meliza', '2023-10-02', 2, 200000, 2),
      ('kevin', '2023-10-03', 3, 250000, 3);

-- Insertar presentaciones de productos
INSERT INTO `producto_presentacion`(producto_id, presentacion_id, precio)
VALUES(1, 1, 15000),
      (1, 2, 20000),
      (1, 3, 30000),
      (1, 4, 40000),
      (2, 1, 10000),
      (2, 2, 15000),
      (2, 3, 20000),
      (2, 4, 25000);

-- Insertar productos en combos
INSERT INTO `producto_combo`(producto_id, combo_id)
VALUES(1, 1),
      (2, 1),
      (3, 2),
      (4, 2),
      (5, 3);
