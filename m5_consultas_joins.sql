USE Ventas_Tech_DB

-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Junta las ventas con los clientes, productos y categorías para tener todo en una sola tabla gigante.
SELECT * FROM categorias
SELECT * FROM productos
SELECT * FROM clientes
SELECT * FROM ventas

SELECT 
    v.fecha_venta,
    c.id_cliente,
    p.nombre_producto,
    cat.descripcion AS categoria_descripcion, 
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS TOTAL
FROM ventas v
INNER JOIN clientes c ON c.id_cliente = v.id_cliente
INNER JOIN productos p ON p.id_producto = v.id_producto 
INNER JOIN categorias cat ON cat.id_categoria = p.id_categoria;
-- Hallazgo: Se consolida la tabla transaccional con sus dimensiones de clientes, productos y categorías, generando el dataset base desnormalizado para alimentar el modelo en Power BI.


-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Busca si hay algún cliente registrado que jamás haya comprado.
SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Hallazgo: La consulta arroja 0 registros debido a que el 100% de los clientes en la base cuenta con al menos una compra registrada (no se identifican clientes inactivos para CRM).


-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Revisa el catálogo para ver si quedó algún producto en el estante que nadie compró.
SELECT 
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
-- Hallazgo: No se registran productos sin ventas en el catálogo actual; todos los artículos presentan rotación comercial y salida en este conjunto de datos.


-- Consulta 4: Consolidado por canal (UNION ALL)
-- Inventa a mano una columna llamada 'canal' (separando las ventas por fecha) y las apila sin borrar nada con el UNION ALL.
SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Online' AS canal
    FROM ventas WHERE fecha_venta < '2024-03-10'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Presencial' AS canal
    FROM ventas WHERE fecha_venta >= '2024-03-10'
) AS consolidado
GROUP BY canal;
-- Hallazgo: Las ventas del canal Online alcanzaron $3,160.00 frente a $3,070.00 del canal Presencial, mostrando un volumen de facturación equilibrado entre ambos canales.
