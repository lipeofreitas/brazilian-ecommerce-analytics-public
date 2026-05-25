USE BrazilianEcommerceAnalytics;
GO

-- Fact
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
  soi.order_id AS sales_order_id,
  soi.order_item_id AS sales_order_item_id,
  so.customer_id AS sales_customer_id,
  soi.product_id AS sales_product_id,
  soi.seller_id AS sales_seller_id,
  so.order_status AS sales_order_status,
  CONVERT(int, FORMAT(so.order_purchase_ts, 'yyyyMMdd')) AS purchase_date_key,
  CONVERT(int, FORMAT(soi.shipping_limit_ts, 'yyyyMMdd')) AS shipping_limit_date_key,
  soi.price,
  soi.freight_value,
  (soi.price + soi.freight_value) AS gross_revenue
FROM silver.order_items AS soi
JOIN silver.orders AS so
  ON so.order_id = soi.order_id;
GO


-- ADD OTIF
-- check free shipping condition
-- lead time between purchase and delivery
-- compare lead time with shipping limit date
-- add payment & review info

