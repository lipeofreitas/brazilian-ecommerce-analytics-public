-- 01 create db.sql

-- IF DB_ID('BrazilianEcommerceAnalytics') IS NULL
-- BEGIN
--     CREATE DATABASE BrazilianEcommerceAnalytics;
-- END;
-- GO


-- 02 create layers (schema)

-- USE BrazilianEcommerceAnalytics;
-- GO

-- CREATE SCHEMA bronze;
-- GO
-- CREATE SCHEMA silver;
-- GO
-- CREATE SCHEMA gold;
-- GO


-- 03 visibility test -> check schema creation

-- SELECT name
-- FROM sys.schemas
-- WHERE name IN ('bronze', 'silver', 'gold');

-- CREATE TABLE bronze._test_visibility (
--     id INT
-- );
