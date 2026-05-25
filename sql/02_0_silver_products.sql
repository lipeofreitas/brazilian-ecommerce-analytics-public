USE BrazilianEcommerceAnalytics;
GO

-- Products
CREATE OR ALTER VIEW silver.products AS
WITH s_products AS (
    SELECT
        product_id,

        -- Clean
        NULLIF(TRIM(product_category_name), ' ') AS product_category_name,
        TRY_CAST(product_description_lenght AS INT) AS product_description_length,
        TRY_CAST(product_photos_qty AS INT) AS product_photos_qty,
        TRY_CAST(product_weight_g AS INT) AS product_weight_g,
        TRY_CAST(product_length_cm AS INT) AS product_length_cm,
        TRY_CAST(product_height_cm AS INT) AS product_height_cm,
        TRY_CAST(product_width_cm AS INT) AS product_width_cm
    FROM bronze.olist_products_dataset
)
SELECT
    product_id,
    product_category_name,

    NULLIF(product_description_length, 0) AS product_description_length,
    NULLIF(product_photos_qty, 0) AS product_photos_qty,
    product_weight_g,
    NULLIF(product_length_cm, 0) AS product_length_cm,
    NULLIF(product_height_cm, 0) AS product_height_cm,
    NULLIF(product_width_cm, 0) AS product_width_cm,

    -- Data quality flag
    CASE
        WHEN product_weight_g = 0 THEN 1
        ELSE 0
    END AS zero_weight_flag,

    -- Completeness classification
    CASE
        WHEN product_category_name IS NULL
         AND product_description_length IS NULL
         AND product_photos_qty IS NULL
         AND product_weight_g IS NULL
         AND product_length_cm IS NULL
         AND product_height_cm IS NULL
         AND product_width_cm IS NULL
            THEN 'incomplete'

        WHEN product_category_name IS NOT NULL
         AND product_description_length IS NOT NULL
         AND product_photos_qty IS NOT NULL
         AND product_weight_g IS NOT NULL
         AND product_length_cm IS NOT NULL
         AND product_height_cm IS NOT NULL
         AND product_width_cm IS NOT NULL
            THEN 'complete'

        ELSE 'partial'
    END AS product_status
FROM s_products;
GO
