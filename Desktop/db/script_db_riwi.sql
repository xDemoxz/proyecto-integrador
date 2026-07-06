-- LIMPIEZA TOTAL DE OBJETOS EXISTENTES

DROP TABLE IF EXISTS rm_inventory_movements CASCADE;
DROP TABLE IF EXISTS rm_purchases CASCADE;
DROP TABLE IF EXISTS rm_employees CASCADE;
DROP TABLE IF EXISTS rm_warehouses CASCADE;
DROP TABLE IF EXISTS rm_suppliers CASCADE;
DROP TABLE IF EXISTS rm_products CASCADE;
DROP TABLE IF EXISTS rm_categories CASCADE;
DROP TABLE IF EXISTS rm_cities CASCADE;

-- TABLAS MAESTRAS

CREATE TABLE rm_cities (
	city_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	city_name varchar(100) NOT NULL UNIQUE
);

CREATE TABLE rm_categories (
	category_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	category_name varchar(100) NOT NULL UNIQUE 
);

CREATE TABLE rm_employees (
	employee_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	employee_name varchar(150) NOT NULL UNIQUE
);

-- TABLAS DEPENDIENTES 

CREATE TABLE rm_products (
  product_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  product_sku varchar(50) NOT NULL UNIQUE,
  product_name varchar(150) NOT NULL,
  product_desc varchar(255),
  unit_measure varchar(30) NOT NULL,
  unit_price decimal(12, 2) NOT NULL CHECK (unit_price >= 0),
  
  category_name varchar(100) NOT NULL, 
  category_id int, 

  CONSTRAINT fk_products_categories
  	FOREIGN KEY (category_id) REFERENCES rm_categories (category_id) ON DELETE RESTRICT
);

CREATE TABLE rm_suppliers (
  supplier_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  supplier_code varchar(50) NOT NULL UNIQUE,
  supplier_tax_id varchar(50) NOT NULL UNIQUE,
  supplier_name varchar(150) NOT NULL,
  supplier_phone varchar(30),
  
  -- Campos de datos
  city_name varchar(100) NOT NULL,
  city_id int, 

  CONSTRAINT fk_suppliers_cities
  	FOREIGN KEY (city_id) REFERENCES rm_cities (city_id) ON DELETE RESTRICT
);

CREATE TABLE rm_warehouses (
  warehouse_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  warehouse_code varchar(20) UNIQUE NOT NULL,
  warehouse_name varchar(150) NOT NULL,
  warehouse_address varchar(200) NOT NULL,
  
  -- Campos de datos
  city_name varchar(100) NOT NULL,
  city_id int,   
  
  CONSTRAINT fk_warehouses_cities
  	FOREIGN KEY (city_id) REFERENCES rm_cities (city_id) ON DELETE RESTRICT
);

CREATE TABLE rm_purchases (
  purchase_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  purchase_code varchar(20) UNIQUE NOT NULL,
  purchase_date timestamp NOT NULL,
  purchase_quantity int NOT NULL CHECK (purchase_quantity > 0),
  
  product_sku varchar(50) NOT NULL,
  warehouse_code varchar(20) NOT NULL,
  supplier_code varchar(50) NOT NULL,
  
  supplier_id int,
  warehouse_id int,
  product_id int,

  CONSTRAINT fk_purchases_warehouses FOREIGN KEY (warehouse_id) REFERENCES rm_warehouses (warehouse_id) ON DELETE RESTRICT,
  CONSTRAINT fk_purchases_products FOREIGN KEY (product_id) REFERENCES rm_products (product_id) ON DELETE RESTRICT,
  CONSTRAINT fk_purchases_suppliers FOREIGN KEY (supplier_id) REFERENCES rm_suppliers (supplier_id) ON DELETE RESTRICT
);

