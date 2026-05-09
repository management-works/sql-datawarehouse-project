/* Performing Bulk Insert to the Databases from our file system */
/* Inserting Data to CRM Customer Info Table - Full Load */
Truncate Table bronze.crm_cust_info;
Bulk insert bronze.crm_cust_info 
from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_crm\cust_info.csv'
with(
	FIRSTROW=2,
	Fieldterminator=',',
	Tablock
);

select COUNT(*) from bronze.crm_cust_info;

/* Inserting Data to CRM Product Info Table - Full Load */
Truncate Table bronze.crm_prd_info;
Bulk insert bronze.crm_prd_info 
from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_crm\prd_info.csv'
with(
	FIRSTROW=2,
	Fieldterminator=',',
	Tablock
);

select COUNT(*) from bronze.crm_prd_info;

/* Inserting Data to CRM Sales Info Table - Full Load */
Truncate Table bronze.crm_sales_details;
Bulk insert bronze.crm_sales_details 
from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_crm\sales_details.csv'
with(
	FIRSTROW=2,
	Fieldterminator=',',
	Tablock
);

select COUNT(*) from bronze.crm_sales_details;

/* Inserting Data to ERP Customer Info Table - Full Load */
Truncate Table bronze.erp_cust_az12
Bulk insert bronze.erp_cust_az12
from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_erp\CUST_AZ12.csv'
with(
	FIRSTROW=2,
	Fieldterminator=',',
	Tablock
);

select COUNT(*) from bronze.erp_cust_az12;

/* Inserting Data to ERP Location Info Table - Full Load */
Truncate Table bronze.erp_loc_a101;
Bulk insert bronze.erp_loc_a101 
from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_erp\LOC_A101.csv'
with(
	FIRSTROW=2,
	Fieldterminator=',',
	Tablock
);

select COUNT(*) from bronze.erp_loc_a101;


/* Inserting Data to ERP Product Category Info Table - Full Load */
Truncate Table bronze.erp_px_cat_g1v2;
Bulk insert bronze.erp_px_cat_g1v2 
from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_erp\PX_CAT_G1V2.csv'
with(
	FIRSTROW=2,
	Fieldterminator=',',
	Tablock
);

select COUNT(*) from bronze.erp_px_cat_g1v2;
