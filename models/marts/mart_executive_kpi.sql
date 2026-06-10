{{ config(materialized='table') }}

select

    session_date,

    count(*) as sessions,

    count(distinct user_pseudo_id) as users,

    countif(converted) as purchase_sessions,

    sum(session_revenue) as revenue,

        round(
        countif(converted)/count(*),
        4
    ) as cvr,

    round(
        sum(session_revenue)
        / nullif(countif(converted),0),
        2
    ) as aov,

    round(
    sum(session_revenue)
    /
    nullif(count(distinct user_pseudo_id),0),
    2) as arpu

from {{ ref('stg_ga4__sessions') }}

group by 1