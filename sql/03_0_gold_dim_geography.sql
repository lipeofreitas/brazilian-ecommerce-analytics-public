USE BrazilianEcommerceAnalytics;
GO


CREATE OR ALTER VIEW gold.dim_geography AS
WITH s_geo AS (
  SELECT
    geolocation_zip_code_prefix AS zip_code_prefix,
    geolocation_city AS geo_city,
    geolocation_state AS geo_state,
    geolocation_lat AS geo_lat,
    geolocation_lng AS geo_lng,
    ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix ORDER BY geolocation_lat, geolocation_lng) AS row_number
  FROM silver.geolocation
)
SELECT
  zip_code_prefix,
  geo_city,
  geo_state,
  geo_lat,
  geo_lng
FROM s_geo
WHERE row_number = 1;
GO
