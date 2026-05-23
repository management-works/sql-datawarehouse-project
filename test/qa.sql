/** Performing Data Quality Checks for Bronze Layer Table -- Duplicate Values **/
Select cust_id, COUNT(*)
from bronze.crm_cust_info
group by cust_id
having COUNT(*)>1 or cust_id is null;

Select * from bronze.crm_cust_info where cust_id=29466;

Select 
*
From(
Select *,
ROW_NUMBER() over(partition by cust_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info 
) t where t.flag_last =1
/* For the Above Primary Key, we have three records, hence we will select the latest one using RANK function */

/** Check for Unwanted/Extra Spaces in the Text field **/
Select * from bronze.crm_cust_info
where cst_firstname != TRIM(cst_firstname)
union
Select * from bronze.crm_cust_info
where cst_lastname != TRIM(cst_lastname)

Select * from bronze.crm_cust_info
where cst_gndr != TRIM(cst_gndr)

/** Check for Data Standardization & Consistency **/
Select distinct(cst_gndr) from bronze.crm_cust_info

/* Checking & Inspecting Data Quality - bronze.crm_prd_info */
Select * from bronze.crm_prd_info;

/* Checking for Duplicates or Null in Primary Key*/
Select prd_id, COUNT(*) as unique_cnt_product_id from bronze.crm_prd_info
group by prd_id
having COUNT(*)>1 or prd_id is null

Select prd_key, COUNT(*) as unique_cnt_product_key from bronze.crm_prd_info
group by prd_key
having COUNT(*)>1

Select prd_nm from bronze.crm_prd_info
where prd_nm != TRIM(prd_nm);

SELECT [prd_id],
      Replace(SUBSTRING(prd_key,1,5),'-','_') as category_id,
      Substring(prd_key,7,len(prd_key)) as prd_key
      ,[prd_nm]
      ,ISNULL([prd_cost],0)as prd_cost
      ,
      Case When Upper(TRIM(prd_line))='M' then 'Mountain'
           When Upper(TRIM(prd_line))='R' then 'Road'
           When Upper(TRIM(prd_line))='S' then 'Other Sales'
           When Upper(TRIM(prd_line))='T' then 'Touring'
           Else 'N/A' end as prd_line
      ,Cast([prd_start_dt] as date) as prd_start_dt
      ,Cast(LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
  FROM [Datawarehouse].[bronze].[crm_prd_info]


Select distinct(id) from bronze.erp_px_cat_g1v2
Select * from bronze.crm_prd_info
select * from bronze.crm_sales_details
select COUNT(*) from bronze.crm_prd_info
/* Check for null or nrgative numbers in Cost Column*/
Select * from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null
Select distinct(prd_line) from bronze.crm_prd_info

Select prd_id,prd_key,prd_nm,prd_start_dt,prd_end_dt,
LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as test_start_date
from bronze.crm_prd_info 
where prd_key in ('AC-HE-HL-U509-R','AC-HE-HL-U509') 

Select * from bronze.crm_prd_info where prd_key in ('AC-HE-HL-U509-R','AC-HE-HL-U509') 
select prd_id,COUNT(*) from silver.crm_prd_info
group by prd_id
having COUNT(*)>1 or prd_id is null

Select * from silver.crm_prd_info where prd_end_dt<prd_start_dt;

Select * from bronze.crm_sales_details
Select * from bronze.crm_cust_info where cust_id='21768'
select * from bronze.crm_prd_info where prd_key like '%BK-R93R-62%'
Select * from bronze.crm_sales_details where sls_prd_key not in (select sls_prd_key from silver.crm_prd_info)
Select NULLIf(sls_order_dt,0) as sls_order_dt
from bronze.crm_sales_details where sls_order_dt<=0 or LEN(sls_order_dt) !=8
Select * from bronze.crm_sales_details where sls_ship_dt < sls_order_dt or sls_due_dt < sls_order_dt
Select * from silver.crm_sales_details 
where sls_sales != sls_quantity*sls_price
or sls_sales is null or sls_price is null or sls_quantity is null
or sls_sales <0 or sls_price <0 or sls_quantity <0

select * from bronze.erp_cust_az12
select * from silver.crm_cust_info 
Select distinct(gen) from silver.erp_cust_az12 

SELECT REPLACE(cid,'-','') as cid,
	Case When TRIM(cntry) In('USA','US') Then 'United States'
		 When TRIM(cntry)='DE' Then 'Germany'
		 When TRIM(cntry) = '' or cntry IS NULL Then 'N/A'
	else TRIM(cntry)
	End as cntry
  FROM [Datawarehouse].[bronze].[erp_loc_a101]


Select distinct 
cntry as old_country,
Case When TRIM(cntry) In('USA','US') Then 'United States'
		 When TRIM(cntry)='DE' Then 'Germany'
		 When TRIM(cntry) = '' or cntry IS NULL Then 'N/A'
	else TRIM(cntry)
	End as cntry
from bronze.erp_loc_a101
