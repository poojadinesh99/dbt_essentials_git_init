-- Snowflake setup for the jaffle_shop dbt project
-- Run in a Snowflake worksheet as ACCOUNTADMIN

use role accountadmin;

-- Compute
create warehouse if not exists DBT_WH
  warehouse_size = 'XSMALL'
  auto_suspend = 60
  auto_resume = true;
grant usage on warehouse DBT_WH to role public;

-- Databases and schemas
create database if not exists raw;
create database if not exists analytics;
create schema if not exists raw.jaffle_shop;
create schema if not exists raw.stripe;

-- Customers
create or replace table raw.jaffle_shop.customers (
  id integer,
  first_name varchar,
  last_name varchar
);
copy into raw.jaffle_shop.customers (id, first_name, last_name)
from 's3://dbt-tutorial-public/jaffle_shop_customers.csv'
file_format = (type = 'CSV' field_delimiter = ',' skip_header = 1);

-- Orders
create or replace table raw.jaffle_shop.orders (
  id integer,
  user_id integer,
  order_date date,
  status varchar,
  _etl_loaded_at timestamp default current_timestamp
);
copy into raw.jaffle_shop.orders (id, user_id, order_date, status)
from 's3://dbt-tutorial-public/jaffle_shop_orders.csv'
file_format = (type = 'CSV' field_delimiter = ',' skip_header = 1);

-- Payments
create or replace table raw.stripe.payment (
  id integer,
  orderid integer,
  paymentmethod varchar,
  status varchar,
  amount integer,
  created date,
  _batched_at timestamp default current_timestamp
);
copy into raw.stripe.payment (id, orderid, paymentmethod, status, amount, created)
from 's3://dbt-tutorial-public/stripe_payments.csv'
file_format = (type = 'CSV' field_delimiter = ',' skip_header = 1);

-- Sanity checks: expect 100 / 99 / 120 rows
select count(*) from raw.jaffle_shop.customers;
select count(*) from raw.jaffle_shop.orders;
select count(*) from raw.stripe.payment;