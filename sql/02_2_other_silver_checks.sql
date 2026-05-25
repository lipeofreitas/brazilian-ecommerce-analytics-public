-- since it is portuguese dataset. I want to make accent-free in the entire dataset. Here is some accent checking that I used. 
-- City column is  already accent-free so I did not update/apply to my main silver schema/query file.

SELECT DISTINCT
  customer_city
FROM silver.customers
WHERE customer_city IS NOT NULL
  AND PATINDEX('%[^ -~]%', customer_city COLLATE Latin1_General_100_BIN2) > 0;

-- checking different names for states (it should be all 2 letters, uppercase and together)
SELECT customer_state, count(*) AS state_count
FROM [BrazilianEcommerceAnalytics].[silver].[customers]
GROUP BY customer_state
HAVING COUNT(*) > 1;