CREATE TABLE rm_inventory_movements (
  movement_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  movement_code varchar(30) UNIQUE NOT NULL,
  movement_type varchar(30) NOT NULL CHECK (movement_type IN ('IN','OUT')),
  movement_date timestamp NOT NULL,
  movement_quantity int NOT NULL CHECK (movement_quantity > 0),
  stock_after_movement int NOT NULL CHECK (stock_after_movement > 0),
  
  warehouse_code varchar(20) NOT NULL,
  product_sku varchar(50) NOT NULL,
  employee_name varchar(150) NOT NULL,
  purchase_code varchar(20),
  
  warehouse_id int,
  product_id int,
  employee_id int,
  purchase_id int,

  CONSTRAINT fk_inventory_movements_warehouses FOREIGN KEY (warehouse_id) REFERENCES rm_warehouses (warehouse_id) ON DELETE RESTRICT,
  CONSTRAINT fk_inventory_movements_products FOREIGN KEY (product_id) REFERENCES rm_products (product_id) ON DELETE RESTRICT,
  CONSTRAINT fk_inventory_movements_employees FOREIGN KEY (employee_id) REFERENCES rm_employees (employee_id) ON DELETE RESTRICT,
  CONSTRAINT fk_inventory_movements_purchases FOREIGN KEY (purchase_id) REFERENCES rm_purchases (purchase_id) ON DELETE RESTRICT
);

-- ÍNDICES DE VELOCIDAD OPTIMIZADOS PARA IDs
CREATE INDEX idx_purchases_product ON rm_purchases(product_id);
CREATE INDEX idx_purchases_supplier ON rm_purchases(supplier_id);
CREATE INDEX idx_movements_warehouse ON rm_inventory_movements(warehouse_id);
CREATE INDEX idx_movements_product ON rm_inventory_movements(product_id);

-- COMANDOS COPY

COPY rm_cities(city_name) FROM 'C:/Users/Aleja/developer/SQL/simulacro/archivos_csv/rm_cities.csv' DELIMITER ',' CSV HEADER;
COPY rm_categories(category_name) FROM 'C:\Users\Aleja\developer\SQL\simulacro\archivos_csv\rm_categories.csv' DELIMITER ',' CSV HEADER;
COPY rm_products(product_sku,product_name,product_desc,category_name,unit_measure,unit_price) FROM 'C:\Users\Aleja\developer\SQL\simulacro\archivos_csv\rm_products.csv' DELIMITER ',' CSV HEADER;
COPY rm_suppliers(supplier_code,supplier_tax_id,supplier_name,supplier_phone,city_name) FROM 'C:\Users\Aleja\developer\SQL\simulacro\archivos_csv\rm_suppliers.csv' DELIMITER ',' CSV HEADER;
COPY rm_warehouses(warehouse_code,warehouse_name,warehouse_address,city_name) FROM 'C:\Users\Aleja\developer\SQL\simulacro\archivos_csv\rm_warehouses.csv' DELIMITER ',' CSV HEADER;
COPY rm_purchases(purchase_code,purchase_date,purchase_quantity,supplier_code,warehouse_code,product_sku) FROM 'C:\Users\Aleja\developer\SQL\simulacro\archivos_csv\rm_purchases.csv' DELIMITER ',' CSV HEADER;
COPY rm_employees(employee_name) FROM 'C:\Users\Aleja\developer\SQL\simulacro\archivos_csv\rm_employees.csv' DELIMITER ',' CSV HEADER;
COPY rm_inventory_movements(movement_code, movement_type, movement_date, movement_quantity, stock_after_movement, warehouse_code, product_sku, employee_name, purchase_code) FROM 'C:/Users/Aleja/developer/SQL/simulacro/archivos_csv/rm_inventory_movements.csv' DELIMITER ',' CSV HEADER;

-- ASIGNACIÓN MASIVA E INSTANTÁNEA DE LOS IDs RELACIONALES

UPDATE rm_products p SET category_id = c.category_id FROM rm_categories c WHERE p.category_name = c.category_name;
UPDATE rm_suppliers s SET city_id = c.city_id FROM rm_cities c WHERE s.city_name = c.city_name;
UPDATE rm_warehouses w SET city_id = c.city_id FROM rm_cities c WHERE w.city_name = c.city_name;

UPDATE rm_purchases p
SET supplier_id = s.supplier_id, warehouse_id = w.warehouse_id, product_id = prod.product_id
FROM rm_suppliers s, rm_warehouses w, rm_products prod
WHERE p.supplier_code = s.supplier_code AND p.warehouse_code = w.warehouse_code AND p.product_sku = prod.product_sku;

