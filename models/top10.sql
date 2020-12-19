{{ config(materialized='view') }}

SELECT * FROM {{ ref('useredits') }} ORDER BY changes DESC LIMIT 10