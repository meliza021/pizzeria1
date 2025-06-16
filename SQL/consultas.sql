-- Active: 1749179811997@@127.0.0.1@3306@taller_sql
-- PROCEDIMIENTO: Insertar pizza con ingredientes
DELIMITER $$
CREATE PROCEDURE ps_add_pizza_con_ingredientes(
  IN p_nombre_pizza VARCHAR(100),
  IN p_precio DECIMAL(10,2),
  IN p_ids_ingredientes JSON
)
BEGIN
  DECLARE p_pizza_id INT;
  DECLARE i INT DEFAULT 0;
  DECLARE ingrediente_id INT;

  -- Insertar la pizza como producto
  INSERT INTO producto (nombre, tipo_producto_id) VALUES (p_nombre_pizza, 2);
  SET p_pizza_id = LAST_INSERT_ID();

  -- Insertar presentación base
  INSERT INTO producto_presentacion (producto_id, presentacion_id, precio)
  VALUES (p_pizza_id, 1, p_precio);

  -- Insertar ingredientes de la pizza
  WHILE i < JSON_LENGTH(p_ids_ingredientes) DO
    SET ingrediente_id = JSON_UNQUOTE(JSON_EXTRACT(p_ids_ingredientes, CONCAT('$[', i, ']')));
    INSERT INTO ingredientes_extra (detalle_id, ingrediente_id, cantidad)
    VALUES (p_pizza_id, ingrediente_id, 1);
    SET i = i + 1;
  END WHILE;
END$$
DELIMITER ;

-- PROCEDIMIENTO: Actualizar precio de pizza
DELIMITER $$
CREATE PROCEDURE ps_actualizar_precio_pizza(
  IN p_pizza_id INT,
  IN p_nuevo_precio DECIMAL(10,2)
)
BEGIN
  IF p_nuevo_precio <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor que cero';
  ELSE
    UPDATE producto_presentacion
    SET precio = p_nuevo_precio
    WHERE producto_id = p_pizza_id;
  END IF;
END$$
DELIMITER ;

-- FUNCIÓN: Calcular subtotal de pizza (precio + ingredientes)
DELIMITER $$
CREATE FUNCTION fc_calcular_subtotal_pizza(p_pizza_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE subtotal DECIMAL(10,2);

  SELECT COALESCE(SUM(i.precio), 0)
  INTO subtotal
  FROM ingredientes_extra ie
  JOIN ingrediente i ON ie.ingrediente_id = i.id
  WHERE ie.detalle_id = p_pizza_id;

  -- Añadir precio base de la pizza
  RETURN (SELECT precio FROM producto_presentacion WHERE producto_id = p_pizza_id AND presentacion_id = 1) + subtotal;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ps_generar_pedido(
  IN p_cliente_id INT,
  IN p_items JSON,
  IN p_metodo_pago_id INT
)
BEGIN
  DECLARE p_pedido_id INT;
  DECLARE i INT DEFAULT 0;
  DECLARE v_producto_id INT;
  DECLARE v_cantidad INT;
  DECLARE v_detalle_id INT;
  DECLARE v_total DECIMAL(10,2) DEFAULT 0;

  START TRANSACTION;

  INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id)
  VALUES (NOW(), 0, p_cliente_id, p_metodo_pago_id);

  SET p_pedido_id = LAST_INSERT_ID();

  WHILE i < JSON_LENGTH(p_items) DO
    SET v_producto_id = JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].producto_id')));
    SET v_cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].cantidad')));

    INSERT INTO detalle_pedido (pedido_id, cantidad)
    VALUES (p_pedido_id, v_cantidad);
    SET v_detalle_id = LAST_INSERT_ID();

    INSERT INTO detalle_pedido_producto (detalle_id, producto_id)
    VALUES (v_detalle_id, v_producto_id);

    SET v_total = v_total + (
      SELECT precio FROM producto_presentacion
      WHERE producto_id = v_producto_id AND presentacion_id = 1
    ) * v_cantidad;

    SET i = i + 1;
  END WHILE;

  UPDATE pedido SET total = v_total WHERE id = p_pedido_id;

  COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ps_cancelar_pedido(IN p_pedido_id INT)
BEGIN
  DECLARE v_num_líneas INT;

  -- Marcar como cancelado
  UPDATE pedido SET estado = 'Cancelado' WHERE id = p_pedido_id;

  -- Eliminar detalles
  DELETE FROM detalle_pedido WHERE pedido_id = p_pedido_id;
  SET v_num_líneas = ROW_COUNT();

  SELECT v_num_líneas AS lineas_eliminadas;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ps_facturar_pedido(IN p_pedido_id INT)
BEGIN
  DECLARE v_total DECIMAL(10,2);
  DECLARE v_cliente_id INT;

  SELECT total, cliente_id INTO v_total, v_cliente_id
  FROM pedido WHERE id = p_pedido_id;

  INSERT INTO factura (total, fecha, pedido_id, cliente_id)
  VALUES (v_total, NOW(), p_pedido_id, v_cliente_id);

  SELECT LAST_INSERT_ID() AS factura_id;
END$$
DELIMITER ;


DELIMITER $$
CREATE FUNCTION fc_descuento_por_cantidad(
  p_cantidad INT,
  p_precio_unitario DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  IF p_cantidad >= 5 THEN
    RETURN p_precio_unitario * p_cantidad * 0.10;
  ELSE
    RETURN 0;
  END IF;
END$$
DELIMITER ;



DELIMITER $$
CREATE FUNCTION fc_precio_final_pedido(p_pedido_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE v_total DECIMAL(10,2) DEFAULT 0;
  DECLARE v_precio_unitario DECIMAL(10,2);
  DECLARE v_cantidad INT;
  DECLARE v_descuento DECIMAL(10,2);

  DECLARE done INT DEFAULT FALSE;
  DECLARE cur CURSOR FOR
    SELECT pp.precio, dp.cantidad
    FROM detalle_pedido dp
    JOIN detalle_pedido_producto dpp ON dp.id = dpp.detalle_id
    JOIN producto_presentacion pp ON dpp.producto_id = pp.product_id
    WHERE dp.pedido_id = p_pedido_id AND pp.presentacion_id = 1;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO v_precio_unitario, v_cantidad;
    IF done THEN LEAVE read_loop; END IF;

    SET v_descuento = fc_descuento_por_cantidad(v_cantidad, v_precio_unitario);
    SET v_total = v_total + (v_precio_unitario * v_cantidad) - v_descuento;
  END LOOP;

  CLOSE cur;

  RETURN v_total;
END$$
DELIMITER ;


DELIMITER $$
CREATE FUNCTION fc_obtener_stock_ingrediente(p_ingrediente_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE v_stock INT;

  SELECT stock INTO v_stock FROM ingrediente WHERE id = p_ingrediente_id;

  RETURN v_stock;
END$$
DELIMITER ;



