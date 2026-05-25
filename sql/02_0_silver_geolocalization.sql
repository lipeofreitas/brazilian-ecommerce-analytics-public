-- Geolocation
CREATE OR ALTER VIEW silver.geolocation AS
WITH s_geo AS (
    SELECT
        geolocation_zip_code_prefix,

        -- Clean text once
        NULLIF(UPPER(TRIM(geolocation_state)), '') AS geolocation_state,
        NULLIF(UPPER(TRIM(geolocation_city)), '') AS geolocation_city,

        -- Cast once
        TRY_CAST(geolocation_lat AS DECIMAL(10,7)) AS geolocation_lat,
        TRY_CAST(geolocation_lng AS DECIMAL(10,7)) AS geolocation_lng
    FROM bronze.olist_geolocation_dataset
)

SELECT
    geolocation_zip_code_prefix,
    geolocation_state,
    geolocation_city,

    CASE
        WHEN geolocation_lat IS NOT NULL AND geolocation_lat > 0 THEN geolocation_lat * -1
        ELSE geolocation_lat
    END AS geolocation_lat,

    CASE
        WHEN geolocation_lng IS NOT NULL AND geolocation_lng > 0 THEN geolocation_lng * -1
        ELSE geolocation_lng
    END AS geolocation_lng
FROM s_geo;
GO
