/*
-------------------------------------------------------------------------------
DATA WAREHOUSE PROJECT: BRONZE LAYER DEPLOYMENT
-------------------------------------------------------------------------------
Module      : Schema Definition (DDL)
Layer       : Bronze (Raw Data Staging)
Description : Re-initializes the Bronze schema by recreating all base tables.
Caution     : Running this script will TRUNCATE and RECREATE existing tables.
-------------------------------------------------------------------------------
*/

if OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
create table bronze.crm_cust_info (
    cst_id int,
    cst_key varchar(50),
    cst_firstname varchar(100),
    cst_lastname varchar(100),
    cst_marital_status varchar(20),
    cst_gndr char(1),
    cst_create_date date
);

if object_id ('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
create table bronze.crm_prd_info (
    prd_id int,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(100),
    prd_cost DECIMAL(10, 2),
    prd_line NVARCHAR(100),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);
if object_id ('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
create table bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id int,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales DECIMAL(10, 2),
    sls_quantity INT ,
    sls_price DECIMAL(10, 2)
);

if object_id ('bronze.rep_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.rep_cust_az12;
create table bronze.rep_cust_az12 (
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50)
)

if object_id ('bronze.rep_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.rep_loc_a101;
create table bronze.rep_loc_a101 (
  CID NVARCHAR(50),
  CNTRY NVARCHAR(50)
)

if object_id ('bronze.rep_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.rep_px_cat_g1v2;
create table bronze.rep_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50)
) ;

GO
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
