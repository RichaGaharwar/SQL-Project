-- Get the time range between which the orders were placed.

select min(order_purchase_timestamp)as first_order, max(order_purchase_timestamp)as last_order from `target-sql-project-428910.target.orders`;


-- Count the Cities & States of customers who ordered during the given period

select count(distinct(geolocation_city))cities, count(distinct(geolocation_state))states from `target-sql-project-428910.target.geolocation`;


-- Is there a growing trend in the no. of orders placed over the past years

select count(distinct(order_id)) as total_orders, extract(year FROM order_purchase_timestamp)years from `target-sql-project-428910.target.orders`
group by years order by years; #[yes, there is a growing trend in the no. of orders placed over the past years]


-- Can we see some kind of monthly seasonality in terms of the no. of orders being placed

select extract(month FROM order_purchase_timestamp) as months,
count(order_id) as total_order
from `target-sql-project-428910.target.orders`
group by months
order by total_order;


-- During what time of the day, do the Brazilian customers mostly place their orders? 
-- (Dawn, Morning, Afternoon or Night) 
-- [ *0-6 hrs : Dawn *7-12 hrs : Mornings *13-18 hrs : Afternoon *19-23 hrs : Night]

select 
case when extract(hour from order_purchase_timestamp) between 0 and 6 then "dawn"
when extract(hour from order_purchase_timestamp) between 7 and 12 then "mornings"
when extract(hour from order_purchase_timestamp) between 13 and 18 then "afternoon"
when extract(hour from order_purchase_timestamp) between 19 and 23 then "night"
end as time_of_day, count(*) as ordercount
from `target-sql-project-428910.target.orders`
group by time_of_day
order by ordercount desc
-- #[most no of orders are placed during afternoon]


-- Evolution of E-commerce orders in the Brazil region:
 
-- Get the month on month no. of orders placed in each state

select c.customer_state as states,
extract(month from order_purchase_timestamp) as months, 
count(*) as num_of_order
from `target-sql-project-428910.target.orders` o join `target-sql-project-428910.target.customers` c on c.customer_id = o.customer_id
group by states, months
order by num_of_order desc
limit 10


-- How are the customers distributed across all the states

select customer_state, count(*) no_of_customers
from `target-sql-project-428910.target.customers`
group by customer_state
order by no_of_customers desc
limit 10

-- Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others.
 
-- Get the % increase in the cost of orders from year 2017 to 2018(include months between Jan to Aug only.
-- You can use the "payment_value" column in the payments table to get the cost of orders)

WITH orders_2017 AS (
 SELECT o.order_id, p.payment_value
 FROM `target-sql-project-428910.target.orders` o JOIN `target-sql-project-428910.target.payments` p
 ON o.order_id = p.order_id
 WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2017
 AND EXTRACT(MONTH FROM o.order_purchase_timestamp) 
BETWEEN 1 AND 8),
orders_2018 AS (
 SELECT o.order_id, p.payment_value
 FROM`target-sql-project-428910.target.orders` o  JOIN `target-sql-project-428910.target.payments` AS p
 ON o.order_id = p.order_id
 WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
 AND EXTRACT(MONTH FROM o.order_purchase_timestamp) 
BETWEEN 1 AND 8)
SELECT
 (SUM(orders_2018.payment_value) - SUM(orders_2017.payment_value)) / SUM(orders_2017.payment_value) * 100 AS percentage_increase
FROM orders_2017, orders_2018
WHERE orders_2017.order_id = orders_2018.order_id



-- Calculate the Total & Average value of order price for each state.

select distinct c.customer_state as state, round(sum(p.payment_value),2) as total_value, round(avg(p.payment_value),2) as avg_value 
from `target-sql-project-428910.target.payments` p inner join `target-sql-project-428910.target.orders` o on p.order_id = o.order_id
inner join `target-sql-project-428910.target.customers` c on o.customer_id = c.customer_id
group by c.customer_state
order by total_value desc, avg_value desc
limit 10;


-- Calculate the Total & Average value of order freight for each state.

select c.customer_state as state, round(sum(oi.freight_value),2) total_value, round(avg(oi.freight_value),2) avg_value
from `target-sql-project-428910.target.order_items` oi inner join `target-sql-project-428910.target.orders` o on oi.order_id = o.order_id
inner join `target-sql-project-428910.target.customers` c on o.customer_id = c.customer_id
group by state
order by total_value desc
limit 10;


-- Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
-- Also, calculate the difference (in days) between the estimated & actual delivery date of an order.

-- Do this in a single query.You can calculate the delivery time and the difference between the estimated & actual delivery date using the given formula:
-- [time_to_deliver = order_delivered_customer_date-order_purchase_timestamp]
-- [diff_estimated_delivery = order_estimated_delivery_date-order_delivered_customer_date]
 
select (extract(second from order_delivered_customer_date)- extract(second from order_purchase_timestamp)/86400)as time_to_deliver,
date_diff(order_estimated_delivery_date, order_delivered_customer_date,day) as diff_estimated_delivery 
from `target-sql-project-428910.target.orders` 


-- Find out the top 5 states with the highest & lowest average freight value

select c.customer_state as state,round(avg(oi.freight_value),2) avg_value
from `target-sql-project-428910.target.order_items` oi inner join `target-sql-project-428910.target.orders` o on oi.order_id = o.order_id
inner join `target-sql-project-428910.target.customers` c on o.customer_id = c.customer_id
group by state
order by avg_value desc
limit 5;

select c.customer_state as state,round(avg(oi.freight_value),2) avg_value
from `target-sql-project-428910.target.order_items` oi inner join `target-sql-project-428910.target.orders` o on oi.order_id = o.order_id
inner join `target-sql-project-428910.target.customers` c on o.customer_id = c.customer_id
group by state
order by avg_value asc
limit 5;



-- Find out the top 5 states with the highest & lowest average delivery time

select c.customer_state as state, round(avg(extract(second from o.order_delivered_customer_date)- extract(second from o.order_purchase_timestamp)/86400),2) as avg_time_to_deliver
from `target-sql-project-428910.target.orders` o join `target-sql-project-428910.target.customers` c on o.customer_id = c.customer_id
group by state
order by avg_time_to_deliver desc
limit 5

select c.customer_state as state, round(avg(extract(second from order_delivered_customer_date)- extract(second from order_purchase_timestamp)/86400),2)as avg_time_to_deliver
from `target-sql-project-428910.target.orders` o join `target-sql-project-428910.target.customers` c on o.customer_id = c.customer_id
group by state
order by avg_time_to_deliver asc
limit 5



-- Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.

-- You can use the difference between the averages of actual & estimated delivery date to figure out how fast the delivery was for each state

select c.customer_state as states, 
avg(o.order_delivered_customer_date - o.order_purchase_timestamp) as avg_delivery_time
from `target-sql-project-428910.target.orders` o inner join `target-sql-project-428910.target.customers`c
on o.customer_id = c.customer_city
group by states
order by avg_delivery_time asc
limit 5;

 
-- Find the month on month no. of orders placed using different payment types
 
select extract(year from o.order_purchase_timestamp)as years, 
extract(month from o.order_purchase_timestamp)as months, 
p.payment_type as payment_type, 
count(distinct o.order_id) as no_of_orders 
from `target-sql-project-428910.target.orders` o 
inner join `target-sql-project-428910.target.payments` p
on o.order_id = p.order_id
group by years, months, p.payment_type
order by years, months
limit 10


-- Find the no. of orders placed on the basis of the payment installments that have been paid

select payment_installments, count(*) as order_count
from `target-sql-project-428910.target.payments`
group by payment_installments
order by order_count desc
limit 10;

