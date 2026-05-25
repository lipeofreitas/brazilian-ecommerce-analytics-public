USE BrazilianEcommerceAnalytics;
GO

CREATE OR ALTER VIEW gold.fact_order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_ts,
    CAST(price AS DECIMAL(18,2)) AS item_price,
    CAST(freight_value AS DECIMAL(18,2)) AS item_freight_value,
    CAST(ISNULL(price,0) + ISNULL(freight_value,0) AS DECIMAL(18,2)) AS item_gross_revenue
FROM silver.order_items;
GO