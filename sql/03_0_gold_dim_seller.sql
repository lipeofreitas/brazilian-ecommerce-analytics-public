USE BrazilianEcommerceAnalytics;
GO


CREATE OR ALTER VIEW gold.dim_sellers AS
SELECT
    seller_id,
    seller_city,
    seller_state,
    seller_zip_code_prefix,
    seller_zip_code_prefix_digits_flag,
    g.zip_code_prefix AS geo_zip_code_prefix,
    g.geo_city AS geo_city,
    g.geo_state AS geo_state
FROM silver.sellers AS s
LEFT JOIN gold.dim_geography AS g
  ON g.zip_code_prefix = s.seller_zip_code_prefix;
GO