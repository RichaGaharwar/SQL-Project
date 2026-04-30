 -- What does 'good' look like?
-- Import the dataset and do usual exploratory analysis steps like checking the structure & characteristics of the dataset:
-- Data type of all columns in the "customers" table.




-- Get the time range between which the orders were placed.

select max(order_purchase_timestamp) as recent_purchase, min(order_purchase_timestamp) as first_purchase,
DATE_DIFF(
    DATE(MAX(order_purchase_timestamp)), 
    DATE(MIN(order_purchase_timestamp)), 
    MONTH
  ) AS total_months_of_data,
from `target-sql-project-428910.target.orders`;
-- ______________________________________________________________________________________________
-- we have data for 25 months, first_purchase was on 4th sept 2016 and recent purchase was on 17th oct 2018
-- ______________________________________________________________________________________________



-- Count the Cities & States of customers who ordered during the given period.

select count(distinct geolocation_city) as no_of_cities, count(distinct geolocation_state) as no_of_state
from `target-sql-project-428910.target.geolocation`;
-- ______________________________________________________________________________________________
-- This dataset contains record of 8011 cities and 27 states
-- ______________________________________________________________________________________________



-- In-depth Exploration:

-- Is there a growing trend in the no. of orders placed over the past years?

create or replace view `target.orders_per_year` as 
select extract(year FROM order_purchase_timestamp) as years, 
count(order_id) as total_orders from `target-sql-project-428910.target.orders` 
where extract(year FROM order_purchase_timestamp) in (2016, 2017, 2018) 
group by 1;

select years, total_orders, lag(total_orders) over (order by years) as prev_year_orders,
round(((total_orders - lag(total_orders) over (order by years))/total_orders) *100,2) as year_on_year_order_volume_growth
from `target-sql-project-428910.target.orders_per_year`;
-- ______________________________________________________________________________________________
-- There was 99.27% and 16.5% increase in the number of orders in 2017 and 2018 respectively
-- ______________________________________________________________________________________________



-- Can we see some kind of monthly seasonality in terms of the no. of orders being placed?

select extract(month from order_purchase_timestamp) as month_num, FORMAT_DATE('%B', DATE(order_purchase_timestamp)) AS month_name,
count(order_id) as total_orders, lag(count(order_id)) over (order by extract(month from order_purchase_timestamp)) as prev_month_order_count,
ROUND(
    ((COUNT(order_id) - LAG(COUNT(order_id)) OVER (ORDER BY EXTRACT(MONTH FROM order_purchase_timestamp))) 
    / LAG(COUNT(order_id)) OVER (ORDER BY EXTRACT(MONTH FROM order_purchase_timestamp))) * 100, 2
  ) AS growth_rate
from `target-sql-project-428910.target.orders` 
group by 1, 2 
order by 1;

SELECT 
  EXTRACT(MONTH FROM order_purchase_timestamp) AS month_num, 
  FORMAT_DATE('%B', DATE(order_purchase_timestamp)) AS month_name,
  COUNT(order_id) AS total_orders, 
  LAG(COUNT(order_id)) OVER (ORDER BY EXTRACT(MONTH FROM order_purchase_timestamp)) AS prev_month_order_count,
  ROUND(
    ((COUNT(order_id) - LAG(COUNT(order_id)) OVER (ORDER BY EXTRACT(MONTH FROM order_purchase_timestamp))) 
    / LAG(COUNT(order_id)) OVER (ORDER BY EXTRACT(MONTH FROM order_purchase_timestamp))) * 100, 2
  ) AS growth_rate 
FROM `target-sql-project-428910.target.orders` 
GROUP BY 1, 2 
ORDER BY 1;
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________



-- During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
-- 0-6 hrs : Dawn
-- 7-12 hrs : Mornings
-- 13-18 hrs : Afternoon
-- 19-23 hrs : Night

select count(order_id) as total_orders, 
case 
when (extract(hour from order_purchase_timestamp)) between 0 and 6 then "dawn" 
when (extract(hour from order_purchase_timestamp)) between 7 and 12 then "morning"
when (extract(hour from order_purchase_timestamp)) between 13 and 18 then "afternoon"
else "night" 
end as time_of_the_day,
round((count(order_id)/ sum(count(order_id)) over ())*100,2) as percentage_contribution 
from `target-sql-project-428910.target.orders`
group by 2
order by 1 desc;
-- ______________________________________________________________________________________________
-- the most amount of orders are placed in afternoon (ie. between 13 to 18) which contributes to 38.35% of total orders recieved in a day
-- orders received at night (between 19 to 23) and (morning between 7 to 12) are almost equal in percentage (ie. 28.49% and 27.89% respectively)
-- wheereas at dawn lowest amount of orders are placed by the customers (ie. 5.27%)

