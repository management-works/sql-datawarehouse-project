/** BUILDING the GOLD LAYER of Data Warehouse **/
-- Building the Customer dimension view ---
Create view gold.dim_customers as
Select  
ROW_NUMBER() over(order by cust_id) as customer_key,
ci.cust_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as firstname,
ci.cst_lastname as lastname,
la.cntry as country,
ci.cst_marital_status as marital_status,
Case when ci.cst_gndr !='n/a' then ci.cst_gndr
else coalesce(ca.gen,'N/A') 
end as gender,
ca.bdate as birthdate,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join 
silver.erp_cust_az12 ca
on ci.cst_key=ca.cid
left join 
silver.erp_loc_a101 la
on ci.cst_key=la.cid

-- Creating Product dimension view ---
Create view gold.dim_products as
Select 
ROW_NUMBER() over (order by pri.prd_start_dt,pri.prd_key) as product_key,
pri.prd_id as product_id,
pri.prd_key as product_number,
pri.prd_nm as product_name,
pri.category_id as category_id,
prc.cat as category,
prc.subcat as subcategory,
prc.maintenance,
pri.prd_cost as cost,
pri.prd_line as product_line,
pri.prd_start_dt as start_date
from silver.crm_prd_info pri
left join
silver.erp_px_cat_g1v2 prc
on pri.category_id=prc.id
where pri.prd_end_dt is null

-- Creating Fact Sales View --
Create view gold.fact_sales as
Select 
sls_ord_num as order_number,
gp.product_key,
gc.customer_key,
sls_order_dt as order_date,
sls_ship_dt as ship_date,
sls_due_dt as due_date,
sls_quantity as quantity,
sls_price as price,
sls_sales as sales_amount
from silver.crm_sales_details sd -- joining table with a view
left join gold.dim_products  gp
on sd.sls_prd_key=gp.product_number
left join gold.dim_customers gc
on sd.sls_cust_id=gc.customer_id



