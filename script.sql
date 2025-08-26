      -- Sales Perfomance Over the time --
select
order_date,
sales_amount
From
datawarehouseanalytics.gold_fact_sales
where order_date
order by order_date; 

  -- Total Sales --

select
order_date,
sum(sales_amount) as total_sales
From
datawarehouseanalytics.gold_fact_sales
where order_date
group by order_date
order by order_date;

  -- Total Sales per year --
  
select
year(order_date) as order_year,
sum(sales_amount) as total_sales
From
datawarehouseanalytics.gold_fact_sales
where order_date
group by year(order_date) 
order by year(order_date);

-- Total number of customer per year --
select
year(order_date) as order_year,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer
From
datawarehouseanalytics.gold_fact_sales
where order_date
group by year(order_date) 
order by year(order_date);

-- sales by month --
select
month(order_date) as order_month,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer
From
datawarehouseanalytics.gold_fact_sales
where order_date
group by  month(order_date)
order by  month(order_date);

-- By month and year combine --
select
DATE_FORMAT(order_date, '%Y-%m-01') AS order_date,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer
From
datawarehouseanalytics.gold_fact_sales
where order_date is not null
group by  DATE_FORMAT(order_date, '%Y-%m-01')
order by  DATE_FORMAT(order_date, '%Y-%m-01');

-- Cumlative Analysis --
-- Calculate the total sales per month--
select
      order_date,
      total_sales,
-- window function --
sum(total_sales) over (order by order_date) as running_total_sales
from
(
    SELECT 
         DATE_FORMAT(order_date, '%Y-%m-01') AS order_date,
         sum(sales_amount) as total_sales
        from gold_fact_sales
        where order_date is not null
         AND DATE_FORMAT(order_date, '%Y-%m-01') IS NOT NULL
        group by DATE_FORMAT(order_date, '%Y-%m-01')
        order by DATE_FORMAT(order_date, '%Y-%m-01')
) t;

-- Calculate the total sales per year--
select
      order_date,
      total_sales,
-- window function --
sum(total_sales) over (order by order_date) as running_total_sales
from
(
    SELECT 
         DATE_FORMAT(order_date, '%Y') AS order_date,
         sum(sales_amount) as total_sales
        from gold_fact_sales
        where order_date is not null
         AND DATE_FORMAT(order_date, '%Y') IS NOT NULL
        group by DATE_FORMAT(order_date, '%Y')
        order by DATE_FORMAT(order_date, '%Y')
) t;
-- The running total sales over time--
select
      order_date,
      total_sales,
-- window function --
sum(total_sales) over (order by order_date) as running_total_sales,
FLOOR(AVG(avg_price) over (ORDER BY order_date)) AS moving_average_price
from
(
    SELECT 
         DATE_FORMAT(order_date, '%Y') AS order_date,
         sum(sales_amount) as total_sales,
		avg(price) as avg_price
        from gold_fact_sales
        where order_date is not null
         AND DATE_FORMAT(order_date, '%Y') IS NOT NULL
        group by DATE_FORMAT(order_date, '%Y')
        order by DATE_FORMAT(order_date, '%Y')
) t;

       -- Performance Analysis --
-- Analyse the yearly performance of products by comparing each products sales to both its average sales 
-- performance  and pervious year sales

select
     f.order_date,
     p.product_name,
     f.sales_amount
From 
    gold_fact_sales f
left join
		gold_dim_products p
on
   f.product_key = p.product_key;

-- yearly performance of products --

select
     DATE_FORMAT(f.order_date, '%Y') AS order_year,
           p.product_name,

     sum(f.sales_amount) as current_sales     
From 
    gold_fact_sales f
left join
		gold_dim_products p
on
   f.product_key = p.product_key
WHERE DATE_FORMAT(f.order_date, '%Y') IS NOT NULL
GROUP BY DATE_FORMAT(f.order_date, '%Y'), p.product_name
order by DATE_FORMAT(f.order_date, '%Y'), p.product_name;

-- average sales performance --

select
     f.order_date,
     p.product_name,
     f.sales_amount
From 
    gold_fact_sales f
left join
		gold_dim_products p
on
   f.product_key = p.product_key;

-- yearly performance of products --
with 
yearly_sales_product as (
select
     DATE_FORMAT(f.order_date, '%Y') AS order_year,
           p.product_name,

     sum(f.sales_amount) as current_sales     
From 
    gold_fact_sales f
left join
		gold_dim_products p
on
   f.product_key = p.product_key
WHERE DATE_FORMAT(f.order_date, '%Y') IS NOT NULL
GROUP BY DATE_FORMAT(f.order_date, '%Y'), p.product_name
order by DATE_FORMAT(f.order_date, '%Y'), p.product_name
)
select 
      order_year,
      product_name,
      current_sales,
	  floor(avg(current_sales) over (partition by product_name)) as avg_sales,
      current_sales - floor(avg(current_sales) over (partition by product_name)) as diff_avg,
      
Case 
    when current_sales - floor(avg(current_sales) over (partition by product_name)) > 0 then 'below_avg'
    when current_sales - floor(avg(current_sales) over (partition by product_name)) < 0 then 'above_avg'
    else 'avg'
    end avg_change
from 
     yearly_sales_product
order by product_name,
		order_year;
        
-- compare pervious year sales --

with 
yearly_sales_product as (
select
     DATE_FORMAT(f.order_date, '%Y') AS order_year,
           p.product_name,

     sum(f.sales_amount) as current_sales     
From 
    gold_fact_sales f
left join
		gold_dim_products p
on
   f.product_key = p.product_key
WHERE DATE_FORMAT(f.order_date, '%Y') IS NOT NULL
GROUP BY DATE_FORMAT(f.order_date, '%Y'), p.product_name
order by DATE_FORMAT(f.order_date, '%Y'), p.product_name
)
select 
      order_year,
      product_name,
      current_sales,
	  floor(avg(current_sales) over (partition by product_name)) as avg_sales,
      current_sales - floor(avg(current_sales) over (partition by product_name)) as diff_avg,
      