-- most amount of focus should be at afternoon for advertisement and sales discounts
-- ______________________________________________________________________________________________



-- Evolution of E-commerce orders in the Brazil region:

-- Get the month on month no. of orders placed in each state.

create or replace view `target.monthly_orders_per_state` as 
 with basic_cal as (
select 
c.customer_state as state,
extract(month from order_purchase_timestamp) as months, 
count(o.order_id)as total_orders 
from `target-sql-project-428910.target.orders` o 
left join `target-sql-project-428910.target.customers` c
on o.customer_id = c.customer_id
group by c.customer_state, extract(month from order_purchase_timestamp)
)

select 
state, 
months, 
total_orders, 
sum(total_orders) over(partition by state order by months) as no_of_orders, 
round(safe_divide((total_orders - lag(total_orders) over(partition by state order by months)),
lag(total_orders) over(partition by state order by months))*100, 2) as monthly_prcnt_change
from basic_cal
ORDER BY state, months, no_of_orders desc;

SELECT * FROM `target.monthly_orders_per_state` 
ORDER BY state, months;
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________



-- How are the customers distributed across all the states?

select customer_state, count(customer_id) total_customers,
round((count(customer_id)/ sum(count(customer_id)) over ())*100,2) as customer_distribution_statewise
from `target-sql-project-428910.target.customers`
group by customer_state
order by total_customers desc
limit 10;
-- ______________________________________________________________________________________________
-- top 3 states who contribute to 66.6% of total customers are SP, RJ, MG 
-- Amongst them RJ has 42% of total customers 
-- ______________________________________________________________________________________________



-- Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others.

-- Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).
-- You can use the "payment_value" column in the payments table to get the cost of orders.

select 
sum(if(extract(year from order_purchase_timestamp)=2018,p.payment_value,0)) as total_2018,
sum(if(extract(year from order_purchase_timestamp)=2017,p.payment_value,0)) as total_2017,
round(
  (
    (sum(if(extract(year from order_purchase_timestamp)=2018,p.payment_value,0))-
    sum(if(extract(year from order_purchase_timestamp)=2017,p.payment_value,0))
    )
    /sum(if(extract(year from order_purchase_timestamp)=2017,p.payment_value,0))
    )*100
    ,2) as percentage_increase
from `target-sql-project-428910.target.orders` o 
join `target-sql-project-428910.target.payments` p
on o.order_id = p.order_id 
where extract(month from order_purchase_timestamp) between 1 and 8 
and extract(year from order_purchase_timestamp) in (2017,2018);
-- ______________________________________________________________________________________________
-- There is a 136% increase in cost of orders from year 2017 to 2018
-- ______________________________________________________________________________________________



-- Calculate the Total & Average value of order price for each state.

select g.geolocation_state as states,
count(distinct p.order_id) as orders,
round(sum(p.payment_value),0) as total_order_price,
round(avg(p.payment_value),0) as avg_order_price 
from `target-sql-project-428910.target.payments` p 
join `target-sql-project-428910.target.orders` o 
on p.order_id = o.order_id
join `target-sql-project-428910.target.customers` c 
on o.customer_id = c.customer_id
join `target-sql-project-428910.target.geolocation` g 
on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
group by 1
order by 3 desc
limit 10;
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________



-- Calculate the Total & Average value of order freight for each state.

select geolocation_state as states,
count(distinct oi.order_id) as no_of_orders,
round(sum(oi.freight_value),0) as total_freight_value,
round(avg(oi.freight_value),0) as avg_freight_value
from `target-sql-project-428910.target.order_items` oi 
join `target-sql-project-428910.target.sellers` s
on oi.seller_id = s.seller_id 
join `target-sql-project-428910.target.geolocation` g 
on s.seller_zip_code_prefix  = g.geolocation_zip_code_prefix 
group by 1
order by 2 desc
limit 10;
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________



-- Analysis based on sales, freight and delivery time.


-- Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
-- Also, calculate the difference (in days) between the estimated & actual delivery date of an order.
-- Do this in a single query.

-- You can calculate the delivery time and the difference between the estimated & actual delivery date using the given formula:
-- time_to_deliver = order_delivered_customer_date - order_purchase_timestamp
-- diff_estimated_delivery = order_delivered_customer_date - order_estimated_delivery_date

