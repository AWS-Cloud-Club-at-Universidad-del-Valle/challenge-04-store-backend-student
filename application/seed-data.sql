-- ─────────────────────────────────────────────────────────────
-- Datos de prueba de EJEMPLO — Reto 4: Catálogo de la tienda
--
-- Pobla el catálogo para verificar que RDS PostgreSQL funciona.
-- Carga después de schema.sql:
--   psql -h <RDS_ENDPOINT> -U <USUARIO> -d <DB> -f seed-data.sql
-- ─────────────────────────────────────────────────────────────

INSERT INTO categories (name, description) VALUES
    ('Electrónica', 'Dispositivos y accesorios electrónicos'),
    ('Hogar',       'Artículos para el hogar'),
    ('Ropa',        'Prendas de vestir')
ON CONFLICT (name) DO NOTHING;

INSERT INTO products (category_id, name, description, price, image_key) VALUES
    (1, 'Audífonos inalámbricos', 'Bluetooth 5.0, cancelación de ruido', 149.90, 'products/audifonos.jpg'),
    (1, 'Teclado mecánico',       'Switches rojos, retroiluminado',       89.99, 'products/teclado.jpg'),
    (2, 'Lámpara de escritorio',  'LED regulable con puerto USB',         34.50, 'products/lampara.jpg'),
    (3, 'Camiseta algodón',       '100% algodón, varios colores',         19.99, 'products/camiseta.jpg');

INSERT INTO inventory (product_id, quantity, warehouse) VALUES
    (1, 120, 'main'),
    (2,  80, 'main'),
    (3, 200, 'main'),
    (4, 500, 'main');

-- Consulta de ejemplo: catálogo con categoría y stock (demuestra el valor del modelo relacional)
--   SELECT p.name, c.name AS categoria, p.price, i.quantity
--   FROM products p
--   JOIN categories c ON c.category_id = p.category_id
--   JOIN inventory  i ON i.product_id  = p.product_id;
