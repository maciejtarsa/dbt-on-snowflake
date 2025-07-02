USE ROLE ACCOUNTADMIN;
-- warehouse for execution
CREATE WAREHOUSE IF NOT EXISTS dbt_wh 
WITH INITIALLY_SUSPENDED=TRUE;
ALTER WAREHOUSE dbt_wh
SET WAREHOUSE_SIZE = XSMALL
AUTO_SUSPEND = 60;

USE WAREHOUSE_DBT_WH;

-- create database and schema to store dbt models
CREATE DATABASE IF NOT EXISTS dbt_demo;
CREATE SCHEMA IF NOT EXISTS dbt_demo.raw;
CREATE SCHEMA IF NOT EXISTS dbt_demo.dev;
CREATE SCHEMA IF NOT EXISTS dbt_demo.prod;
CREATE SCHEMA IF NOT EXISTS dbt_demo.integrations;

-- enable logging, tracing and metrics for the schemas created
ALTER SCHEMA dbt_demo.dev SET LOG_LEVEL = 'INFO';
ALTER SCHEMA dbt_demo.dev SET TRACE_LEVEL = 'ALWAYS';
ALTER SCHEMA dbt_demo.dev SET METRIC_LEVEL = 'ALL';

ALTER SCHEMA dbt_demo.prod SET LOG_LEVEL = 'INFO';
ALTER SCHEMA dbt_demo.prod SET TRACE_LEVEL = 'ALWAYS';
ALTER SCHEMA dbt_demo.prod SET METRIC_LEVEL = 'ALL';

-- create a secret for github token
USE SCHEMA dbt_demo.integrations;
CREATE OR REPLACE SECRET git_secret
  TYPE = password
  USERNAME = 'git_username'
  PASSWORD = 'git_token';

-- create api integration
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/my-account')
  ALLOWED_AUTHENTICATION_SECRETS = (dbt_demo.integrations.git_secret)
  ENABLED = TRUE;

-- create external access integration for dbt dependencies
-- Create NETWORK RULE for external access integration
CREATE OR REPLACE NETWORK RULE dbt_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  -- Minimal URL allowlist that is required for dbt deps
  VALUE_LIST = (
    'hub.getdbt.com',
    'codeload.github.com'
    );

-- Create EXTERNAL ACCESS INTEGRATION for dbt access to external dbt package locations

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION dbt_ext_access
  ALLOWED_NETWORK_RULES = (dbt_network_rule)
  ENABLED = TRUE;

-- create file format and stage
CREATE OR REPLACE FILE FORMAT dbt_demo.public.csv_ff 
type = 'csv';

CREATE OR REPLACE STAGE dbt_demo.public.s3load
COMMENT = 'Quickstarts S3 Stage Connection'
url = 's3://sfquickstarts/frostbyte_tastybytes/'
file_format = dbt_demo.public.csv_ff;
