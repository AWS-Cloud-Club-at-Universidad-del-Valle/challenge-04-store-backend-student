-- ─────────────────────────────────────────────────────────────
-- Esquema de EJEMPLO — Reto 4: Catálogo de la tienda (RDS PostgreSQL)
--
-- Modela la parte RELACIONAL de la tienda: categorías, productos e
-- inventario, con integridad referencial (claves foráneas).
-- Esto es lo que justifica usar una base de datos relacional en vez
-- de NoSQL: hay relaciones y consultas estructuradas.
--
-- Carga sugerida:
--   psql -h <RDS_ENDPOINT> -U <USUARIO> -d <DB> -f schema.sql
-- ─────────────────────────────────────────────────────────────

-- Categorías de productos
CREATE TABLE IF NOT EXISTS categories (
    category_id   SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL UNIQUE,
    description   TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Productos del catálogo
CREATE TABLE IF NOT EXISTS products (
    product_id    SERIAL PRIMARY KEY,
    category_id   INTEGER NOT NULL REFERENCES categories(category_id),
    name          VARCHAR(200) NOT NULL,
    description   TEXT,
    price         NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    -- Clave del objeto en S3 (la imagen vive en S3, NO en la base de datos)
    image_key     VARCHAR(512),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Inventario (stock por producto)
CREATE TABLE IF NOT EXISTS inventory (
    inventory_id  SERIAL PRIMARY KEY,
    product_id    INTEGER NOT NULL UNIQUE REFERENCES products(product_id),
    quantity      INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    warehouse     VARCHAR(100) NOT NULL DEFAULT 'main',
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices útiles para consultas frecuentes del catálogo
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_inventory_product ON inventory(product_id);
