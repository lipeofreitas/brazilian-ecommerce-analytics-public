USE BrazilianEcommerceAnalytics;
GO

CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
  customer_id,
  customer_unique_id,
  customer_city,
  customer_state,
  customer_zip_code_prefix,
  customer_zip_code_prefix_digits_flag,
  g.zip_code_prefix AS geo_zip_code_prefix,
  g.geo_city AS geo_city,
  g.geo_state AS geo_state
FROM silver.customers AS c
LEFT JOIN gold.dim_geography AS g
  ON g.zip_code_prefix = c.customer_zip_code_prefix;
GO