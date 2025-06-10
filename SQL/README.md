📋 README - Base de Datos Pizzería Margarita
Este archivo describe la estructura, creación y relaciones de la base de datos pizzeria_margarita, desarrollada para gestionar el funcionamiento de una pizzería, incluyendo clientes, productos, pedidos, facturación, métodos de pago, ingredientes, entre otros.

🔄 Eliminación de Tablas Existentes
Antes de crear las nuevas estructuras, se eliminaron las tablas existentes (si las hubiera) para evitar conflictos y asegurar una creación limpia de la base de datos:

sql
Copiar
Editar
DROP TABLE IF EXISTS ...
🗃️ Uso de la Base de Datos
sql
Copiar
Editar
USE pizzeria_margarita;
Se asegura que las operaciones se ejecuten en la base de datos correcta.

🏗️ Creación de Tablas
Se crean las siguientes tablas:

1. cliente
Contiene información de los clientes.

id, nombre, telefono, direccion

Se indexa el nombre para facilitar búsquedas.

2. producto
Registra los productos individuales (pizzas, bebidas, etc.).

Relacionado con tipo_producto.

3. combo
Contiene combos que agrupan varios productos.

Incluye nombre y precio.

4. detalle_pedido
Registra los productos de cada pedido con su cantidad.

Relacionado con pedido y producto.

5. factura
Guarda la información de la venta final.

Incluye cliente, total, fecha, pedido_id y cliente_id.

6. pedido
Registra cada pedido, su fecha de recogida, total, cliente y método de pago.

7. metodo_pago
Contiene los distintos métodos de pago disponibles (efectivo, tarjeta, etc.).

8. ingrediente_extra
Permite agregar ingredientes adicionales por cada producto en el pedido.

9. tipo_producto
Define las categorías de productos (pizza, bebida, postre, etc.).

10. presentacion
Define los formatos o tamaños en los que se ofrecen los productos (ej. Mediana, Grande).

11. ingrediente
Lista de ingredientes disponibles, con su stock y precio.

12. producto_presentacion
Relaciona productos con sus presentaciones y precios correspondientes.

13. producto_combo
Relaciona productos que forman parte de un combo.

🔗 Relaciones (Claves Foráneas)
Se establecen las relaciones entre las tablas mediante claves foráneas para garantizar integridad referencial:

ingrediente_extra ↔ ingrediente, detalle_pedido

detalle_pedido ↔ pedido, producto

pedido ↔ metodo_pago, cliente

factura ↔ cliente, pedido

producto ↔ tipo_producto

producto_presentacion ↔ producto, presentacion

producto_combo ↔ producto, combo

✅ Objetivo del Diseño
Este modelo de base de datos busca:

Controlar el flujo de pedidos y facturación.

Gestionar el inventario de ingredientes.

Ofrecer flexibilidad para combos y presentaciones de productos.

Registrar información detallada de los clientes y sus pedidos.

📌 Recomendaciones
Asegúrate de tener activado el modo de restricción de claves foráneas en tu motor de base de datos.

Se recomienda poblar primero las tablas independientes (tipo_producto, presentacion, ingrediente, metodo_pago) antes de insertar registros dependientes.

