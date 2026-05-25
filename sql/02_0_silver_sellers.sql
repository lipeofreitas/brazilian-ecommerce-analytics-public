USE BrazilianEcommerceAnalytics;
GO

-- Sellers
CREATE OR ALTER VIEW silver.sellers AS
WITH s_sellers AS (
    SELECT
        seller_id,

        -- Clean 
        UPPER(TRIM(seller_city)) AS seller_city,
        UPPER(TRIM(seller_state)) AS seller_state,
        TRY_CAST(seller_zip_code_prefix AS INT) AS seller_zip_code_prefix

    FROM bronze.olist_sellers_dataset
)
SELECT
    seller_id,
    
    CASE 
        WHEN seller_city IS NULL THEN NULL
        ELSE seller_city
    END AS seller_city,

    CASE 
        WHEN seller_state IS NULL THEN NULL
        ELSE seller_state
    END AS seller_state,

    seller_zip_code_prefix,

  -- Flagging Zip codes prefixes with 4 or less digits (data quality)
    CASE 
        WHEN LEN(seller_zip_code_prefix) <= 4 THEN 1 
        ELSE 0 
    END AS seller_zip_code_prefix_digits_flag

FROM s_sellers;
GO