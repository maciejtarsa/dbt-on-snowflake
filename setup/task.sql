CREATE OR REPLACE TASK dbt_demo.dev.run_prepped_data_dbt
        WAREHOUSE=dbt_wh
        SCHEDULE ='USING CRON 5 * * * * America/Los_Angeles'
      AS
  EXECUTE DBT PROJECT DBT_PROJECT_DEV ARGS='run --select customer_loyalty_metrics --target dev';
  ALTER TASK dbt_demo.dev.run_prepped_data_dbt RESUME;