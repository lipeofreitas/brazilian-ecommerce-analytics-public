USE BrazilianEcommerceAnalytics;
GO

-- Orders
CREATE OR ALTER VIEW silver.orders AS
SELECT
  order_id,
  customer_id,
  order_status,
  TRY_CONVERT(datetime2(0), order_purchase_timestamp) AS order_purchase_ts,
  TRY_CONVERT(datetime2(0), order_approved_at) AS order_approved_ts,
  TRY_CONVERT(datetime2(0), order_delivered_carrier_date) AS order_delivered_carrier_ts,
  TRY_CONVERT(datetime2(0), order_delivered_customer_date) AS order_delivered_customer_ts,
  TRY_CONVERT(datetime2(0), order_estimated_delivery_date) AS order_estimated_delivery_date
FROM bronze.olist_orders_dataset;
GO