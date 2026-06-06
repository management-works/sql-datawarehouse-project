/* SQL Advanced Analytics Project */
Select 
Year(order_date) as order_year,
Month(order_date) as order_month,
SUM(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customer,
SUM(quantity) as total_quantity
from [gold].[fact_sales]
where order_date is not null
group by Year(order_date), Month(order_date)
order by Year(order_date), Month(order_date)

-- Aggregate them based on the granularity of the Month ---
--- The Latest Version of SQL Server supports DATETRUNC Function where as the Current Version does not hence we are using DATEFROMPARTS ---
Select 
DATEFROMPARTS(YEAR(order_date),Month(order_date),1) as order_month, 
SUM(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customer,
SUM(quantity) as total_quantity
from [gold].[fact_sales]
where order_date is not null
group by DATEFROMPARTS(YEAR(order_date),Month(order_date),1)
order by DATEFROMPARTS(YEAR(order_date),Month(order_date),1)

--- Formatting the Date Part and performing the previous operation ---
Select 
FORMAT(order_date,'yyyy-MMM') as order_date, 
SUM(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customer,
SUM(quantity) as total_quantity
from [gold].[fact_sales]
where order_date is not null
group by FORMAT(order_date,'yyyy-MMM')
order by FORMAT(order_date,'yyyy-MMM')

/* Cumulative Analysis: Aggregating Data progressively over the time */
-- Calculating total sales per month and running total of sales over time --
Select
order_month,
total_sales,
SUM(total_sales) over (order by order_month) as running_total,
AVG(avg_price) over (order by order_month) as moving_average
from(
select 
DATEFROMPARTS(YEAR(order_date),Month(order_date),1) as order_month, 
sum(sales_amount) as total_sales,
AVG(price) as avg_price
from gold.fact_sales
where order_date is not null
group by DATEFROMPARTS(YEAR(order_date),Month(order_date),1)
)t

-- Alternatively --
Select 
t.order_month,
t.total_sales,
SUM(t.total_sales) over (order by t.order_month Rows between unbounded preceding and current row) as running_total_sales
from(
SELECT
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
    SUM(sales_amount) AS total_sales,
    AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)t

-- Running Total for each Year : Reseting after every year--
Select
order_month,
total_sales,
avg_price,
SUM(total_sales) over (Partition by Year(order_month) order by order_month) as running_total_sales,
AVG(avg_price) over (Partition by Year(order_month) order by order_month) as moving_average_price
from(
select 
DATEFROMPARTS(YEAR(order_date),Month(order_date),1) as order_month, 
sum(sales_amount) as total_sales,
AVG(price) as avg_price
from gold.fact_sales
where order_date is not null
group by DATEFROMPARTS(YEAR(order_date),Month(order_date),1)
)t

/* Performance Analysis: Comparing the Current Value with the Target Value */
-- We will either use Aggregate window function or Value window function --
--Compare the each product sales with the average sales & previous year sales --

Select 
Year(fs.order_date) as order_year,
p.product_name,
sum(fs.sales_amount) as current_sales
from gold.fact_sales fs
left join gold.dim_products p
on fs.product_key = p.product_key
group by Year(fs.order_date), p.product_name
having Year(fs.order_date) is not null

-- Using CTE instead of sub-query --
with yearly_product_sales as(
Select 
Year(fs.order_date) as order_year,
p.product_name,
sum(fs.sales_amount) as current_sales
from gold.fact_sales fs
left join gold.dim_products p
on fs.product_key = p.product_key
where fs.order_date is not null
group by Year(fs.order_date), p.product_name
)
select 
order_year,
product_name,
current_sales,
AVG(current_sales) over (partition by product_name) as avg_sales,
current_sales-AVG(current_sales) over (partition by product_name) as diff_avg,
Case when current_sales-AVG(current_sales) over (partition by product_name) > 0 Then 'Above Avg'
    when current_sales-AVG(current_sales) over (partition by product_name) < 0 Then 'Below Avg'
    else 'Avg'
End as Avg_change,
LAG(current_sales) over (Partition by product_name order by order_year) as py_sales,
current_sales-LAG(current_sales) over (Partition by product_name order by order_year) as sales_change
from yearly_product_sales
order by product_name,order_year

/*Part to Whole Analysis: Analysing proportion of a part to the whole and how that proportion impacts.*/
-- Which Categories contibutes most to the overall sales? ---
with category_sales as (
    Select 
    p.category,
    SUM(fs.sales_amount) as total_category_sales
    from gold.fact_sales fs
    left join gold.dim_products p
    on fs.product_key= p.product_key
    group by p.category
)
select category, total_category_sales, 
SUM(total_category_sales) over() as total_sales,
Concat(Round((Cast(total_category_sales as float)/ SUM(total_category_sales) over())*100,3),'%') as proportional_sales
from category_sales;

/* Data Segmentations: Grouping data points based on specific range */
-- It is a Measure by Measure Comparison --
-- Segment Products into Cost Ranges and how many products falls in each ranges --
with product_segment as(
select 
product_key,
product_name,
category,
cost,
Case when cost <100 Then 'Below 100'
     When cost between 100 and 500 then '100-500' 
     When cost between 500 and 1000 then '500-1000'
     Else 'Above 1000'
End as cost_range
from gold.dim_products
) 
select cost_range, 
count(product_key) as total_products 
from product_segment
group by cost_range
order by 2 desc;

with product_sales_segment as(
select 
product_key,
product_name,
category,
cost,
Case when cost <100 Then 'Below 100'
     When cost between 100 and 500 then '100-500' 
     When cost between 500 and 1000 then '500-1000'
     Else 'Above 1000'
End as cost_range
from gold.dim_products
) 
Select ps.cost_range,count(ps.product_key) as total_products,AVG(fs.price) as avg_price,sum(fs.sales_amount) as total_sales from product_sales_segment ps
left join gold.fact_sales as fs
on ps.product_key=fs.product_key
where fs.order_date is not null
group by ps.cost_range;

-- Group Customers into 3 segments based on their spending beahviour --
With customer_spending as (
Select cs.customer_key,
sum(fs.sales_amount) as total_spend, 
MIN(fs.order_date) as first_order, MAX(fs.order_date) as latest_order,
DATEDIFF(MONTH,MIN(fs.order_date),MAX(fs.order_date)) as customer_lifespan
from gold.fact_sales fs
left join gold.dim_customers cs
on fs.customer_key=cs.customer_key
group by cs.customer_key
) 
Select Customer_Category, COUNT(customer_key) as total_customers
from(
    select cs.customer_key,  
    Case When cs.customer_lifespan >=12 and cs.total_spend >5000 Then 'VIP'
         When cs.customer_lifespan >=12 and cs.total_spend <=5000 Then 'Regular'
         Else 'New Customer'
    End Customer_Category
    from customer_spending cs
)t group by Customer_Category;

/* Reporting: Creating Customer Reports */
-- Captures key Customer Metrics and its behaviour --
Create view gold.customer_reports as
    with base_query1 as(
    Select 
    cs.customer_key,cs.customer_number,concat(cs.firstname,', ',cs.lastname) as customer_name,cs.birthdate,DATEDIFF(YEAR,cs.birthdate,GETDATE()) as current_age,
    fs.product_key,fs.order_number,fs.order_date,fs.quantity, fs.sales_amount
    from gold.fact_sales fs
    left join gold.dim_customers cs
    on fs.customer_key=cs.customer_key
    where fs.order_date is not null
    ), customer_aggregation as(
    /* Summarizes Key Metrics at customer Level */
    select 
    bq.customer_key,bq.customer_number,bq.customer_name,bq.current_age,
    Count(Distinct bq.order_number) as total_orders,
    SUM(bq.sales_amount) as total_sales,
    SUM(bq.quantity) as total_quantity,
    COUNT(Distinct bq.product_key) as total_products,
    MAX(bq.order_date)  as last_order_date,
    DATEDIFF(MONTH, MIN(bq.order_date),Max(bq.order_date)) as customer_lifespan
    from base_query1 bq
    group by bq.customer_key,bq.customer_number,bq.customer_name,bq.current_age
    ) select 
    ca.customer_key,ca.customer_number,ca.customer_name,ca.current_age,
    Case When ca.current_age < 20 Then 'Under 20'
         When ca.current_age between 20 and 29 then '20-29'
         When ca.current_age between 30 and 39 then '30-39'
         When ca.current_age between 40 and 49 then '40-49'
         Else '50 and above'
    End as age_group,
    ca.customer_lifespan,
    Case When customer_lifespan >=12 and total_sales >5000 Then 'VIP'
         When customer_lifespan >=12 and total_sales <=5000 Then 'Regular'
         Else 'New Customer'
    End Customer_Category,
    ca.total_orders,ca.total_sales,ca.total_quantity,ca.total_products,ca.last_order_date,
    DATEDIFF(MONTH,last_order_date,GETDATE()) as recency,
    -- compute average order value --
    Case When total_orders = 0 Then 0
        Else total_sales/total_orders 
        End as avg_order_value,
    -- compute average monthly spend --
    Case when customer_lifespan= 0 then total_sales
        else total_sales/customer_lifespan 
        end as avg_monthly_spend
    from customer_aggregation ca

/* Reporting: Creating Product Reports */
