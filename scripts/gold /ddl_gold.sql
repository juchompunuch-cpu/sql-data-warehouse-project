/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script defines the 'gold' schema views for the final analytical layer.
    It transforms Silver data into a Star Schema (Fact and Dimension tables)
    to provide a clean, enriched, and business-ready dataset.

Usage:
    Directly queried for Business Intelligence, Analytics, and Reporting.
===============================================================================
*/


GO
create or alter view gold.dim_customer as
select

	ROW_NUMBER() over(order by cst_id) as customer_key,

	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,

	la.CNTRY as country,
	ci.cst_marital_status as marital_status,

	case 
		when ci.cst_gndr != 'n/a' then ci.cst_gndr
		else coalesce (ca.GEN, 'n/a')
	end as gender,
	ca.BDATE as birthdate,
	ci.cst_create_date as create_date
from silver.crm_cust_info as ci

left join silver.erp_cust_az12 as ca
	on ci.cst_key = ca.CID
left join silver.erp_loc_a101 as la
	on ci.cst_key = la.CID



GO
create or alter view gold.dim_product as

select 
	row_number() over (order by pn.prd_start_dt,pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcatergory,
	pc.maintenance ,
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
from silver.crm_prd_info as pn
left join silver.erp_px_cat_g1v2 as pc
	on pn.cat_id = pc.id

where prd_end_dt is NULL -- Filter out all historical data


GO
create or alter view gold.fac_sales as
select 
	sd.sls_ord_num as order_number,

	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quanity,
	sd.sls_price as price
from silver.crm_sales_details as sd
left join gold.dim_product as pr
	on sd.sls_prd_key = pr.product_number
left join gold.dim_customer as cu
	on sd.sls_cust_id = cu.customer_id




