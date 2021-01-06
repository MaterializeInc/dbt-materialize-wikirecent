{{ config(materialized='table') }}

SELECT * FROM {{ ref('useredits') }} ORDER BY changes DESC LIMIT 10
