/*
-------------------------------------------------------------------------------
1. BRONZE LAYER INITIALIZATION
-------------------------------------------------------------------------------
Purpose: 
    To create the 'landing zone' for raw data files (CSV). 
    This layer maintains the data in its original format with no transformations.

Source Systems:
    - CRM (Customer Relationship Management)
    - ERP (Enterprise Resource Planning)

Warning: 
    Executing this script will reset the Bronze Layer.
-------------------------------------------------------------------------------
*/

if OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
create table bronze.crm_cust_info (
    cst_id int,
    cst_key Nvarchar(50),
    cst_firstname Nvarchar(100),
    cst_lastname Nvarchar(100),
    cst_marital_status Nvarchar(20),
    cst_gndr Nvarchar(50),
    cst_create_date date,
    dwh_create_date    DATETIME2 DEFAULT GETDATE()
);

if object_id ('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
create table bronze.crm_prd_info (
    prd_id int,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(100),
    prd_cost NVARCHAR(50) ,
    prd_line NVARCHAR(100),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME,
    dwh_create_date    DATETIME2 DEFAULT GETDATE()
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
    sls_sales INT,
    sls_quantity INT ,
    sls_price INT,
    dwh_create_date    DATETIME2 DEFAULT GETDATE()
);

if object_id ('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
create table bronze.erp_cust_az12 (
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50)
)

if object_id ('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
create table bronze.erp_loc_a101 (
  CID NVARCHAR(50),
  CNTRY NVARCHAR(50),
  dwh_create_date    DATETIME2 DEFAULT GETDATE()
)

if object_id ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50),
    dwh_create_date    DATETIME2 DEFAULT GETDATE()
) ;
