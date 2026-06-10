{{
    config(
        materialized='view'
    )
}}

select

    session_id,
    reached_item_view,
    reached_cart,
    reached_checkout,
    reached_shipping,
    reached_payment,
    reached_purchase,

    case
        when reached_item_view = 1
            and reached_cart = 0
        then 1
        else 0
    end as dropped_after_view,

    case
        when reached_cart = 1
            and reached_checkout = 0
        then 1
        else 0
    end as dropped_after_cart,

    case
        when reached_checkout = 1
            and reached_payment = 0
        then 1
        else 0
    end as dropped_after_checkout,

    case
        when reached_payment = 1
            and reached_purchase = 0
        then 1
        else 0
    end as dropped_after_payment

from {{ ref('int_sessions') }}