SELECT order_id, 
DATE(order_purchase_timestamp) AS purchase_date,
DATE(order_estimated_delivery_date) AS estimated_date,
DATE(order_delivered_customer_date) AS delivered_date,
TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS actual_time,
TIMESTAMP_DIFF(order_estimated_delivery_date, order_purchase_timestamp, DAY) AS estimated_time,
TIMESTAMP_DIFF(order_estimated_delivery_date, order_delivered_customer_date, DAY) AS diff_estimated_delivery,
CASE 
WHEN TIMESTAMP_DIFF(order_estimated_delivery_date, order_delivered_customer_date, DAY) > 0 THEN 'Early Delivery'
WHEN TIMESTAMP_DIFF(order_estimated_delivery_date, order_delivered_customer_date, DAY) < 0 THEN 'Late Delivery'
ELSE 'On Time'
END AS delivery_status
FROM `target-sql-project-428910.target.orders`
WHERE order_delivered_customer_date IS NOT NULL
LIMIT 10;
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________



-- Find out the top 5 states with the highest & lowest average freight value.

(select g.geolocation_state as states,
round(avg(oi.freight_value),2)avg_freight_value, 
"Highest" as Category
from `target-sql-project-428910.target.order_items` oi 
join `target-sql-project-428910.target.sellers` s
on oi.seller_id = s.seller_id 
join `target-sql-project-428910.target.geolocation` g 
on s.seller_zip_code_prefix  = g.geolocation_zip_code_prefix 
group by 1 
order by 2 desc 
limit 5)
union all
(select g.geolocation_state as states,
round(avg(oi.freight_value),2)avg_freight_value, 
"Lowest" as Category
from `target-sql-project-428910.target.order_items` oi 
join `target-sql-project-428910.target.sellers` s
on oi.seller_id = s.seller_id 
join `target-sql-project-428910.target.geolocation` g 
on s.seller_zip_code_prefix  = g.geolocation_zip_code_prefix 
group by 1 
order by 2 
limit 5);
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________



-- Find out the top 5 states with the highest & lowest average delivery time.

WITH state_delivery_times AS 
(SELECT c.customer_state AS states, 
AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_time
FROM `target-sql-project-428910.target.orders` o
JOIN `target-sql-project-428910.target.customers` c 
ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY 1)
(SELECT states, ROUND(avg_delivery_time, 2) AS avg_delivery_time, 
'Highest' AS category
FROM state_delivery_times
ORDER BY avg_delivery_time DESC
LIMIT 5)
UNION ALL
(SELECT states, ROUND(avg_delivery_time, 2) AS avg_delivery_time, 
'Lowest' AS category
FROM state_delivery_times
ORDER BY avg_delivery_time ASC
LIMIT 5)
ORDER BY category DESC, avg_delivery_time DESC;
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________



-- Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.
-- You can use the difference between the averages of actual & estimated delivery date to figure out how fast the delivery was for each state.

SELECT c.customer_state as States,
round(avg(TIMESTAMP_DIFF(order_estimated_delivery_date, order_delivered_customer_date, DAY)),2) AS avg_days_ahead_of_estimate
FROM `target-sql-project-428910.target.orders` o
join `target-sql-project-428910.target.customers` c
on o.customer_id = c.customer_id
WHERE order_delivered_customer_date IS NOT NULL 
group by 1 order by 2 LIMIT 5;
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________



-- Analysis based on the payments:

-- Find the month on month no. of orders placed using different payment types.

-- select payment_type, extract(month from order_purchase_timestamp) as Months, 
-- count(o.order_id) as total_orders, 
-- lag(count(o.order_id)) over (partition by payment_type, extract(month from order_purchase_timestamp) order by extract(month from order_purchase_timestamp)) as prev_month_order_count
-- from `target-sql-project-428910.target.payments` p 
-- join `target-sql-project-428910.target.orders` o
-- on p.order_id = o.order_id
-- group by 1,2
-- order by 1,2
-- limit 20;

SELECT 
    payment_type, 
    EXTRACT(MONTH FROM order_purchase_timestamp) AS Months, 
    COUNT(o.order_id) AS total_orders, 
    -- 1. Only partition by payment_type to see other months
    -- 2. Use the same COUNT() expression inside the LAG
    LAG(COUNT(o.order_id)) OVER (
        PARTITION BY payment_type 
        ORDER BY EXTRACT(MONTH FROM order_purchase_timestamp)
    ) AS prev_month_order_count
FROM `target-sql-project-428910.target.payments` p 
JOIN `target-sql-project-428910.target.orders` o ON p.order_id = o.order_id
GROUP BY 1, 2
ORDER BY 1, 2
LIMIT 20;
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________



-- The no. of orders placed on the basis of the payment installments that have been paid

select payment_installments, count(*) as order_count
from `target-sql-project-428910.target.payments`
group by payment_installments
order by order_count desc
limit 10;
-- ______________________________________________________________________________________________
-- 
-- ______________________________________________________________________________________________


