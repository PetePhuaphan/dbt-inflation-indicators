{% set cpi_factors = ["All-items", "Food", "Shelter", "Household operations, furnishings and equipment", "Clothing and footwear", "Transportation", "Health and personal care", "Recreation, education and reading", "Alcoholic beverages, tobacco products and recreational cannabis"] %}

WITH
{% for cpi_factor in cpi_factors %}
    `{{cpi_factor}}Data` AS (
    SELECT 
        _REF_DATE_, 
        VALUE AS `{{cpi_factor}}`
    FROM 
        {{ source('raw', 'ca_cpi_monthly') }}
    WHERE 
        `Products_and_product_groups` = '{{cpi_factor}}'
    )
    {%- if not loop.last -%}
    ,
    {%- endif -%}
{% endfor %}

SELECT 
    a._REF_DATE_ AS `date`,
    a.`All-items` AS `cpi`, 
    f.food as food_price_index,
    sh.shelter as shelter_price_index,
    ho.`Household operations, furnishings and equipment` AS `household_price_index`,
    co.`Clothing and footwear` AS `clothing_price_index`,
    tr.transportation AS transportation_price_index,
    he.`Health and personal care` AS `healthcare_price_index`,
    re.`Recreation, education and reading` AS `recreation_price_index`,
    al.`Alcoholic beverages, tobacco products and recreational cannabis` AS `alcohol_price_index`
FROM 
    `All-itemsData` a
LEFT JOIN 
    FoodData f ON a._REF_DATE_ = f._REF_DATE_
LEFT JOIN 
    ShelterData sh ON a._REF_DATE_ = sh._REF_DATE_
LEFT JOIN 
    `Household operations, furnishings and equipmentData` ho ON a._REF_DATE_ = ho._REF_DATE_
LEFT JOIN 
    `Clothing and footwearData` co ON a._REF_DATE_ = co._REF_DATE_
LEFT JOIN 
    `TransportationData` tr ON a._REF_DATE_ = tr._REF_DATE_
LEFT JOIN 
    `Health and personal careData` he ON a._REF_DATE_ = he._REF_DATE_
LEFT JOIN 
    `Recreation, education and readingData` re ON a._REF_DATE_ = re._REF_DATE_
LEFT JOIN 
    `Alcoholic beverages, tobacco products and recreational cannabisData` al ON a._REF_DATE_ = al._REF_DATE_
ORDER BY `date` DESC