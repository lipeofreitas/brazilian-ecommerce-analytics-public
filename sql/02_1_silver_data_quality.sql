-- Checking for total rows and nulls in key columns between bronze and silver layers
SELECT 'bronze_orders' AS table_name,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_order_purchase_ts
FROM bronze.olist_orders_dataset
UNION ALL
SELECT 'silver_orders' AS table_name,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN order_purchase_ts IS NULL THEN 1 ELSE 0 END) AS null_order_purchase_ts
FROM silver.orders;

SELECT 'bronze_customers' AS table_name,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_customer_unique_id,
  SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_customer_zip_code_prefix,
  SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_customer_city,
  SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_customer_state
FROM bronze.olist_customers_dataset
UNION ALL
SELECT 'silver_customers' AS table_name,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_customer_unique_id,
  SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_customer_zip_code_prefix,
  SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_customer_city,
  SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_customer_state
FROM silver.customers;

SELECT 'bronze_order_items' AS table_name,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS null_order_item_id,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
  SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
  SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS null_shipping_limit_date,
  SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
  SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight_value
FROM bronze.olist_order_items_dataset
UNION ALL
SELECT 'silver_order_items' AS table_name,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS null_order_item_id,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
  SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
  SUM(CASE WHEN shipping_limit_ts IS NULL THEN 1 ELSE 0 END) AS null_shipping_limit_date,
  SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
  SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight_value
FROM silver.order_items;

-- SELECT 'bronze_products' AS table_name,
--   COUNT(*) AS total_rows,
--   SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_product_category_name,
--   SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS null_product_description_length,
--   SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS null_product_photos_qty,
--   SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_product_weight_g,
--   SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_product_length_cm,
--   SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_product_height_cm,
--   SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_product_width_cm
-- FROM bronze.olist_products_dataset
-- UNION ALL
SELECT 'silver_products' AS table_name,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_product_category_name,
  SUM(CASE WHEN product_description_length IS NULL THEN 1 ELSE 0 END) AS null_product_description_length,
  SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS null_product_photos_qty,
  SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_product_weight_g,
  SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_product_length_cm,
  SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_product_height_cm,
  SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_product_width_cm,
  SUM(CASE WHEN product_status = 'complete' THEN 1 ELSE 0 END) AS status_complete,
  SUM(CASE WHEN product_status = 'partial' THEN 1 ELSE 0 END) AS status_partial,
  SUM(CASE WHEN product_status = 'incomplete' THEN 1 ELSE 0 END) AS status_incomplete
FROM silver.products;

