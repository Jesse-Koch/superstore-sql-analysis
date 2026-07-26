create database superstore_db;
use superstore_db;

create table superstore (
row_id int not null auto_increment,
order_id varchar(100),
order_date datetime,
ship_date datetime,
ship_mode varchar(50),
customer_id varchar(100),
customer_name varchar(100),
segment varchar(25),
country varchar(50),
city varchar(100),
state varchar(100),
postal_code varchar(20),
region varchar(100),
product_id varchar(100),
category varchar(100),
sub_category varchar(100),
product_name varchar(100),
sales decimal(10,2),
quantity int,
discount decimal(4,2),
profit decimal(10,2),
primary key (row_id)
);

set global local_infile = 1;

load data local infile 'E:/et/Data Analysis/Datasets/New folder (4)/Sample - Superstore.csv'
into table superstore
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

truncate table superstore;

show warnings limit 20;

select count(*) from superstore;

select order_date, ship_date from superstore limit 50;

alter table superstore modify order_date varchar(20);
alter table superstore modify ship_date varchar(20);

load data local infile 'E:/et/Data Analysis/Datasets/New folder (4)/Sample - Superstore.csv'
into table superstore
character set latin1
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select distinct order_date
from superstore
where order_date not regexp '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
limit 200;

-- CLEANING
-- fixing order and ship date formats 
alter table superstore add column order_date_clean date;
alter table superstore add column ship_date_clean date;

update superstore
set order_date_clean = case
when order_date regexp '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$' then str_to_date(order_date, '%m-%d-%y')
when order_date regexp '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' then str_to_date(order_date, '%m/%d/%Y')
else null
end;

update superstore
set ship_date_clean = case
when ship_date regexp '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$' then str_to_date(ship_date, '%m-%d-%y')
when ship_date regexp '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' then str_to_date(ship_date, '%m/%d/%Y')
else null
end;

select order_date, order_date_clean, ship_date, ship_date_clean
from superstore
where ship_date_clean is null;

alter table superstore drop column order_date;
alter table superstore drop column ship_date;
alter table superstore change order_date_clean order_date date;
alter table superstore change ship_date_clean ship_date date;

select *
from superstore
limit 30;

-- ANALYSIS
select *
from superstore 
limit 50;

-- discount vs profit
select product_id, product_name, sum(sales) revenue
from superstore
group by product_id, product_name
order by revenue desc
limit 10;

select product_id, product_name, sum(sales) revenue
from superstore
group by product_id, product_name
order by revenue asc
limit 10;

select product_id, product_name, sum(profit) total_profit
from superstore
group by product_id, product_name
order by total_profit desc
limit 10;

select product_id, product_name, sum(profit) total_profit
from superstore
group by product_id, product_name
order by total_profit asc
limit 10;

select product_id, product_name, sum(sales) revenue, sum(profit) total_profit
from superstore
group by product_id, product_name
order by revenue desc
limit 10;

select product_id, product_name, sum(sales) revenue, sum(profit) total_profit
from superstore
group by product_id, product_name
order by total_profit desc
limit 10;

select discount, 
count(*) order_count, 
round(avg(profit), 2) avg_profit_per_order, 
sum(profit) total_profit
from superstore
group by discount
order by discount desc
limit 10;

select product_id, product_name, discount, sales, profit 
from superstore
where product_id in ('TEC-MA-10002412', 'OFF-BI-10004995', 'OFF-SU-10000151')
order by product_name, discount desc;

-- profitability by region
select region, 
count(*) order_count, 
sum(sales) revenue, 
sum(profit) total_profit, 
sum(quantity) total_quantity, 
round(avg(sales), 2) avg_revenue_per_order,
round(avg(profit), 2) avg_profit_per_order,
round((sum(profit) / sum(sales)) * 100, 2) profit_margin_pct
from superstore
group by region
order by revenue desc;

select region, round(avg(discount), 3) avg_discount
from superstore
group by region
order by avg_discount desc;

-- customer segment analysis
select segment, 
count(*) order_count, 
sum(sales) revenue, 
sum(profit) total_profit, 
sum(quantity) total_quantity, 
round(avg(sales), 2) avg_revenue_per_order,
round(avg(profit), 2) avg_profit_per_order,
round((sum(profit) / sum(sales)) * 100, 2) profit_margin_pct
from superstore
group by segment
order by revenue desc;

select segment, round(avg(discount), 3) avg_discount
from superstore
group by segment
order by avg_discount desc;

select segment, category, 
sum(sales) revenue, 
sum(profit) total_profit,
round((sum(profit) / sum(sales)) * 100, 2) profit_margin_pct
from superstore
group by segment, category
order by segment, category desc;

-- monthly sales trend
with monthly_revenue as 
(
select date_format(order_date, '%Y-%m') order_month,
sum(sales) revenue
from superstore
group by order_month
order by order_month
)
select order_month, revenue,
sum(revenue) over (order by order_month) running_total,
lag(revenue) over(order by order_month) prev_month_revenue,
round((((revenue - lag(revenue) over(order by order_month)) / lag(revenue) over(order by order_month)) * 100), 2) monthly_growth
from monthly_revenue;

-- customer lifetime sales
select customer_id, customer_name,
sum(sales) revenue,
sum(profit) total_profit
from superstore
group by customer_id, customer_name
order by revenue desc
limit 10;

select customer_id, customer_name, order_id, product_name, sales, discount, profit
from superstore 
where customer_id in ('SM-20320');