with source_data as (
    select *
    from {{ ref('raw_customer_customer_loyalty') }}
)

select
    customer_id,
    dev.hello_function(city) as augmented_city,
from source_data
