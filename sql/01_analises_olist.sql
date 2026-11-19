/*
Projeto: Análise de dados de e-commerce brasileiro (Olist)
Banco: PostgreSQL
Objetivo: analisar vendas, avaliações e desempenho logístico.

Observação:
- Os scripts usam as tabelas importadas do dataset Olist.
- Execute as consultas na ordem ou individualmente.
- Valores financeiros usam price (produtos); frete é analisado separadamente.
*/

-- =========================================================
-- 01. VISÃO GERAL DOS PEDIDOS
-- =========================================================

-- Quantidade de pedidos por status
SELECT
    order_status,
    COUNT(*) AS quantidade
FROM olist_orders
GROUP BY order_status
ORDER BY quantidade DESC;

-- Percentual de pedidos cancelados
SELECT
    COUNT(*) FILTER (WHERE order_status = 'canceled') AS pedidos_cancelados,
    COUNT(*) AS total_pedidos,
    ROUND(
        COUNT(*) FILTER (WHERE order_status = 'canceled') * 100.0 / COUNT(*),
        2
    ) AS percentual_cancelados
FROM olist_orders;

-- Evolução mensal de pedidos
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS mes,
    COUNT(*) AS quantidade_pedidos
FROM olist_orders
GROUP BY mes
ORDER BY mes;


-- =========================================================
-- 02. ANÁLISE FINANCEIRA
-- =========================================================

-- Receita de produtos, frete e total incluindo frete
SELECT
    ROUND(SUM(price)::numeric, 2) AS faturamento_produtos,
    ROUND(SUM(freight_value)::numeric, 2) AS total_frete,
    ROUND(SUM(price + freight_value)::numeric, 2) AS total_com_frete
FROM olist_order_items;

-- Receita por categoria, preservando produtos sem categoria informada
SELECT
    COALESCE(p.product_category_name, 'Sem categoria informada') AS categoria,
    ROUND(SUM(i.price)::numeric, 2) AS faturamento
FROM olist_order_items i
INNER JOIN olist_products p
    ON i.product_id = p.product_id
GROUP BY categoria
ORDER BY faturamento DESC;

-- Ticket médio de produtos por pedido (todos os pedidos com itens)
SELECT
    ROUND(AVG(valor_pedido)::numeric, 2) AS ticket_medio
FROM (
    SELECT
        order_id,
        SUM(price) AS valor_pedido
    FROM olist_order_items
    GROUP BY order_id
) AS pedidos;

-- Ticket médio de produtos por pedido entregue (com itens registrados)
SELECT
    ROUND(AVG(valor_pedido)::numeric, 2) AS ticket_medio_entregues
FROM (
    SELECT
        i.order_id,
        SUM(i.price) AS valor_pedido
    FROM olist_order_items i
    INNER JOIN olist_orders o
        ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY i.order_id
) AS pedidos_entregues;


-- =========================================================
-- 03. AVALIAÇÕES DOS CLIENTES
-- =========================================================

-- Nota média das avaliações
SELECT
    ROUND(AVG(review_score)::numeric, 2) AS nota_media
FROM olist_order_reviews;

-- Distribuição das avaliações por nota
SELECT
    review_score,
    COUNT(*) AS quantidade
FROM olist_order_reviews
GROUP BY review_score
ORDER BY review_score;

-- Percentual de avaliações negativas (notas 1 e 2)
SELECT
    COUNT(*) FILTER (
        WHERE review_score IN (1, 2)
    ) AS avaliacoes_negativas,
    COUNT(*) AS total_avaliacoes,
    ROUND(
        COUNT(*) FILTER (
            WHERE review_score IN (1, 2)
        ) * 100.0 / COUNT(*),
        2
    ) AS percentual_negativo
FROM olist_order_reviews;

-- Percentual mensal de avaliações negativas
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS mes,
    COUNT(*) FILTER (
        WHERE r.review_score IN (1, 2)
    ) AS negativas,
    COUNT(*) AS total_avaliacoes,
    ROUND(
        COUNT(*) FILTER (
            WHERE r.review_score IN (1, 2)
        ) * 100.0 / COUNT(*),
        2
    ) AS percentual_negativo
FROM olist_order_reviews r
INNER JOIN olist_orders o
    ON r.order_id = o.order_id
GROUP BY mes
ORDER BY mes;


-- =========================================================
-- 04. ANÁLISE LOGÍSTICA
-- =========================================================

-- Quantidade e percentual de pedidos entregues com atraso
SELECT
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date > order_estimated_delivery_date
    ) AS pedidos_atrasados,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date <= order_estimated_delivery_date
    ) AS pedidos_no_prazo,
    COUNT(*) AS total_entregues,
    ROUND(
        COUNT(*) FILTER (
            WHERE order_delivered_customer_date > order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS percentual_atrasados
FROM olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

-- Taxa de atraso por estado do cliente (mínimo de 500 pedidos)
SELECT
    c.customer_state AS estado,
    COUNT(*) AS total_pedidos,
    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) AS pedidos_atrasados,
    ROUND(
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS percentual_atrasados
FROM olist_orders o
INNER JOIN olist_customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 500
ORDER BY percentual_atrasados DESC;

-- Tempo médio entre a compra e a entrega por estado (mínimo de 500 pedidos)
SELECT
    c.customer_state AS estado,
    ROUND(
        (
            AVG(
                EXTRACT(EPOCH FROM (
                    o.order_delivered_customer_date - o.order_purchase_timestamp
                )) / 86400
            )
        )::numeric,
        2
    ) AS media_dias_entrega
FROM olist_orders o
INNER JOIN olist_customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 500
ORDER BY media_dias_entrega DESC;

-- Painel consolidado de indicadores logísticos por estado
SELECT
    c.customer_state AS estado,
    COUNT(*) AS total_pedidos,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                o.order_delivered_customer_date - o.order_purchase_timestamp
            )) / 86400
        )::numeric,
        2
    ) AS media_dias_entrega,
    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) AS pedidos_atrasados,
    ROUND(
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS percentual_atrasados
FROM olist_orders o
INNER JOIN olist_customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 500
ORDER BY percentual_atrasados DESC;
