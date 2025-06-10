-- Clientes
INSERT INTO cliente (nombre, telefono, direccion) VALUES
('Juan Pérez', '12345678901', 'Calle Falsa 123'),
('María López', '10987654321', 'Av. Siempre Viva 742');

-- Tipo de productos
INSERT INTO tipo_producto (nombre) VALUES
('Bebida'),
('Comida'),
('Postre');

-- Productos
INSERT INTO producto (nombre, tipo_producto_id) VALUES
('Café', 1),
('Hamburguesa', 2),
('Helado', 3);

-- Presentaciones
INSERT INTO presentacion (nombre) VALUES
('Pequeña'),
('Mediana'),
('Grande');

-- Producto - Presentación (con precios)
INSERT INTO producto_presentacion (producto_id, presentacion_id, precio) VALUES
(1, 1, 1.50),  
(1, 2, 2.00),  
(2, 2, 5.00),  
(3, 3, 3.00);  

-- Combos
INSERT INTO combo (nombre, precio) VALUES
('Combo desayuno', 7.00),
('Combo cena', 10.00);

-- Producto - Combo
INSERT INTO producto_combo (producto_id, combo_id) VALUES
(1, 1),  
(2, 2),  
(3, 2);  

-- Método de pago
INSERT INTO metodo_pago (nombre) VALUES
('Efectivo'),
('Tarjeta de crédito'),
('Transferencia');

-- Pedido
INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id) VALUES
('2025-06-10 12:00:00', 7.00, 1, 2),
('2025-06-10 20:00:00', 10.00, 2, 1);

-- Detalle pedido
INSERT INTO detalle_pedido (cantidad, pedido_id, producto_id) VALUES
(1, 1, 1),  
(1, 2, 2),  
(1, 2, 3);  

-- Ingredientes
INSERT INTO ingrediente (nombre, stock, precio) VALUES
('Leche', 100, 0.50),
('Carne', 50, 3.00),
('Chocolate', 30, 1.00);

-- Ingredientes extra en detalle pedido
INSERT INTO ingrediente_extra (cantidad, detalle_pedido_id, ingrediente_id) VALUES
(1, 1, 1),  
(2, 2, 2);  

-- Factura
INSERT INTO factura (cliente, total, fecha, pedido_id, cliente_id) VALUES
('Juan Pérez', 7.00, '2025-06-10 12:05:00', 1, 1),
('María López', 10.00, '2025-06-10 20:05:00', 2, 2);
