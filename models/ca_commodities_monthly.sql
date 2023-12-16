SELECT FORMAT_DATE('%Y-%m', date) AS date, M_BCPI AS `commodity_price_index_total`,
M_BCNE AS `commodity_price_index_excl_energy`,
M_ENER AS `commodity_price_index_energy`,
M_MTLS AS `commodity_price_index_metals_minerals`,
M_FOPR AS `commodity_price_index_forestry`,
M_AGRI AS `commodity_price_index_agriculture`,
M_FISH AS `commodity_price_index_fish`
FROM {{ source('raw', 'ca_commodity_price_index_monthly') }} ORDER BY date DESC