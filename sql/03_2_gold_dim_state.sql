USE BrazilianEcommerceAnalytics;
GO

CREATE OR ALTER VIEW gold.dim_state AS
WITH state_reference AS (
    SELECT *
    FROM (VALUES
        ('AC', 'Acre', 'North'),
        ('AL', 'Alagoas', 'Northeast'),
        ('AP', 'Amapa', 'North'),
        ('AM', 'Amazonas', 'North'),
        ('BA', 'Bahia', 'Northeast'),
        ('CE', 'Ceara', 'Northeast'),
        ('DF', 'Distrito Federal', 'Center-West'),
        ('ES', 'Espirito Santo', 'Southeast'),
        ('GO', 'Goias', 'Center-West'),
        ('MA', 'Maranhao', 'Northeast'),
        ('MT', 'Mato Grosso', 'Center-West'),
        ('MS', 'Mato Grosso do Sul', 'Center-West'),
        ('MG', 'Minas Gerais', 'Southeast'),
        ('PA', 'Para', 'North'),
        ('PB', 'Paraiba', 'Northeast'),
        ('PR', 'Parana', 'South'),
        ('PE', 'Pernambuco', 'Northeast'),
        ('PI', 'Piaui', 'Northeast'),
        ('RJ', 'Rio de Janeiro', 'Southeast'),
        ('RN', 'Rio Grande do Norte', 'Northeast'),
        ('RS', 'Rio Grande do Sul', 'South'),
        ('RO', 'Rondonia', 'North'),
        ('RR', 'Roraima', 'North'),
        ('SC', 'Santa Catarina', 'South'),
        ('SP', 'Sao Paulo', 'Southeast'),
        ('SE', 'Sergipe', 'Northeast'),
        ('TO', 'Tocantins', 'North')
    ) AS states(state_code, state_name, region)
),
state_centroid AS (
    SELECT
        geo_state AS state_code,
        AVG(CAST(geo_lat AS DECIMAL(10,7))) AS state_lat,
        AVG(CAST(geo_lng AS DECIMAL(10,7))) AS state_lng
    FROM gold.dim_geography_zip
    WHERE geo_state IS NOT NULL
      AND geo_lat IS NOT NULL
      AND geo_lng IS NOT NULL
    GROUP BY geo_state
)
SELECT
    s.state_code,
    s.state_name,
    s.region,
    'Brazil' AS country,
    CONCAT(s.state_name, ', Brazil') AS map_location,
    c.state_lat,
    c.state_lng
FROM state_reference AS s
LEFT JOIN state_centroid AS c
    ON c.state_code = s.state_code;
GO