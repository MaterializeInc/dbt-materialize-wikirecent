{{ config(materialized='table') }}

SELECT user, count(*) as changes FROM {{ ref('recentchanges') }}  GROUP BY user
