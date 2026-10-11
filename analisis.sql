-- ============================================================
-- PROYECTO CAPSTONE EDA - E-COMMERCE
-- Archivo: analisis.sql
-- Ejecutar después de estructura.sql en capstone_project.
-- Las consultas explican el criterio de negocio, además del SQL.
-- ============================================================

-- 1. PERFIL DE CALIDAD DE DATOS
-- Medimos los faltantes antes de decidir cómo tratarlos.
SELECT
    'productos.precio' AS campo,
    COUNT(*) FILTER (WHERE precio IS NULL) AS valores_nulos,
    COUNT(*) AS filas_totales
FROM productos
UNION ALL
SELECT
    'pedidos.fecha_pedido',
    COUNT(*) FILTER (WHERE fecha_pedido IS NULL),
    COUNT(*)
FROM pedidos;


-- 2. PREPARACIÓN / LIMPIEZA
-- Para este ejercicio, los precios faltantes se reemplazan por el promedio
-- de los precios conocidos. Es una regla didáctica: en un caso real se debe
-- validar con el área comercial antes de imputar un precio.
-- La fecha faltante NO se inventa. Se mantiene NULL y esos pedidos quedan
-- fuera del análisis mensual hasta que se confirme su fecha.
CREATE OR REPLACE VIEW productos_limpios AS
SELECT
    producto_id,
    nombre_producto,
    categoria,
    COALESCE(
        precio,
        (SELECT ROUND(AVG(precio), 2) FROM productos WHERE precio IS NOT NULL)
    ) AS precio_analisis,
    (precio IS NULL) AS precio_imputado
FROM productos;

-- Verificación: identificar qué valor fue imputado.
SELECT *
FROM productos_limpios
ORDER BY producto_id;


-- 3. VISTA DE VENTAS LIMPIAS
-- Unimos pedidos, detalle y productos para calcular el importe de cada línea.
-- Se usa INNER JOIN porque solo analizamos líneas que tienen pedido y producto
-- relacionados mediante sus claves foráneas.
CREATE OR REPLACE VIEW ventas_limpias AS
SELECT
    pe.pedido_id,
    pe.cliente_id,
    pe.fecha_pedido,
    d.producto_id,
    p.nombre_producto,
    p.categoria,
    d.cantidad,
    p.precio_analisis,
    d.cantidad * p.precio_analisis AS importe_linea
FROM pedidos pe
JOIN detalle_pedido d ON d.pedido_id = pe.pedido_id
JOIN productos_limpios p ON p.producto_id = d.producto_id;


-- 4. PREGUNTA DE NEGOCIO 1:
-- ¿Cuáles son los 5 clientes que más dinero generan?
-- Sumamos el importe de sus líneas y ordenamos de mayor a menor.
SELECT
    c.cliente_id,
    c.nombre,
    COUNT(DISTINCT v.pedido_id) AS cantidad_pedidos,
    ROUND(SUM(v.importe_linea), 2) AS gasto_total
FROM clientes c
JOIN ventas_limpias v ON v.cliente_id = c.cliente_id
GROUP BY c.cliente_id, c.nombre
ORDER BY gasto_total DESC
LIMIT 5;


-- 5. PREGUNTA DE NEGOCIO 2:
-- ¿Cómo evolucionan las ventas mes a mes?
-- Los pedidos sin fecha se excluyen de la tendencia mensual, no se les asigna
-- una fecha ficticia. Es necesario corregirlos en origen para un reporte final.
SELECT
    DATE_TRUNC('month', fecha_pedido)::DATE AS mes,
    ROUND(SUM(importe_linea), 2) AS ventas_totales,
    COUNT(DISTINCT pedido_id) AS pedidos
FROM ventas_limpias
WHERE fecha_pedido IS NOT NULL
GROUP BY DATE_TRUNC('month', fecha_pedido)
ORDER BY mes;


-- 6. PREGUNTA DE NEGOCIO 3:
-- ¿Cuáles son los 3 productos menos vendidos por unidades?
-- Se usa LEFT JOIN para incluir también productos con cero unidades vendidas.
SELECT
    p.producto_id,
    p.nombre_producto,
    p.categoria,
    COALESCE(SUM(v.cantidad), 0) AS unidades_vendidas
FROM productos_limpios p
LEFT JOIN ventas_limpias v ON v.producto_id = p.producto_id
GROUP BY p.producto_id, p.nombre_producto, p.categoria
ORDER BY unidades_vendidas ASC, p.nombre_producto
LIMIT 3;


-- 7. PREGUNTA DE NEGOCIO 4:
-- ¿Qué posición ocupa cada pedido dentro de su categoría por importe?
-- RANK() es una función de ventana: permite rankear sin agrupar las filas
-- hasta perder el detalle de cada pedido.
WITH total_por_pedido_categoria AS (
    SELECT
        pedido_id,
        categoria,
        SUM(importe_linea) AS total_categoria
    FROM ventas_limpias
    GROUP BY pedido_id, categoria
)
SELECT
    pedido_id,
    categoria,
    ROUND(total_categoria, 2) AS total_categoria,
    RANK() OVER (
        PARTITION BY categoria
        ORDER BY total_categoria DESC
    ) AS ranking_en_categoria
FROM total_por_pedido_categoria
ORDER BY categoria, ranking_en_categoria, pedido_id;


-- 8. MÉTRICA COMPLEMENTARIA:
-- ¿Qué categorías generan más facturación?
SELECT
    categoria,
    SUM(cantidad) AS unidades_vendidas,
    ROUND(SUM(importe_linea), 2) AS ventas_totales,
    ROUND(
        100.0 * SUM(importe_linea) / NULLIF(SUM(SUM(importe_linea)) OVER (), 0),
        2
    ) AS porcentaje_ventas
FROM ventas_limpias
GROUP BY categoria
ORDER BY ventas_totales DESC;


-- 9. CONTROL DE FECHAS PENDIENTES
-- Lista de pedidos que no pueden entrar en el análisis temporal.
SELECT pedido_id, cliente_id
FROM pedidos
WHERE fecha_pedido IS NULL
ORDER BY pedido_id;
