USE BrazilianEcommerceAnalytics;
GO


CREATE OR ALTER VIEW gold.fact_payments AS
SELECT
  order_id
  payment_sequential,
  payment_type,
  payment_installments,
  payment_value
FROM silver.order_payments;
GO