UPDATE rm_inventory_movements m
SET warehouse_id = sub.warehouse_id,
    product_id   = sub.product_id,
    employee_id  = sub.employee_id,
    purchase_id  = sub.purchase_id
FROM (

    SELECT 
        m_int.movement_id,
        w.warehouse_id,
        prod.product_id,
        emp.employee_id,
        pur.purchase_id
    FROM rm_inventory_movements m_int
    INNER JOIN rm_warehouses w    ON m_int.warehouse_code = w.warehouse_code
    INNER JOIN rm_products prod   ON m_int.product_sku = prod.product_sku
    INNER JOIN rm_employees emp   ON m_int.employee_name = emp.employee_name
    LEFT JOIN rm_purchases pur    ON m_int.purchase_code = pur.purchase_code 
) sub
WHERE m.movement_id = sub.movement_id;

-- Arreglar el UPDATE de purchases con el mapeo de códigos alias
WITH stg_supplier_map (supplier_code, supplier_tax_id) AS (
    VALUES
        ('S-001','900111222-1'), ('S-002','900111222-1'),
        ('S-003','901333444-5'), ('S-004','901333444-5'),
        ('S-005','901777888-2'), ('S-006','901777888-2'),
        ('S-007','900999111-3'), ('S-008','900999111-3')
)
UPDATE rm_purchases p
SET supplier_id = s.supplier_id, warehouse_id = w.warehouse_id, product_id = prod.product_id
FROM stg_supplier_map map, rm_suppliers s, rm_warehouses w, rm_products prod
WHERE p.supplier_code = map.supplier_code
  AND map.supplier_tax_id = s.supplier_tax_id
  AND p.warehouse_code = w.warehouse_code
  AND p.product_sku = prod.product_sku;
 
-- Bloquear NOT NULL en las FKs
ALTER TABLE rm_products ALTER COLUMN category_id SET NOT NULL;
ALTER TABLE rm_suppliers ALTER COLUMN city_id SET NOT NULL;
ALTER TABLE rm_warehouses ALTER COLUMN city_id SET NOT NULL;
ALTER TABLE rm_purchases ALTER COLUMN supplier_id SET NOT NULL;
ALTER TABLE rm_purchases ALTER COLUMN warehouse_id SET NOT NULL;
ALTER TABLE rm_purchases ALTER COLUMN product_id SET NOT NULL;
ALTER TABLE rm_inventory_movements ALTER COLUMN warehouse_id SET NOT NULL;
ALTER TABLE rm_inventory_movements ALTER COLUMN product_id SET NOT NULL;
ALTER TABLE rm_inventory_movements ALTER COLUMN employee_id SET NOT NULL;

-- Eliminar las columnas puente
ALTER TABLE rm_products DROP COLUMN category_name;
ALTER TABLE rm_suppliers DROP COLUMN city_name;
ALTER TABLE rm_warehouses DROP COLUMN city_name;
ALTER TABLE rm_purchases DROP COLUMN product_sku, DROP COLUMN warehouse_code, DROP COLUMN supplier_code;
ALTER TABLE rm_inventory_movements DROP COLUMN warehouse_code, DROP COLUMN product_sku, DROP COLUMN employee_name;

INSERT INTO rm_suppliers (supplier_code, supplier_tax_id, supplier_name, supplier_phone, city_id)
VALUES (
	'S-009', 
	'900999888-7', 
	'Ferretería Central', 
	'555-1234',
    (SELECT city_id FROM rm_cities WHERE city_name = 'Bogota D.C.'));

INSERT INTO rm_products (product_sku, product_name, product_desc, unit_measure, unit_price, category_id)
VALUES (
    'SKU-9999', 
    'Taladro Percutor 20V', 
    'Taladro inalámbrico industrial', 
    'Unidad', 
    149.99, 
    (SELECT category_id FROM rm_categories WHERE category_name = 'Herramientas')
);

