/* Creating Bronze Layer System */

/* Creating Tables for CRM System Customer Info */
/* To Check whether the table exists or not */
If OBJECT_ID('silver.crm_cust_info','U') is not null
	drop table silver.crm_cust_info;
Create Table silver.crm_cust_info (
	cust_id int, 
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50), 
	cst_gndr nvarchar(50), 
	cst_create_date Date,
    dwh_create_date Datetime2 Default GetDate() /* It is the derived column */
);
Go

/* Creating Tables for CRM System Product Info*/
If OBJECT_ID('silver.crm_prd_info','U') is not null
 drop table silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    category_id  NVARCHAR(50),
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,
    dwh_create_date Datetime2 Default GetDate() /* It is the derived column */
);
GO

/* Creating Tables for CRM System Sales Info*/
If OBJECT_ID('silver.crm_sales_details','U') is not null
 drop table silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt Date,
    sls_ship_dt  Date,
    sls_due_dt   Date,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date Datetime2 Default GetDate() /* It is the derived column */
);
GO

/* Creating Tables for ERP System Location Info */
If OBJECT_ID('silver.erp_loc_a101','U') is not null
 drop table silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50),
    dwh_create_date Datetime2 Default GetDate() /* It is the derived column */
);
GO

/* Creating Tables for ERP System Customer Info */
If OBJECT_ID('silver.erp_cust_az12','U') is not null
 drop table silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50),
    dwh_create_date Datetime2 Default GetDate() /* It is the derived column */
);
GO

/* Creating Tables for ERP System Product Category Info */
If OBJECT_ID('silver.erp_px_cat_g1v2','U') is not null
 drop table silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50),
    dwh_create_date Datetime2 Default GetDate() /* It is the derived column */
);
Go
