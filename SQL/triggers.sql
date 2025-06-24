
DELIMITER $$

DROP TRIGGER IF EXISTS tg_descontar_stock_ingrediente_extra $$

CREATE TRIGGER tg_descontar_stock_ingrediente_extra
AFTER INSERT ON ingrediente_extra
FOR EACH ROW
BEGIN

    UPDATE ingrediente SET stock = stock - NEW.cantidad
    WHERE id = NEW.ingrediente_id;

END $$

DELIMITER ;

INSERT INTO ingrediente_extra(cantidad, detalle_pedido_id, ingrediente_id)
VALUES(10, 1, 1);

SELECT * FROM ingrediente;


DELIMITER $$

DROP TRIGGER IF EXISTS tg_registro_actualizacion_precios $$

CREATE TRIGGER tg_registro_actualizacion_precios
AFTER UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    DECLARE p_precio_anterior DECIMAL(10,2);

    INSERT INTO auditoria_precios(producto_id, presentacion_id, precio_anterior, precio_nuevo, fecha_cambio)
    VALUES(NEW.producto_id, NEW.presentacion_id, OLD.precio, NEW.precio, NOW());

END $$

DELIMITER ;

UPDATE producto_presentacion SET precio = 25000 WHERE id = 4;

SELECT * FROM auditoria_precios;


DELIMITER $$

DROP TRIGGER IF EXISTS tg_impedir_ciertos_precios $$

CREATE TRIGGER tg_impedir_ciertos_precios
BEFORE UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN

    IF NEW.precio < 1 THEN
        SIGNAL SQLSTATE '40001'
            SET MESSAGE_TEXT = 'El precio debe ser mayor a 0';
    END IF;

END $$

DELIMITER ;

UPDATE producto_presentacion SET precio = 0 WHERE id = 1;


DELIMITER $$

DROP TRIGGER IF EXISTS tg_generar_factura $$

CREATE TRIGGER tg_generar_factura
AFTER INSERT ON pedido
FOR EACH ROW
BEGIN
    DECLARE p_estado VARCHAR(150);

    IF NEW.estado IN ('Cancelado', 'Enviado') THEN
        SIGNAL SQLSTATE '40001'
            SET MESSAGE_TEXT = 'El pedido debe de estar en pendiente';
    END IF;

    INSERT INTO factura(total, fecha, pedido_id, cliente_id)
    VALUES(NEW.total, NOW(), NEW.id, NEW.cliente_id);

END $$

DELIMITER ;

INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id, estado)
VALUES('2025-03-11 06:00:00', 50000, 2, 1, 'Pendiente');

SELECT * FROM factura;


DELIMITER $$

DROP TRIGGER IF EXISTS tg_actualizar_estado_pedido $$

CREATE TRIGGER tg_actualizar_estado_pedido
AFTER INSERT ON factura
FOR EACH ROW
BEGIN

    UPDATE pedido SET estado = 'enviado' WHERE id = NEW.pedido_id;

END $$

DELIMITER ;

SELECT * FROM pedido;

INSERT INTO factura (total, fecha, pedido_id, cliente_id)
VALUES(35000, '2025-06-10 12:05:00', 1, 1);


DELIMITER $$

DROP TRIGGER IF EXISTS tg_evitar_eliminacion_combos_usados $$

CREATE TRIGGER tg_evitar_eliminacion_combos_usados
BEFORE DELETE ON combo
FOR EACH ROW
BEGIN
    DECLARE p_combo_id INT;
    DECLARE relacion_combo INT;

    SELECT id INTO p_combo_id FROM combo
    WHERE id = OLD.id;

    SELECT COUNT(*) INTO relacion_combo FROM producto_combo
    WHERE combo_id IN (SELECT id FROM combo WHERE id = p_combo_id);

    IF relacion_combo > 0 THEN
        SIGNAL SQLSTATE '40001'
            SET MESSAGE_TEXT = 'El combo esta relacionado';
    END IF;
    
END $$

DELIMITER ;

INSERT INTO combo(nombre, precio)
VALUES('Pa Adrian', 2000);

DELETE FROM combo WHERE id = 1;

SELECT COUNT(*) AS relaciones_combo FROM producto_combo
WHERE combo_id IN (SELECT id FROM combo WHERE id = 2);