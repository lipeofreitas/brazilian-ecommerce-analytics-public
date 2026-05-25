-- creating this table to add to PowerBI, so we can have a dimension with city/state/lat/lng for each zip code prefix. Great for map & bubble charts.
USE BrazilianEcommerceAnalytics;
GO

IF OBJECT_ID('gold.dim_geography_zip', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_geography_zip (
        zip_code_prefix      INT            NOT NULL PRIMARY KEY,
        geo_city             VARCHAR(100)    NULL,
        geo_state            VARCHAR(10)     NULL,
        geo_lat              DECIMAL(10,7)   NULL,
        geo_lng              DECIMAL(10,7)   NULL,
        geo_points_count     INT            NOT NULL
    );
END
GO

TRUNCATE TABLE gold.dim_geography_zip; -- wipes existing rows if necessary, but keeps the table structure and permissions intact
GO

-- reloads data from silver layer
INSERT INTO gold.dim_geography_zip (
    zip_code_prefix,
    geo_city,
    geo_state,
    geo_lat,
    geo_lng,
    geo_points_count
)
SELECT
    TRY_CAST(g.geolocation_zip_code_prefix AS INT) AS zip_code_prefix,
    MAX(g.geolocation_city)  AS geo_city,
    MAX(g.geolocation_state) AS geo_state,
    CAST(AVG(CAST(g.geolocation_lat AS DECIMAL(10,7))) AS DECIMAL(10,7)) AS geo_lat, -- centroid of multiple rows with same zip_code_prefix, if any. Better for BI than picking one random row with ROW_NUMBER() or similar
    CAST(AVG(CAST(g.geolocation_lng AS DECIMAL(10,7))) AS DECIMAL(10,7)) AS geo_lng, -- centroid of multiple rows with same zip_code_prefix, if any. Better for BI than picking one random row with ROW_NUMBER() or similar
    COUNT(*) AS geo_points_count
FROM silver.geolocation g
WHERE
    TRY_CAST(g.geolocation_zip_code_prefix AS INT) IS NOT NULL
    AND g.geolocation_lat IS NOT NULL
    AND g.geolocation_lng IS NOT NULL
GROUP BY
    TRY_CAST(g.geolocation_zip_code_prefix AS INT);
GO