INSERT INTO rm_purchases (purchase_code, purchase_date, purchase_quantity, supplier_id, warehouse_id, product_id)
VALUES (
    'PO-2026-999', 
    NOW(), 
    50, 
    (SELECT supplier_id FROM rm_suppliers WHERE supplier_code = 'S-009'),
    (SELECT warehouse_id FROM rm_warehouses WHERE warehouse_code = 'WH-BOG-01'),
    (SELECT product_id FROM rm_products WHERE product_sku = 'SKU-9999')
);


-- Actualizar teléfono de un proveedor
UPDATE rm_suppliers
SET supplier_phone = '314-201-9722'
WHERE supplier_code = 'S-003';

-- Actualizar ciudad de una bodega
UPDATE rm_warehouses
SET city_id = (SELECT city_id FROM rm_cities WHERE city_name = 'Medellin')
WHERE warehouse_code = 'WH-BAQ-01';

-- Actualizar precio de un producto
UPDATE rm_products
SET unit_price = 8000
WHERE product_sku = 'SKU-1002';

INSERT INTO rm_products (product_sku, product_name, product_desc, unit_measure, unit_price, category_id)
VALUES (
	'SKU-0000', 
	'Producto de prueba', 
	'Solo para probar DELETE', 
	'Unidad', 
	1.00,
        (SELECT category_id FROM rm_categories WHERE category_name = 'Herramientas'));

DELETE FROM rm_products WHERE product_sku = 'SKU-0000';


--SELECT 
--    p.product_sku,
--    p.product_name,
--    SUM(CASE WHEN m.movement_type = 'IN' THEN m.movement_quantity ELSE -m.movement_quantity END) AS stock_disponible
--FROM rm_products p
--JOIN rm_inventory_movements m ON p.product_id = m.product_id
--GROUP BY p.product_sku, p.product_name
--ORDER BY p.product_name;

--SELECT 
--    w.warehouse_name,
--    p.product_name,
--    SUM(CASE WHEN m.movement_type = 'IN' THEN m.movement_quantity ELSE -m.movement_quantity END) AS cantidad
--FROM rm_warehouses w
--JOIN rm_inventory_movements m ON w.warehouse_id = m.warehouse_id
--JOIN rm_products p ON p.product_id = m.product_id
--GROUP BY w.warehouse_name, p.product_name
--ORDER BY w.warehouse_name, p.product_name;

--SELECT 
--   s.supplier_name,
--    SUM(pu.purchase_quantity * p.unit_price) AS total_comprado
--FROM rm_suppliers s
--JOIN rm_purchases pu ON s.supplier_id = pu.supplier_id
--JOIN rm_products p ON p.product_id = pu.product_id
--GROUP BY s.supplier_name
--ORDER BY total_comprado DESC;

--SELECT 
--    p.product_sku,
--    p.product_name,
--    SUM(CASE WHEN m.movement_type = 'IN' THEN m.movement_quantity ELSE -m.movement_quantity END) AS stock_disponible
--FROM rm_products p
--JOIN rm_inventory_movements m ON p.product_id = m.product_id
--GROUP BY p.product_sku, p.product_name
--ORDER BY stock_disponible ASC
--LIMIT 5;

--SELECT 
--    p.product_name,
--   SUM(pu.purchase_quantity) AS total_comprado
--FROM rm_products p
--JOIN rm_purchases pu ON p.product_id = pu.product_id
--GROUP BY p.product_name
--ORDER BY total_comprado DESC
--LIMIT 5;

--SELECT 
--    c.city_name,
--    SUM(stock.cantidad_disponible * p.unit_price) AS valor_inventario
--FROM (
--    SELECT 
--        m.warehouse_id,
--        m.product_id,
--        SUM(CASE WHEN m.movement_type = 'IN' THEN m.movement_quantity ELSE -m.movement_quantity END) AS cantidad_disponible
--    FROM rm_inventory_movements m
--    GROUP BY m.warehouse_id, m.product_id
--) stock.p
--JOIN rm_products p ON p.product_id = stockroduct_id
--JOIN rm_warehouses w ON w.warehouse_id = stock.warehouse_id
--JOIN rm_cities c ON c.city_id = w.city_id
--GROUP BY c.city_name
--ORDER BY valor_inventario DESC;
