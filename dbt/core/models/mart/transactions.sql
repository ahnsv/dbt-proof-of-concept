{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

order_payments as (

    select
        order_id,

        {% for payment_method in payment_methods -%}
        sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount,
        {% endfor -%}

        sum(amount) as total_amount

    from payments

    group by 1

),
customers as (
    select *
    from {{ ref('stg_customers') }}
),

final as (

    select
        orders.order_id,
        orders.customer_id,
        customers.last_name || customers.first_name as customer_name,
        orders.order_date,
        orders.status,

        {% for payment_method in payment_methods -%}

        order_payments.{{ payment_method }}_amount,

        {% endfor -%}

        order_payments.total_amount as amount

    from orders

    left join order_payments using (order_id)
    left join customers on orders.customer_id = customers.customer_id

)

select * from final