Case 
    when current_sales - floor(avg(current_sales) over (partition by product_name)) > 0 then 'below_avg'
    when current_sales - floor(avg(current_sales) over (partition by product_name)) < 0 then 'above_avg'
    else 'avg'
    end avg_change,
    lag(current_sales) over (partition by product_name order by order_year) as py_sales,
    current_sales -  lag(current_sales) over (partition by product_name order by order_year) as diff_py,
    case 
    when current_sales -  lag(current_sales) over (partition by product_name order by order_year) > 0 then 'increase'
    when current_sales -  lag(current_sales) over (partition by product_name order by order_year) < 0 then 'decrease'
    else 'not_changed'
    end as py_change
from 
     yearly_sales_product
order by product_name,
		order_year;
        
  -- Analyze how an indivual part is performaning compared to overall, allow us to understand which category--
-- has the greatest impact on the business--

-- Which categories contribute most to overall sales --

with category_sales as(
select
      category,
      sum(sales_amount) as total_sales
From 
     gold_fact_sales f
left join 
        gold_dim_products p
on f.product_key = p.product_key
group by category)
select 
category,
total_sales,
sum(total_sales) over() as overall_sales,	
CONCAT(ROUND((total_sales / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_total
from
category_sales
order by total_sales desc;

-- Data Segmentation --
-- Segment product into cost ranges and count how many products fall into each segmnet ----
-- segemntation on cost --
with product_segment as (
select 
product_key,
product_name,
cost,
case
when cost < 100 then 'below 100'
when cost between 100 and 500 then '100-500'
when cost between 500 and 1000 then '500-1000'
else 'above 1000'
end as cost_range
from gold_dim_products
)
select cost_range,
count(product_key) as total_products
from product_segment
group by cost_range
order by total_products desc;

-- Group customers into three segments based on their spending behavior:
-- VIP: Customers with atleast 12 months of history and spending more than $5000.
-- Regular: Customers with atleast 12 months of history and spending $500 or less.
-- New:  Customers with lifespan of less than 12 months.
-- and find the total number of customer by each group --
with customer_spending as (
select c.customer_key,
       sum(f.sales_amount) as total_spending,
       min(order_date) as first_order,
       max(order_date) as last_order,
PERIOD_DIFF(
        DATE_FORMAT(MAX(f.order_date), '%Y%m'),
        DATE_FORMAT(MIN(f.order_date), '%Y%m')
    ) AS lifespan
from gold_fact_sales f 
left join gold_dim_customers c
on f.customer_key = c.customer_key
group by c.customer_key)

select customer_key, 
        total_spending,
        lifespan,
Case
when lifespan >= 12 and total_spending > 5000 then 'Vip'
when lifespan >= 12 and total_spending <= 5000 then 'Regular'
else 'New'
end as customer_segment
from customer_spending;

-- and find the total number of customer by each group --

with customer_spending as (
select c.customer_key,
       sum(f.sales_amount) as total_spending,
       min(order_date) as first_order,
       max(order_date) as last_order,
PERIOD_DIFF(
        DATE_FORMAT(MAX(f.order_date), '%Y%m'),
        DATE_FORMAT(MIN(f.order_date), '%Y%m')
    ) AS lifespan
from gold_fact_sales f 
left join gold_dim_customers c
on f.customer_key = c.customer_key
group by c.customer_key)

select 
Case
when lifespan >= 12 and total_spending > 5000 then 'Vip'
when lifespan >= 12 and total_spending <= 5000 then 'Regular'
else 'New'
end as customer_segment,
count(customer_key) as total_customer
from customer_spending
group by
case
when lifespan >= 12 and total_spending > 5000 then 'Vip'
when lifespan >= 12 and total_spending <= 5000 then 'Regular'
else 'New'
end;

/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- 1) Base Query: Retrieves core columns from tables
WITH base_query AS (
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        c.last_name,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        TIMESTAMPDIFF(YEAR, c.birthdate, f.order_date) AS age
    FROM gold_fact_sales f
    LEFT JOIN gold_dim_customers c ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),

-- 2) Customer Aggregations: Summarizes key metrics at the customer level
customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order,
        PERIOD_DIFF(
            DATE_FORMAT(MAX(order_date), '%Y%m'),
            DATE_FORMAT(MIN(order_date), '%Y%m')
        ) AS lifespan
    FROM base_query
    GROUP BY customer_key, customer_number, customer_name, age
)

-- 3) Final Output: Segmentation and Metrics
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE
        WHEN age < 20 THEN 'under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'Vip'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
PERIOD_DIFF(DATE_FORMAT(CURRENT_DATE, '%Y%m'), 
DATE_FORMAT(last_order, '%Y%m')) AS recency,
   last_order,
   total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
-- Compute average order value
case
when total_sales = 0 then '0'
else floor((total_sales / total_orders)) 
end as avg_order_value,

-- Compuate average monthly spend
case
when lifespan = 0 then total_sales
else floor( total_sales / lifespan)
end as avg_monthly_spend
FROM customer_aggregation;

/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/




WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold_fact_sales f
    LEFT JOIN  gold_dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),
product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        FLOOR(AVG(sales_amount / NULLIF(quantity, 0))) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    TIMESTAMPDIFF(MONTH, last_sale_date, CURRENT_DATE) AS recency,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    floor(Case 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END) AS avg_order_revenue,
    floor( CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END) AS avg_monthly_revenue
FROM product_aggregations;
