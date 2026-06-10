with stg as (

select count(*) cnt
from {{ ref('int_sessions') }}

),

mart as (

select sum(sessions) cnt
from {{ ref('mart_funnel') }}

)

select *
from stg,mart
where stg.cnt != mart.cnt