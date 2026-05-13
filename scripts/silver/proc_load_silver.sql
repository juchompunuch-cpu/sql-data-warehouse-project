/*
===============================================================================
Stored Procedure: silver.load_silver
===============================================================================
Description:
    Performs data refinement by moving records from the Bronze to Silver schema.
    The objective is to provide a 'Single Version of Truth' for cleansed data 
    before downstream consumption in the Gold layer.

Process Flow:
    1. Truncate target tables in the Silver schema.
    2. Extract data from the Bronze layer.
    3. Apply business logic and data cleaning transformations.
    4. Load refined data into Silver tables.

Execution:
    EXEC silver.load_silver;
===============================================================================
*/



GO
create or alter procedure silver.load_silver as
begin

	DECLARE @START_TIME DATETIME, @END_TIME DATETIME,@batch_start_time datetime,@batch_end_time datetime;
	begin try
		set @batch_start_time = GETDATE();
		print '================================================================'
        print 'Loading silver layer';
        print '================================================================'

        print '================================================================'
        print 'Loading CRM tables';
        print '================================================================'
	
		SET @START_TIME = GETDATE();
		Print '>> TRUNCATE TABLE : silver.crm_cust_info' ;
		TRUNCATE TABLE silver.crm_cust_info;
		
		Print '>> inserting data Into : silver.crm_cust_info' ;
		insert into [silver].[crm_cust_info] (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		select
			cst_id,
			cst_key,
		
			trim(cst_firstname) as cst_firstname,
			trim(cst_lastname) as cst_lastname,
		
		case 
			when upper(trim(cst_marital_status)) = 'M' then 'Married'
			when upper(trim(cst_marital_status)) = 'S' then 'Single'
			else 'n/a'
		end as cst_marital_status,
		case 
			when upper(trim(cst_gndr)) = 'M' then 'Female'
			when upper(trim(cst_gndr)) = 'F' then 'Male'
			else 'n/a'
		end as cst_gndr,
			cst_create_date
		from 
		(
		
		select 
		*,
		ROW_NUMBER () over (partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
		where cst_id is not null 
		)t where flag_last = 1 ;
		SET @END_TIME = GETDATE();
        PRINT 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

		set @START_TIME = GETDATE();
		Print '>> TRUNCATE TABLE : silver.crm_prd_info' ;
		TRUNCATE TABLE silver.crm_prd_info;
		Print '>> inserting data Into : silver.crm_prd_info' ;
		insert into silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		select 
			prd_id,
			erpLACE(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key,
			prd_nm,
			isnull(prd_cost,0) as prd_cost,
			case UPPER(trim(prd_line))
				when 'M' then 'Mountain'
				when 'R' then 'Road'
				when 'S' then 'Other Sales'
				when 'T' then 'Touring'
				else 'n/a'
			end as prd_line,
			cast(prd_start_dt as date) as prd_start_dt,
			cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)- 1 as date) as prd_end_dt
		from bronze.crm_prd_info
		set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';


		set @START_TIME = GETDATE();
		Print '>> TRUNCATE TABLE : silver.crm_sales_details' ;
		TRUNCATE TABLE silver.crm_sales_details;
		Print '>> inserting data Into : silver.crm_sales_details' ;
		insert into silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,

			case
				when sls_order_dt <= 0 or len(sls_order_dt) ! = 8 then null
				else cast(cast(sls_order_dt as varchar) as date)
			end as sls_order_dt,
			case
				when sls_ship_dt <= 0 or len(sls_ship_dt) ! = 8 then null
				else cast(cast(sls_ship_dt as varchar) as date)
			end as sls_ship_dt,
			case
				when sls_due_dt <= 0 or len(sls_due_dt) ! = 8 then null
				else cast(cast(sls_due_dt as varchar) as date)
			end as sls_due_dt,
			case
				when sls_sales is null or sls_sales <= 0 or sls_sales ! = sls_quantity * ABS(sls_price)
					then sls_quantity * ABS(sls_price)
					else sls_sales
			end as sls_sales,
			sls_quantity,
			case
				when sls_price is null or sls_price < = 0 
					then sls_sales / Nullif(sls_quantity,0)
					else sls_price
			end as sls_price
		from bronze.crm_sales_details ;
		set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';


		print '================================================================'
        print 'Loading  ERP tables';
        print '================================================================'

        set @START_TIME = GETDATE();
		Print '>> TRUNCATE TABLE : silver.erp_cust_az12' ;
		TRUNCATE TABLE silver.erp_cust_az12;
		Print '>> inserting data Into : silver.erp_cust_az12' ;
		insert into silver.erp_cust_az12 (
			CID,
			BDATE,
			GEN
		)
		select 
			TRIM (
			case
				when cid like 'NAS%' then substring(cid,4, len(cid))
				else cid  
			end ) as CID ,
			case 
				when BDATE > getdate() then null
				else BDATE
			end  BDATE,
			case
				when UPPER(TRIM(GEN)) in ('F', 'FEMALE') then 'Female'
				when UPPER(TRIM(GEN)) in ('M', 'MALE') then 'Male'
				else 'n/a'
			end as gen
		from bronze.erp_cust_az12
		set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

		set @START_TIME = GETDATE();
		Print '>> TRUNCATE TABLE : silver.erp_loc_a101' ;
		TRUNCATE TABLE silver.erp_loc_a101;
		Print '>> inserting data Into : silver.erp_loc_a101' ;
		insert into silver.erp_loc_a101 (
			CID,
			CNTRY
		)
		select 
			trim (
			erplace(CID,'-','') ) as CID,
			case
			when trim(CNTRY) = 'DE' then 'Germany'
			when trim(CNTRY) IN ('US','USA') then 'United States'
			when trim(CNTRY) = '' or cntry is null then 'n/a'
			else trim(CNTRY)
		end as cntry
		from bronze.erp_loc_a101
		set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

		set @START_TIME = GETDATE();
		Print '>> TRUNCATE TABLE : silver.erp_px_cat_g1v2 ' ;
		TRUNCATE TABLE silver.erp_px_cat_g1v2 ;
		Print '>> inserting data Into : silver.erp_px_cat_g1v2 ' ;
		insert into silver.erp_px_cat_g1v2 (
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		)
		select
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		from bronze.erp_px_cat_g1v2
		 set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

		set @batch_end_time = GETDATE();
        print '================================================================'
        print 'Loading silver layer Completed';
        print'  - Total Load Durattion:' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar ) + 'seconds' ;
        print '================================================================'

	end try
	begin catch
		print '========================================================='
        print 'Error Occured While Loading silver Layer'
        print 'Errror massage : ' + ERROR_MESSAGE();
        print 'Error massage ; ' + cast(ERROR_NUMBER() as Nvarchar);
        print 'Error massage : ' + cast(ERROR_STATE() as Nvarchar);
        print '========================================================='
	end catch
end






