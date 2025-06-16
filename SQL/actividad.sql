-- Active: 1750072773908@@127.0.0.1@3307@mysql
- Borrar procedimientos

DROP PROCEDURE IF EXISTS ps_top_ventas_pedidos;

DROP PROCEDURE IF EXISTS ps_top_ventas_pedidos_loop;

DROP PROCEDURE IF EXISTS ps_actualizar_precio_productos;

DROP PROCEDURE IF EXISTS ps_actualizar_precio_productos2;

DROP PROCEDURE IF EXISTS ps_actualizar_precio_productos3;

-- Crear procedimientos

-- EJercicio1 #1

DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS ps_top_ventas_pedidos()
BEGIN

    DECLARE _total DECIMAL(10, 2) DEFAULT 0.00;
    DECLARE _total_filas INT DEFAULT 0;
    DECLARE _fila INT DEFAULT 0;
    SET _total_filas = (SELECT COUNT(*) FROM pedido);

    ciclo : LOOP
        -- Traer datos
        SET _total = (SELECT total FROM pedido LIMIT _fila, 1);

        IF _total >= 40000 THEN
            SELECT id AS Id_Pedido, total AS Total, 'TOP' AS Statu, _total AS 'TOTAL_CAL' FROM pedido LIMIT _fila, 1;
        ELSE
            SELECT id AS Id_Pedido, total AS Total, 'NO TOP' AS Statu, _total AS 'TOTAL_CAL' FROM pedido LIMIT _fila, 1;

        END IF;

        -- Incremento y fin de ciclo

        IF _total_filas > 0 AND _fila < _total_filas - 1 THEN
            SET _fila = _fila + 1;
        ELSE
            LEAVE ciclo;
        END IF;

    END LOOP ciclo;
END$$

DELIMITER ;

-- Ejercicio1 #2

DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS ps_top_ventas_pedidos_loop()
BEGIN
    DECLARE _id INT DEFAULT 0;
    DECLARE _total DECIMAL(10,2) DEFAULT 0.00;
    DECLARE fin_cursor INT DEFAULT FALSE;

    DECLARE cursor_pedido CURSOR FOR
    SELECT id, total FROM pedido ORDER BY total DESC;

    -- Manejador de final de cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin_cursor = TRUE;

    OPEN cursor_pedido;

    c_pedidos: LOOP
        FETCH cursor_pedido INTO _id, _total;
        IF fin_cursor THEN
            LEAVE c_pedidos;
        END IF;


        IF _total >= 45000 THEN
            SELECT _id AS Id_Pedido, _total AS Total, 'TOP' AS Status;
        ELSE
            SELECT _id AS Id_Pedido, _total AS Total, 'NO TOP' AS Status;
        END IF;

    END LOOP c_pedidos;

    CLOSE cursor_pedido;

END$$

DELIMITER ;

-- Ejercicio2 #1

DELIMITER //

CREATE PROCEDURE ps_actualizar_precio_productos(
    IN p_producto_id INT, 
    IN p_nuevo_precio DECIMAL(10,2))
BEGIN
    DECLARE _pro_pre_id INT; -- producto presentacion id
    DECLARE _rows_loop INT DEFAULT 0;
    DECLARE _counter_loop INT DEFAULT 0;

    DECLARE cur_pro CURSOR FOR
        SELECT presentacion_id FROM producto_presentacion WHERE producto_id = p_producto_id AND presentacion_id <> 1;

    -- Actualizar
    UPDATE producto_presentacion SET precio = p_nuevo_precio WHERE producto_id = p_producto_id AND presentacion_id = 1;
    
    -- Validacion del update
    IF ROW_COUNT() <= 0 THEN
        SELECT 'No se encontro el producto' AS Error;
    ELSE

        -- Asignar la cantidad de filas o registros para el loop
        SET _rows_loop = (SELECT COUNT(*) FROM producto_presentacion WHERE producto_id = p_producto_id AND presentacion_id <> 1);

        OPEN cur_pro;

        leer_pro : LOOP
            FETCH cur_pro INTO _pro_pre_id;
            SET _counter_loop = _counter_loop + 1;

            UPDATE producto_presentacion
            SET precio = p_nuevo_precio + (p_nuevo_precio * 0.11)
            WHERE producto_id = p_producto_id AND presentacion_id = _pro_pre_id;

            -- Validar LOOP
            IF _counter_loop >= _rows_loop THEN
                LEAVE leer_pro;
            END IF;
        END LOOP leer_pro;

        CLOSE cur_pro;

        IF ROW_COUNT() > 0 THEN
            SELECT 'Producto actualizado' AS Message;
        ELSE
            SELECT 'No se actualizo el precio de las otras presentaciones del producto' AS Error;
        END IF;

    END IF;

END //

DELIMITER ;

-- Ejercicio2 #2

DELIMITER //

