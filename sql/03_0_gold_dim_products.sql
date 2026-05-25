USE BrazilianEcommerceAnalytics;
GO

CREATE OR ALTER VIEW gold.dim_product AS
SELECT
    product_id,

    product_category_name,

    CASE
        WHEN product_category_name IS NULL THEN 'Uncategorized'
        ELSE product_category_name
    END AS product_category_name_clean,

    CASE
        WHEN product_category_name IS NULL THEN 'Uncategorized'

        WHEN product_category_name IN (
            'cama_mesa_banho',
            'moveis_decoracao',
            'utilidades_domesticas',
            'casa_conforto',
            'casa_conforto_2',
            'casa_construcao',
            'moveis_sala',
            'moveis_quarto',
            'moveis_cozinha_area_de_servico_jantar_e_jardim',
            'moveis_colchao_e_estofado'
        ) THEN 'Home & Furniture'

        WHEN product_category_name IN (
            'informatica_acessorios',
            'eletronicos',
            'telefonia',
            'telefonia_fixa',
            'consoles_games',
            'pcs',
            'pc_gamer',
            'tablets_impressao_imagem'
        ) THEN 'Electronics & Tech'

        WHEN product_category_name IN (
            'eletrodomesticos',
            'eletrodomesticos_2',
            'eletroportateis',
            'portateis_casa_forno_e_cafe',
            'portateis_cozinha_e_preparadores_de_alimentos'
        ) THEN 'Appliances'

        WHEN product_category_name IN (
            'beleza_saude',
            'perfumaria',
            'fraldas_higiene'
        ) THEN 'Health & Beauty'

        WHEN product_category_name IN (
            'fashion_bolsas_e_acessorios',
            'fashion_calcados',
            'fashion_roupa_masculina',
            'fashion_roupa_feminina',
            'fashion_underwear_e_moda_praia',
            'fashion_esporte',
            'fashion_roupa_infanto_juvenil',
            'relogios_presentes',
            'malas_acessorios'
        ) THEN 'Fashion & Accessories'

        WHEN product_category_name IN (
            'esporte_lazer'
        ) THEN 'Sports & Leisure'

        WHEN product_category_name IN (
            'brinquedos',
            'bebes'
        ) THEN 'Kids & Baby'

        WHEN product_category_name IN (
            'automotivo'
        ) THEN 'Auto & Mobility'

        WHEN product_category_name IN (
            'ferramentas_jardim',
            'construcao_ferramentas_construcao',
            'construcao_ferramentas_seguranca',
            'construcao_ferramentas_jardim',
            'construcao_ferramentas_iluminacao',
            'construcao_ferramentas_ferramentas',
            'sinalizacao_e_seguranca'
        ) THEN 'Garden & Tools'

        WHEN product_category_name IN (
            'alimentos',
            'alimentos_bebidas',
            'bebidas'
        ) THEN 'Food & Beverage'

        WHEN product_category_name IN (
            'papelaria',
            'moveis_escritorio'
        ) THEN 'Office & Stationery'

        WHEN product_category_name IN (
            'livros_interesse_geral',
            'livros_tecnicos',
            'livros_importados',
            'musica',
            'cds_dvds_musicais',
            'dvds_blu_ray',
            'cine_foto',
            'audio'
        ) THEN 'Books & Media'

        WHEN product_category_name IN (
            'pet_shop'
        ) THEN 'Pets'

        WHEN product_category_name IN (
            'artes',
            'artes_e_artesanato',
            'artigos_de_festas',
            'artigos_de_natal',
            'instrumentos_musicais'
        ) THEN 'Art, Crafts & Party'

        WHEN product_category_name IN (
            'agro_industria_e_comercio',
            'industria_comercio_e_negocios',
            'market_place',
            'seguros_e_servicos'
        ) THEN 'Business & Industrial'

        WHEN product_category_name IN (
            'cool_stuff',
            'flores',
            'la_cuisine'
        ) THEN 'Other / Specialty'

        ELSE 'Other / Specialty'
    END AS product_category_group,

    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    zero_weight_flag,
    product_status
FROM silver.products;
GO