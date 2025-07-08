with source_data as (
    select *
    from {{ ref('raw_customer_customer_loyalty') }}
)

SELECT transform_table.id, transform_table.new_value
  FROM source_data, TABLE(DBT_DEMO.DEV.transform_table(first_name, city))
