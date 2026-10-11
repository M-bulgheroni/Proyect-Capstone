-- ============================================================
-- PROYECTO CAPSTONE EDA - E-COMMERCE
-- Archivo: estructura.sql
-- Objetivo: crear y poblar las tablas para analizar ventas.
-- Ejecutar conectado a la base capstone_project.
-- ============================================================

-- Si se vuelve a ejecutar, elimina las tablas del proyecto.
DROP TABLE IF EXISTS detalle_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    cliente_id INTEGER PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    ciudad VARCHAR(80),
    fecha_alta DATE
);

CREATE TABLE productos (
    producto_id INTEGER PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio NUMERIC(12,2)
    -- Se permite NULL a propósito para practicar limpieza de datos.
);

CREATE TABLE pedidos (
    pedido_id INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(cliente_id),
    fecha_pedido DATE
    -- Se permite NULL a propósito para practicar identificación de faltantes.
);

CREATE TABLE detalle_pedido (
    detalle_id INTEGER PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES pedidos(pedido_id),
    producto_id INTEGER NOT NULL REFERENCES productos(producto_id),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0)
);

-- -------------------------
-- Clientes
-- -------------------------
INSERT INTO clientes (cliente_id, nombre, ciudad, fecha_alta) VALUES
(1, 'Ana Torres', 'Buenos Aires', '2025-01-10'),
(2, 'Bruno Díaz', 'Córdoba', '2025-02-15'),
(3, 'Carla Gómez', 'Rosario', '2025-03-20'),
(4, 'Diego López', 'Buenos Aires', '2025-04-05'),
(5, 'Elena Ruiz', 'Mendoza', '2025-05-12'),
(6, 'Facundo Pérez', 'Córdoba', '2025-06-18'),
(7, 'Gabriela Sosa', 'La Plata', '2025-07-01'),
(8, 'Hugo Fernández', 'Buenos Aires', '2025-08-22'),
(9, 'Inés Castro', 'Rosario', '2025-09-09'),
(10, 'Julián Acosta', 'Mendoza', '2025-10-30');

-- -------------------------
-- Productos
-- Un precio NULL es intencional para probar el tratamiento de faltantes.
-- -------------------------
INSERT INTO productos (producto_id, nombre_producto, categoria, precio) VALUES
(1, 'Auriculares', 'Electrónica', 25000.00),
(2, 'Teclado', 'Electrónica', 32000.00),
(3, 'Mouse', 'Electrónica', 15000.00),
(4, 'Silla de escritorio', 'Hogar', 95000.00),
(5, 'Botella térmica', 'Hogar', 18000.00),
(6, 'Cuaderno', 'Oficina', 5000.00),
(7, 'Lámpara de escritorio', 'Oficina', NULL),
(8, 'Mochila', 'Accesorios', 42000.00);

-- -------------------------
-- Pedidos
-- Un pedido con fecha NULL es intencional para demostrar la limpieza.
-- -------------------------
INSERT INTO pedidos (pedido_id, cliente_id, fecha_pedido) VALUES
(1001, 1, '2026-01-05'),
(1002, 2, '2026-01-08'),
(1003, 3, '2026-01-15'),
(1004, 1, '2026-02-02'),
(1005, 4, '2026-02-10'),
(1006, 5, '2026-02-18'),
(1007, 2, '2026-03-01'),
(1008, 6, '2026-03-04'),
(1009, 7, '2026-03-12'),
(1010, 3, '2026-03-20'),
(1011, 8, '2026-04-02'),
(1012, 1, '2026-04-09'),
(1013, 9, '2026-04-15'),
(1014, 10, '2026-04-20'),
(1015, 4, NULL);

-- -------------------------
-- Detalle de cada pedido
-- Cada fila representa un producto dentro de un pedido.
-- -------------------------
INSERT INTO detalle_pedido (detalle_id, pedido_id, producto_id, cantidad) VALUES
(1, 1001, 1, 2),
(2, 1001, 6, 3),
(3, 1002, 4, 1),
(4, 1002, 5, 2),
(5, 1003, 2, 1),
(6, 1003, 3, 2),
(7, 1004, 4, 1),
(8, 1004, 1, 1),
(9, 1005, 8, 1),
(10, 1005, 6, 5),
(11, 1006, 5, 3),
(12, 1006, 3, 1),
(13, 1007, 2, 2),
(14, 1007, 1, 1),
(15, 1008, 6, 4),
(16, 1008, 5, 1),
(17, 1009, 8, 2),
(18, 1009, 3, 1),
(19, 1010, 4, 1),
(20, 1010, 2, 1),
(21, 1011, 1, 1),
(22, 1011, 5, 2),
(23, 1012, 4, 1),
(24, 1012, 8, 1),
(25, 1013, 6, 2),
(26, 1013, 3, 1),
(27, 1014, 2, 1),
(28, 1014, 5, 2),
(29, 1015, 7, 2),
(30, 1015, 6, 1);

-- -------------------------
-- Control inicial de calidad
-- Estos resultados permiten confirmar que los datos se cargaron.
-- -------------------------
SELECT 'clientes' AS tabla, COUNT(*) AS filas FROM clientes
UNION ALL
SELECT 'productos', COUNT(*) FROM productos
UNION ALL
SELECT 'pedidos', COUNT(*) FROM pedidos
UNION ALL
SELECT 'detalle_pedido', COUNT(*) FROM detalle_pedido;

-- Detección de valores faltantes antes del análisis.
SELECT
    COUNT(*) FILTER (WHERE precio IS NULL) AS productos_sin_precio
FROM productos;

SELECT
    COUNT(*) FILTER (WHERE fecha_pedido IS NULL) AS pedidos_sin_fecha
FROM pedidos;
