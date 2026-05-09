/* Create a Stored Procedure to automate the Data Insertion */

Create or alter procedure bronze.load_bronze as 
Begin
	Declare @start_time DateTime, @end_time DateTime, @start_batch_time DateTime, @end_batch_time Datetime
	Set @start_batch_time=GETDATE();
	Begin Try
		/* Inserting Data to CRM Customer Info Table - Full Load */
		Print('=========================================================================');
		Print'Loading Bronze Layer - CRM System';
		Print'=========================================================================';
		Set @start_time=GETDATE();
		Truncate Table bronze.crm_cust_info;
		Bulk insert bronze.crm_cust_info 
		from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_crm\cust_info.csv'
		with(
			FIRSTROW=2,
			Fieldterminator=',',
			Tablock
		);
		Set @end_time=GETDATE();
		Print '>>> Load Duartion: '+ Cast(Datediff(second,@start_time,@end_time) as nvarchar)+ ' seconds'
		print '-----------------------------------------------------------------------------------------'

		/* Inserting Data to CRM Product Info Table - Full Load */
		Set @start_time=GETDATE();
		Truncate Table bronze.crm_prd_info;
		Bulk insert bronze.crm_prd_info 
		from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_crm\prd_info.csv'
		with(
			FIRSTROW=2,
			Fieldterminator=',',
			Tablock
		);
		Set @end_time=GETDATE();
		Print '>>> Load Duartion: '+ Cast(Datediff(second,@start_time,@end_time) as nvarchar)+ ' seconds'
		print '-----------------------------------------------------------------------------------------'
		

		/* Inserting Data to CRM Sales Info Table - Full Load */
		Set @start_time=GETDATE();
		Truncate Table bronze.crm_sales_details;
		Bulk insert bronze.crm_sales_details 
		from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_crm\sales_details.csv'
		with(
			FIRSTROW=2,
			Fieldterminator=',',
			Tablock
		);

		Set @end_time=GETDATE();
		Print '>>> Load Duartion: '+ Cast(Datediff(second,@start_time,@end_time) as nvarchar)+ ' seconds'
		print '-----------------------------------------------------------------------------------------'

		/* Inserting Data to ERP Customer Info Table - Full Load */
		Print'=========================================================================';
		Print'Loading Bronze Layer - ERP System';
		Print'=========================================================================';
		Set @start_time=GETDATE();
		Truncate Table bronze.erp_cust_az12
		Bulk insert bronze.erp_cust_az12
		from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_erp\CUST_AZ12.csv'
		with(
			FIRSTROW=2,
			Fieldterminator=',',
			Tablock
		);

		Set @end_time=GETDATE();
		Print '>>> Load Duartion: '+ Cast(Datediff(second,@start_time,@end_time) as nvarchar)+ ' seconds'
		print '-----------------------------------------------------------------------------------------'

		/* Inserting Data to ERP Location Info Table - Full Load */
		Set @start_time=GETDATE();
		Truncate Table bronze.erp_loc_a101;
		Bulk insert bronze.erp_loc_a101 
		from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_erp\LOC_A101.csv'
		with(
			FIRSTROW=2,
			Fieldterminator=',',
			Tablock
		);

		Set @end_time=GETDATE();
		Print '>>> Load Duartion: '+ Cast(Datediff(second,@start_time,@end_time) as nvarchar)+ ' seconds'
		print '-----------------------------------------------------------------------------------------'


		/* Inserting Data to ERP Product Category Info Table - Full Load */
		Set @start_time=GETDATE();
		Truncate Table bronze.erp_px_cat_g1v2;
		Bulk insert bronze.erp_px_cat_g1v2 
		from 'C:\Users\bdgho\OneDrive - EY\Desktop\Studies-2026\1. Data Engineering\SQL_DWH_Project\SQL_DWH_Project\datasets\source_erp\PX_CAT_G1V2.csv'
		with(
			FIRSTROW=2,
			Fieldterminator=',',
			Tablock
		);

		Set @end_time=GETDATE();
		Print '>>> Load Duartion: '+ Cast(Datediff(second,@start_time,@end_time) as nvarchar)+ ' seconds'
		print '-----------------------------------------------------------------------------------------'

		Set @end_batch_time=GETDATE();
		Print '>>> Load Duartion: '+ Cast(Datediff(second,@start_batch_time,@end_batch_time) as nvarchar)+ ' seconds'
		print '-----------------------------------------------------------------------------------------'

	End Try
	Begin Catch
		print '============================================'
		print 'Error Occured during loading Bronze Layer'
		print 'Error Message'+ ERROR_MESSAGE();
		print 'Error Message'+ Cast(ERROR_NUMBER() as Nvarchar);
		print '============================================'
	End Catch
End;