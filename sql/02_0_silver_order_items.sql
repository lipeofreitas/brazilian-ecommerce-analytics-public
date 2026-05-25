USE BrazilianEcommerceAnalytics;
GO

-- Order items
CREATE OR ALTER VIEW silver.order_items AS
SELECT
  order_id,
  order_item_id,
  product_id,
  seller_id,
  TRY_CONVERT(datetime2(0), shipping_limit_date) AS shipping_limit_ts,
  TRY_CAST(price AS decimal(12,2)) AS price,
  TRY_CAST(freight_value AS decimal(12,2)) AS freight_value,
  -- Create a flagger for later (gold)
  CASE WHEN freight_value = 0 THEN 1 ELSE 0 END AS is_free_shipping
FROM bronze.olist_order_items_dataset;
GO

