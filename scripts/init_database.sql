/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

-- Drop and Recreate a 'Datawarehouse' database
If exists(select 1 from sys.databases where name='Datawarehouse')
Begin
	Alter database Datawarehouse set single_user with Rollback Immediate;
	Drop database Datawarehouse
End;
Go

Create Database Datawarehouse;
Go

Use Datawarehouse;
Go

/** We will Start Creating Schema **/
Create Schema bronze;
Go
Create Schema silver;
Go
Create Schema gold;
Go
