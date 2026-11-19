SELECT
    c.customer_state AS estado,

    COUNT(*) AS total_pedidos,

    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                o.order_delivered_customer_date
                - o.order_purchase_timestamp
            )) / 86400
        )::numeric,
        2
    ) AS media_dias_entrega,

    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date >
              o.order_estimated_delivery_date
    ) AS pedidos_atrasados,

    ROUND(
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date >
                  o.order_estimated_delivery_date
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