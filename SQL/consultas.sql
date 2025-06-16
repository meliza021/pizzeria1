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
