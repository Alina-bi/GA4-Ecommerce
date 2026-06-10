{{ config(materialized='table') }}

with sessions as (

    select *
    from {{ ref('int_sessions') }}

),

first_session as (

    select *

    from sessions

    qualify row_number() over (
        partition by user_pseudo_id
        order by session_start_at
    ) = 1

),

user_metrics as (

    select

        user_pseudo_id,

        min(session_date) as first_seen,

        max(session_date) as last_seen,

        date_diff(
            max(session_date),
            min(session_date),
            day
        ) as lifetime_days,

        count(distinct session_id) as sessions,

        sum(session_revenue) as total_revenue,

        sum(transaction_count) as transactions,

        countif(converted) as purchase_sessions,

        round(
            sum(session_revenue)
            / nullif(sum(transaction_count),0),
            2
        ) as avg_order_value

    from sessions

    group by 1

)

select

    u.*,

    f.channel_group,
    f.source,
    f.medium,

    f.country,
    f.city,

    f.device_category,
    f.os,
    f.browser

from user_metrics u

left join first_session f
    using(user_pseudo_id)