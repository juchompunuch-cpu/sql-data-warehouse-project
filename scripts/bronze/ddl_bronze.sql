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
