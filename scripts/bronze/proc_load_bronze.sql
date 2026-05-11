/*
===============================================================================
STORED PROCEDURE: bronze.refresh_load_pipeline
===============================================================================
Description:
    Orchestrates the ingestion process from flat files (.csv) into the Bronze Layer.
    - Captures start/end time for performance monitoring.
    - Cleanses existing staging data (TRUNCATE).
    - Executes Bulk Load operations.
    
Execution:
    EXEC bronze.refresh_load_pipeline;
===============================================================================
*/
create or alter procedure bronze.load_bronze as 
begin 
    DECLARE @START_TIME DATETIME, @END_TIME DATETIME,@batch_start_time datetime,@batch_end_time datetime;
    begin try
        set @batch_start_time = GETDATE();
        print '================================================================'
        print 'Loading Bronze layer';
        print '================================================================'

        print '================================================================'
        print 'Loading CRM tables';
        print '================================================================'

        SET @START_TIME = GETDATE();
        print'>>Trucating tables : bronze.crm_cust_info'
        truncate table bronze.crm_cust_info;

        print'>>Inserting Data Into : bronze.crm_cust_info'
        BULK INSERT bronze.crm_cust_info
        from 'C:\Users\jucho\OneDrive\Desktop\DATA WITH BRASS\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock 
        ) ;
        SET @END_TIME = GETDATE();
        PRINT 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

        set @START_TIME = GETDATE();
        print'>>Trucating tables : bronze.crm_prd_info'
        truncate table bronze.crm_prd_info;

        print'>>Inserting Data Into : bronze.crm_prd_info'
        BULK INSERT bronze.crm_prd_info
        from 'C:\Users\jucho\OneDrive\Desktop\DATA WITH BRASS\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
           with (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );
        set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

        set @START_TIME = GETDATE();
        print'>>Trucating tables : bronze.crm_sales_details'
        truncate table bronze.crm_sales_details;

        print'>>Inserting Data Into : bronze.crm_sales_details'
        BULK INSERT bronze.crm_sales_details
        from 'C:\Users\jucho\OneDrive\Desktop\DATA WITH BRASS\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
           with (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );
        set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

        print '================================================================'
        print 'Loading  ERP tables';
        print '================================================================'

        set @START_TIME = GETDATE();
        print'>>Trucating tables : bronze.rep_cust_az12'
        truncate table bronze.rep_cust_az12;

        print'>>Inserting Data Into : bronze.rep_cust_az12'
        bulk insert bronze.rep_cust_az12
        FROM 'C:\Users\jucho\OneDrive\Desktop\DATA WITH BRASS\sql-data-warehouse-project-main\datasets\source_erp\cust_az12.csv'
        with (
             firstrow = 2,
            fieldterminator = ',',
            tablock
        );
        set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

        set @START_TIME = GETDATE();
        print'>>Trucating tables : bronze.rep_loc_a101'
        truncate table bronze.rep_loc_a101;

        print'>>Inserting Data Into : bronze.rep_loc_a101'
        bulk insert bronze.rep_loc_a101
        from 'C:\Users\jucho\OneDrive\Desktop\DATA WITH BRASS\sql-data-warehouse-project-main\datasets\source_erp\loc_a101.csv'
            with (
              firstrow = 2,
            fieldterminator = ',',
            tablock
        );
        set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

        set @START_TIME = GETDATE();
        print'>>Trucating tables : bronze.rep_px_cat_g1v2'
        truncate table bronze.rep_px_cat_g1v2;

        print'>>Inserting Data Into : bronze.rep_px_cat_g1v2'
        bulk insert bronze.rep_px_cat_g1v2
        from 'C:\Users\jucho\OneDrive\Desktop\DATA WITH BRASS\sql-data-warehouse-project-main\datasets\source_erp\px_cat_g1v2.csv'
            with (
              firstrow = 2,
            fieldterminator = ',',
            tablock
        );
        set @END_TIME = GETDATE();
        print 'Load Durattion:' + cast(datediff(second,@START_TIME,@END_TIME) as nvarchar ) + 'seconds' ;
        print '>>------------------------------------------------';

        set @batch_end_time = GETDATE();
        print '================================================================'
        print 'Loading Bronze layer Completed';
        print'  - Total Load Durattion:' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar ) + 'seconds' ;
        print '================================================================'
    END TRY
    BEGIN CATCH
        print '========================================================='
        print 'Error Occured While Loading Bronze Layer'
        print 'Errror massage : ' + ERROR_MESSAGE();
        print 'Error massage ; ' + cast(ERROR_NUMBER() as Nvarchar);
        print 'Error massage : ' + cast(ERROR_STATE() as Nvarchar);
         print '========================================================='
    END CATCH
end
