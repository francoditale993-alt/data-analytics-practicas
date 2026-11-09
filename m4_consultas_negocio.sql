USE Ventas_Tech_DB;

-- CONSULTA 1: Resumen ejecutivo mensual
SELECT 
	MONTH(fecha_venta) AS MES,
	SUM(precio_unitario * cantidad) AS TOTAL_FACTURADO,
	AVG(precio_unitario * cantidad) AS TICKET_PROMEDIO,
	COUNT(id_venta) AS CANTIDAD_PEDIDOS
FROM VENTAS
GROUP BY MONTH(fecha_venta);

-- CONSULTA 2: Ranking de productos
SELECT TOP 5
	id_producto,	
	SUM(precio_unitario * cantidad) AS TOTAL_FACTURADO,
	SUM(cantidad) AS UNIDADES_VENDIDAS
FROM VENTAS
GROUP BY id_producto
ORDER BY TOTAL_FACTURADO DESC;

-- CONSULTA 3: Clientes recurrentes
SELECT 
	id_cliente,
	COUNT(*) AS CANTIDAD_PEDIDOS,
	SUM(precio_unitario * cantidad) AS TOTAL_GENERADO
FROM VENTAS
WHERE id_cliente IS NOT NULL
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY CANTIDAD_PEDIDOS DESC;

-- CONSULTA 4: Productos por encima / por debajo del promedio
WITH facturacion_productos AS (
    SELECT 
        id_producto,
        SUM(cantidad * precio_unitario) AS total_producto
    FROM ventas
    GROUP BY id_producto
)
SELECT 
    id_producto,
    total_producto AS FACTURACION_TOTAL,
    CASE 
        WHEN total_producto >= (SELECT AVG(total_producto) FROM facturacion_productos) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS EVALUACION_PROMEDIO
FROM facturacion_productos
ORDER BY FACTURACION_TOTAL DESC;

-- 3 HALLAZGOS: 
/*
1) El producto con id_producto = 1 (Laptop Pro 15) es el que mayor facturación generó en el período, concentrando más de la mitad de los ingresos totales de la tienda.
2) Al analizar las unidades vendidas, el id_producto = 2 destaca enormemente frente al resto, triplicando y cuatriplicando la cantidad de unidades vendidas en comparación con los demás productos del catálogo.
3) En cuanto al comportamiento de los clientes, se observa una fuerte polarización: solo hay 2 clientes que superan los dos pedidos realizados, mientras que el resto de los compradores se mantiene por debajo de los $600 de gasto total.
*/