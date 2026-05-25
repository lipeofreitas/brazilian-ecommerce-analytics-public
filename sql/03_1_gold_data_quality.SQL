-- Checking duplicates
SELECT 
    review_id,
    count(*) AS unique_reviews_count
FROM silver.order_reviews
GROUP BY review_id
HAVING count(*) > 1