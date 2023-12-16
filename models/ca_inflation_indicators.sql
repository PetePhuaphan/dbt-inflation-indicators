{{ config(
    materialized='table',
    )
}}

{% set commodities = ["commodity_price_index_total", "commodity_price_index_excl_energy", "commodity_price_index_energy", "commodity_price_index_metals_minerals", "commodity_price_index_forestry", "commodity_price_index_agriculture", "commodity_price_index_fish"] %}

SELECT f.*, i.Canadian_Interest_Rates AS interest_rate, u.unemployment_rate AS unemployment_rate,
{% for commodity in commodities %}
    c.{{commodity}}
    {%- if not loop.last -%}
    ,
    {%- endif -%}
{% endfor %}
FROM {{ ref('ca_cpi_factors_monthly') }} f

LEFT JOIN {{ source('raw', 'ca_interest_rate_monthly') }} i
ON f.date = i.Date

LEFT JOIN  {{ ref('ca_unemployment_monthly') }} u
ON f.date = u.date

LEFT JOIN  {{ ref('ca_commodities_monthly') }} c
ON f.date = c.date