CREATE PROCEDURE ps_actualizar_precio_productos2(
    IN p_producto_id INT, 
    IN p_nuevo_precio DECIMAL(10,2)
)
BEGIN
    DECLARE _pro_pre_id INT; -- producto presentacion id
    DECLARE done INT DEFAULT 0;
    DECLARE filas_actualizadas INT DEFAULT 0;

    DECLARE cur_pro CURSOR FOR
        SELECT presentacion_id 
        FROM producto_presentacion 
        WHERE producto_id = p_producto_id AND presentacion_id <> 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    UPDATE producto_presentacion 
    SET precio = p_nuevo_precio
    WHERE producto_id = p_producto_id AND presentacion_id = 1;

    IF ROW_COUNT() <= 0 THEN
        SELECT 'No se encontró el producto con presentacion_id = 1' AS Error;
    ELSE

        OPEN cur_pro;

        leer_pro: LOOP
            FETCH cur_pro INTO _pro_pre_id;

            IF done THEN
                LEAVE leer_pro;
            END IF;

            UPDATE producto_presentacion
            SET precio = p_nuevo_precio + (p_nuevo_precio * 0.11)
            WHERE producto_id = p_producto_id AND presentacion_id = _pro_pre_id;

            SET filas_actualizadas = filas_actualizadas + ROW_COUNT();
        END LOOP leer_pro;

        CLOSE cur_pro;

        IF filas_actualizadas > 0 THEN
            SELECT 'Producto actualizado' AS Message;
        ELSE
            SELECT 'Se actualizó la presentación principal, pero no las otras presentaciones' AS Advertencia;
        END IF;

    END IF;

END //

DELIMITER ;

-- Ejercicio2 #3

DELIMITER //

CREATE PROCEDURE ps_actualizar_precio_productos3(
    IN p_producto_id INT, 
    IN p_nuevo_precio DECIMAL(10,2)
)
BEGIN
    DECLARE _pro_pre_id INT; -- producto presentacion id
    DECLARE done INT DEFAULT 0;
    DECLARE filas_actualizadas INT DEFAULT 0;
    DECLARE precio_base DECIMAL(10,2);
    DECLARE precio_mediano DECIMAL(10,2);
    DECLARE precio_grande DECIMAL(10,2);

    DECLARE cur_pro CURSOR FOR
        SELECT presentacion_id 
        FROM producto_presentacion 
        WHERE producto_id = p_producto_id AND presentacion_id <> 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Paso 1: Actualizar presentación pequeno (id = 1)
    UPDATE producto_presentacion 
    SET precio = p_nuevo_precio
    WHERE producto_id = p_producto_id AND presentacion_id = 1;

    IF ROW_COUNT() <= 0 THEN
        SELECT 'No se encontró el producto con presentacion_id = 1' AS Error;
    ELSE
        SET precio_base = p_nuevo_precio;
        SET precio_mediano = ROUND(precio_base + (precio_base * 0.11), 2);
        SET precio_grande = ROUND(precio_mediano + (precio_mediano * 0.11), 2);

        OPEN cur_pro;

        leer_pro: LOOP
            FETCH cur_pro INTO _pro_pre_id;

            IF done THEN
                LEAVE leer_pro;
            END IF;

            IF _pro_pre_id = 2 THEN
                UPDATE producto_presentacion 
                SET precio = precio_mediano
                WHERE producto_id = p_producto_id AND presentacion_id = _pro_pre_id;

            ELSEIF _pro_pre_id = 3 THEN
                UPDATE producto_presentacion 
                SET precio = precio_grande
                WHERE producto_id = p_producto_id AND presentacion_id = _pro_pre_id;
            END IF;

            SET filas_actualizadas = filas_actualizadas + ROW_COUNT();
        END LOOP leer_pro;

        CLOSE cur_pro;

        IF filas_actualizadas > 0 THEN
            SELECT 'Producto actualizado' AS Message;
        ELSE
            SELECT 'Se actualizó la presentación principal, pero no las otras presentaciones' AS Advertencia;
        END IF;

    END IF;

END //

DELIMITER ;

-- Ejecutar procedimientos

CALL ps_top_ventas_pedidos();

CALL ps_top_ventas_pedidos_loop();

CALL ps_actualizar_precio_productos(1, 36000.00);

CALL ps_actualizar_precio_productos2(1, 35000.00);

CALL ps_actualizar_precio_productos3(1, 34000.00);

SELECT * FROM producto_presentacion;


SELECT * FROM factura;

DELIMITER //
   CREATE TRIGGER before_facturas_insert
   BEFORE INSERT ON facturas
   FOR EACH ROW
   BEGIN
       DECLARE next_id INT;
       DECLARE formatted_code VARCHAR(20);
       DECLARE prefix VARCHAR(5) DEFAULT 'FAC-'; -- Prefijo deseado
       DECLARE padding INT DEFAULT 8; -- Cantidad de ceros a rellenar

       -- Obtener el próximo ID autoincremental
       SET next_id = (SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'facturas');

       -- Formatear el código con ceros a la izquierda
       SET formatted_code = CONCAT(prefix, LPAD(next_id, padding, '0'));

       -- Asignar el código formateado al nuevo registro
       SET NEW.codigo_factura = formatted_code;
   END //
   DELIMITER ;

   INSERT INTO facturas (fecha_emision, monto) VALUES ('2024-10-27', 100.00);
   INSERT INTO facturas (fecha_emision, monto) VALUES ('2024-10-28', 250.50);