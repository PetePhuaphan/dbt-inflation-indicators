SELECT _REF_DATE_ AS date, VALUE AS unemployment_rate FROM {{ source('raw', 'ca_unemployment_rate_monthly') }}
WHERE Sex = 'Both sexes' AND Age_group = '15 years and over' ORDER BY date DESC