{{ config(materialized='materializedview') }}

SELECT user, count(*) as changes FROM {{ ref('recentchanges') }}  GROUP BY user