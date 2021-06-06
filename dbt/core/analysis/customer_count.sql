with customers as (
    select *
    from {{ ref('raw_customer') }}
)

select count(1)
from customers