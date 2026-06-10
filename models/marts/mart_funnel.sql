select

    session_date,

    count(*) as sessions,

    countif(reached_item_view = 1) as item_views,
    countif(reached_cart = 1) as carts,
    countif(reached_checkout = 1) as checkouts,
    countif(reached_payment = 1) as payments,
    countif(reached_purchase = 1) as purchases,

       round(
        countif(reached_item_view = 1 and reached_cart = 1)
        /
        nullif(countif(reached_item_view = 1),0),
        4
    ) as item_to_cart_rate,

    round(
        countif(reached_cart = 1 and reached_checkout = 1)
        /
        nullif(countif(reached_cart = 1),0),
        4
    ) as cart_to_checkout_rate,

    round(
        countif(reached_checkout = 1 and reached_purchase = 1)
        /
        nullif(countif(reached_checkout = 1),0),
        4
    ) as checkout_to_purchase_rate

from {{ ref('stg_ga4__sessions') }}

group by 1