# Running dbt on Snowflake

We've seen dbt being run manually from local cli, in dbt cloud, using cosmos in managed airflow as well as in CI/CD pipelines. But Snowflake just introduces another way to run it natively on their platform, with their new Workspaces feature and git integration. Let's give it a go.

But why is it important? We've had client who were using Apache Airflow exlusivelt for orchestrating dbt workloads. We've had client who started with using CI/CD pipelines, but will eventually need to move into a more advanced orchestrator. In both cases while other compute is used for the orchestration, the meat of the compute is happening in Snowflake. Having an ability to run dbt natively on Snowflake could be a game changer for these workloads - completely removing the need to spend money and resources on other compute.

## Displaimer around dbt fushion

The timing on this new feature introduction in Snowflake is interesting. Very recently, dbt introduced dbt fushion, potentially discontinuing dbt core all together. This could be risky for anyone migrating their dbt core orchestration onto Snowflake.

## Minimum setup

Workspaces are currently in preview in Snowflake. Preview features will need to be enabled on your account. To check the status of your account, run
```bash
SELECT SYSTEM$GET_PREVIEW_ACCESS_STATUS();
```
And to enable it
```bash
SELECT SYSTEM$ENABLE_PREVIEW_ACCESS();
```
[More info about preview features](https://docs.snowflake.com/en/release-notes/preview-features)

TODO add notebook
Mention something about session policies

## Working example

## What about observability and alers

## Conclusions


Workspaces docs: https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces