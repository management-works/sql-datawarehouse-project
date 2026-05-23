/* We will Perform Data Insertion */
/* Data will flow from Bronze Layer Table to Silver Layer Table */
Create or alter Procedure silver.load_silver As
Begin
    Truncate Table silver.crm_cust_info;
    Print '>> Inserting Data into crm_customer_info'
    Insert into silver.crm_cust_info(cust_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
    Select 
    cust_id,cst_key, 
    TRIM(cst_firstname) as cust_firstname,TRIM(cst_lastname) as cust_lastname, /* Removing the Extra Spaces */
    CASE when Upper(Trim(cst_material_status))='M' then 'Married'
	     When Upper(Trim(cst_material_status))='s' then 'Single'
	     Else 'N/A'
    End as cst_marital_status,
    CASE when Upper(Trim(cst_gndr))='M' then 'Male'
	     When Upper(Trim(cst_gndr))='F' then 'Female'
	     Else 'N/A'
    End as cst_gndr,
    cst_create_date
    From(
    Select *,
    ROW_NUMBER() over(partition by cust_id order by cst_create_date desc) as flag_last
    from bronze.crm_cust_info 
    where cust_id is not null
    ) t where t.flag_last =1 

    /* Inserting Data to Silver - Product Info Table */
    Truncate Table silver.crm_prd_info;
    Print '>> Inserting Data into crm_product_info'
    Insert Into silver.crm_prd_info (prd_id, category_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt,prd_end_dt)
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

    /* Inserting Data to Silver - Sales Details Table */
    Truncate Table silver.crm_sales_details;
    Print '>> Inserting Data into crm_sales_details'
    Insert into silver.crm_sales_details (sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
    SELECT [sls_ord_num]
          ,[sls_prd_key]
          ,[sls_cust_id],
          Case when sls_order_dt=0 OR LEN(sls_order_dt) !=8 Then Null
                else Cast(Cast(sls_order_dt as varchar) as date)
                End as sls_order_dt,
          Case when sls_ship_dt=0 OR LEN(sls_ship_dt) !=8 Then Null
                else Cast(Cast(sls_ship_dt as varchar) as date)
                End as sls_ship_dt,
          Case when sls_due_dt=0 OR LEN(sls_due_dt) !=8 Then Null
                else Cast(Cast(sls_due_dt as varchar) as date)
                End as sls_due_dt,
          Case When sls_sales IS NULL or sls_sales<=0 or sls_sales!= sls_quantity* ABS(sls_price) then sls_quantity* ABS(sls_price)
                else sls_sales
                End sls_sales,
                [sls_quantity],
          Case When sls_price IS NULL or sls_price<=0 Then sls_sales/Nullif(sls_quantity,0)
                else sls_price
                End sls_price
      FROM [Datawarehouse].[bronze].[crm_sales_details]

    /* Inserting into Silver Layer - ERP Customer Data*/
    Truncate Table silver.erp_cust_az12;
    Print '>> Inserting Data into erp_cust_az12'
    Insert into silver.erp_cust_az12 (cid,bdate,gen)
    SELECT 
        Case when cid like 'NAS%' Then SUBSTRING(cid,4, len(cid))
        Else cid
        End as cid
        ,
        Case When bdate > GETDATE() Then Null
        Else bdate
        End as bdate,
        Case When Upper(Trim(gen)) IN('F','Female','FEMALE') then 'Female'
            When Upper(Trim(gen)) IN('M','Male','MALE') then 'Male'
            Else 'N/A'
        End as gen
      FROM [Datawarehouse].[bronze].[erp_cust_az12]


    /* Inserting into Silver Layer - ERP Customer Location */
    Truncate Table silver.erp_loc_a101;
    Print '>> Inserting Data into erp_loc_a101'
    Insert into silver.erp_loc_a101(cid,cntry)
    SELECT REPLACE(cid,'-','') as cid,
	    Case When TRIM(cntry) In('USA','US') Then 'United States'
		     When TRIM(cntry)='DE' Then 'Germany'
		     When TRIM(cntry) = '' or cntry IS NULL Then 'N/A'
	    else TRIM(cntry)
	    End as cntry
      FROM [Datawarehouse].[bronze].[erp_loc_a101]

    /* Inserting into Silver Layer - ERP Product Category */
    Truncate Table silver.erp_px_cat_g1v2 ;
    Print '>> Inserting Data into erp_px_cat_g1v2'
    Insert into silver.erp_px_cat_g1v2 (id,cat,subcat,maintenance)
    SELECT [id]
          ,[cat]
          ,[subcat]
          ,[maintenance]
      FROM [Datawarehouse].[bronze].[erp_px_cat_g1v2]
End


 
