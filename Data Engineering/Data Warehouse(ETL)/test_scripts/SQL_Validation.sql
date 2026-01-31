# Step-by-step data validation and cleaning for SQL file 

# Validate primary key on cst_id (duplicates or NULLs)
select cst_id ,count(*) as count from layer1_crm_cust_info group by cst_id having count>1 or cst_id is null;
 
# Keep only the latest record per cst_id based on cst_create_date
select * from(
 select * ,row_number() over(partition by cst_id order by cst_create_date desc) as flag from 
 layer1_crm_cust_info) t where flag =1;
 
# Check for unwanted leading/trailing spaces in string values (first name / last name)
select  cst_firstname from layer1_crm_cust_info where cst_firstname != trim(cst_firstname);
select  cst_lastname from layer1_crm_cust_info where cst_lastname != trim(cst_lastname);
 
# Check consistency of values in low-cardinality columns (e.g., cst_marital_status and cst_gndr)
select distinct(cst_gndr) ,count(*) as count from layer1_crm_cust_info group by cst_gndr;
 
select distinct(cst_marital_status) ,count(*) as count from layer1_crm_cust_info group by cst_marital_status;
 
# After loading into layer2_crm_cust_info, validate that data is cleaned properly
select  cst_firstname from layer2_crm_cust_info where cst_firstname != trim(cst_firstname);
select  cst_lastname from layer2_crm_cust_info where cst_lastname != trim(cst_lastname);
 
select distinct(cst_gndr) ,count(*) as count from layer2_crm_cust_info group by cst_gndr;
select distinct(cst_marital_status) ,count(*) as count from layer2_crm_cust_info group by cst_marital_status;
 
select cst_id ,count(*) as count from layer2_crm_cust_info group by cst_id having count>1 or cst_id is null;
 
# DATA Transformation on table layer1_crm_prd_info

# Check if primary key (prd_id) is unique
select prd_id ,
count(*) as count
from layer1_crm_prd_info group by prd_id having count>1;
 
# Derive cat_id from prd_key and check if it exists in the reference category table
select 
prd_id,
prd_key,
replace(substring(prd_key,1,5),'-','_')as cat_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
from layer1_crm_prd_info 
where replace(substring(prd_key,1,5),'-','_')not in (select distinct id from layer1_erp_px_cat_g1v2);

# Check for unwanted spaces in product name
select prd_nm
from layer1_crm_prd_info where prd_nm != trim(prd_nm);

# Check prd_cost for negative numbers and NULL values 
select prd_cost from layer1_crm_prd_info where prd_cost <0 or prd_cost is null ;

# Check distribution/consistency of prd_line values
select distinct prd_line,count(*) as count from layer1_crm_prd_info group by prd_line;

# Check for invalid date order (prd_end_dt before prd_start_dt)
select * from layer1_crm_prd_info where prd_end_dt<prd_start_dt;

# Check continuity of product date ranges per prd_key
select prd_id,
prd_key,
prd_nm,
prd_start_dt,
lead(prd_start_dt) over(partition by prd_key order by prd_start_dt )- interval 1 day as prd_end_dt,
prd_end_dt
from layer1_crm_prd_info where prd_key in( 'AC-HE-HL-U509-R','AC-HE-HL-U509');
 
# After loading into layer2_crm_prd_info, validate primary key uniqueness
select prd_id ,
count(*) as count
from layer2_crm_prd_info group by prd_id having count>1;

# Validate date order in layer2 (prd_end_dt should not be before prd_start_dt)
select * from layer2_crm_prd_info where prd_end_dt<prd_start_dt;

# DATA Transformation on table layer1_crm_sales_details

# Check for mismatches between sales details and product info:
# sls_prd_key in sales_details should exist as prd_key in layer2_crm_prd_info
select * from layer1_crm_sales_details where sls_prd_key not in
 (select prd_key from layer2.layer2_crm_prd_info);
 
# Check for mismatches between sales details and customer info:
# sls_cust_id in sales_details should exist as cst_id in layer2_crm_cust_info
select * from layer1_crm_sales_details where sls_cust_id not in
 (select cst_id from layer2.layer2_crm_cust_info);
 
# Validate sls_order_dt: reject invalid, zero, or out-of-range dates before converting to DATE
select nullif(sls_order_dt,0) from layer1_crm_sales_details 
where sls_order_dt <=0 or length(sls_order_dt)!=8 or 
sls_order_dt>20500101 or sls_order_dt<19000101;

# Validate sls_ship_dt: same rules as order date
select nullif(sls_ship_dt,0) from layer1_crm_sales_details 
where sls_ship_dt <=0 or length(sls_ship_dt)!=8 or 
sls_ship_dt>20500101 or sls_ship_dt<19000101;

# Validate sls_due_dt: same rules as order date
select nullif(sls_due_dt,0) from layer1_crm_sales_details 
where sls_due_dt <=0 or length(sls_due_dt)!=8 or 
sls_due_dt>20500101 or sls_due_dt<19000101;

# Check for invalid date logic:
# order date must be earlier than shipping and due dates
select * from layer1_crm_sales_details where sls_order_dt>sls_ship_dt or sls_order_dt>sls_due_dt;

# Validate sales, quantity, and price
# Business rule:
#   sales = quantity * price
#   negative, zero, or NULL values are not allowed
select distinct sls_sales,
sls_quantity,
sls_price
from layer1_crm_sales_details
where sls_sales != sls_quantity* sls_price
or sls_sales  is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity<=0 or sls_price<=0;
 
# Business rules for fixing invalid values:
# - If sales is negative, zero, or NULL, derive it using quantity * price.
# - If price is zero or NULL, derive it using sales / quantity.
# - If price is negative, convert it to a positive value using ABS().
select distinct  sls_sales as old_sales,
sls_quantity,
sls_price as old_price,
case when sls_sales is null or sls_sales <=0 or 
sls_sales != sls_quantity * abs(sls_price)
then sls_quantity * abs(sls_price)
else sls_sales
End as sls_sales,
case when sls_price is null or sls_price <=0
then sls_sales/nullif(sls_quantity,0)
else sls_price end as sls_price
from layer1_crm_sales_details
where sls_sales != sls_quantity* sls_price
or sls_sales  is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity<=0 or sls_price<=0;

# After loading sales_details from layer1 into layer2, do a final quality check
use layer2;
select  sls_sales,
sls_quantity,
sls_price
from layer2_crm_sales_details
where sls_sales != sls_quantity* sls_price
or sls_sales  is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity<=0 or sls_price<=0 order by sls_sales,sls_quantity,sls_price;

# We use a CTE here because MySQL evaluates all column expressions at the same time.
# Without a CTE, the new sls_sales value may be computed using the old (uncleaned) sls_price.
# By using a CTE, MySQL first fixes sls_price, and then uses that cleaned price to correctly recalculate sls_sales.

# DATA Transformation on table layer1_erp_cust_az12
 
# Standardize CID by removing 'NAS' prefix when present
select case when CID like 'NAS%' then substring(CID,4)
 else CID
 end as CID
 ,BDATE,GEN from layer1_erp_cust_az12;
 
# Validate birthday (BDATE should be within a realistic range)
select  CID
 ,BDATE,GEN from layer1_erp_cust_az12 where BDATE<1920-01-01 or BDATE>now();


# Clean CID and nullify impossible future birthdates
select case when CID like 'NAS%' then substring(CID,4)
 else CID
 end as CID,
 case when BDATE >now() then null
 else BDATE
 end as BDATE
from layer1_erp_cust_az12 ;
 
# Standardize GEN (gender) values to Male/Female/NA
select case 
 when upper(trim(GEN)) in('F','FEMALE') then 'Female'
 when upper(trim(GEN)) in('M','FEMALE') then 'Male'
 else 'NA'
 end as GEN from layer1_erp_cust_az12;
 
# Check distinct GEN values before cleaning
select distinct GEN,count(*) from layer1_erp_cust_az12 group by GEN;

# Validate data quality in layer2_erp_cust_az12 after loading
use layer2;
select case when CID like 'NAS%' then substring(CID,4)
 else CID
 end as CID
 ,BDATE,GEN from layer1_erp_cust_az12;
 
 
# Validate birthday in layer2 (no future dates)
select  CID
 ,BDATE,GEN from layer2_erp_cust_az12 where BDATE>now();

 
# Explanation of hidden carriage return issue in GEN column:
# The HEX output showed values like:
#   'Male\r'   → 4D616C650D
#   'Female\r' → 46656D616C650D
# The last byte 0D is carriage return (\r, CHAR(13)).
# So the stored value was actually 'MALE\r' or 'FEMALE\r', which is not equal to 'MALE' or 'FEMALE'.
# Therefore, CASE ... IN ('M','MALE','F','FEMALE') did not match and fell into ELSE 'NA'.
# Some rows were just whitespace + \r (e.g., HEX 20200D, 200D), which also become NA.
# Key point: TRIM() removes spaces (CHAR(32)), but not carriage returns (CHAR(13)).

SELECT 
  CASE
    WHEN UPPER(TRIM(REPLACE(GEN, CHAR(13), ''))) IN ('F','FEMALE')
      THEN 'Female'
    WHEN UPPER(TRIM(REPLACE(GEN, CHAR(13), ''))) IN ('M','MALE')
      THEN 'Male'
    ELSE 'NA'
  END AS GEN_CLEAN
FROM layer1_erp_cust_az12;

# Check distinct GEN values after cleaning / loading into layer2
select distinct GEN,count(*)from layer2.layer2_erp_cust_az12 group by GEN;

# Data transformation on layer1_erp_loc_a101
use layer1;

# Standardize CID (remove '-') and clean country codes
select replace(CID,'-','') as CID,
case 
when trim(CNTRY) in('DE') then 'Germany'
when trim(CNTRY) in('US','USA') then 'United States'
when trim(CNTRY) ='' or CNTRY is null then 'NA'
else trim(CNTRY) END as
CNTRY 
from layer1_erp_loc_a101;

# Clean CNTRY by removing carriage returns and mapping codes -> country names
select distinct CNTRY as old_cntry,case 
when trim(replace(CNTRY,char(13),'')) ='DE' then 'Germany'
when trim(replace(CNTRY,char(13),'')) in('US','USA') then 'United States'
when CNTRY is null or trim(replace(CNTRY,char(13),'')) =''  
then 'NA'
else trim(replace(CNTRY,char(13),'')) END as
CNTRY from layer1_erp_loc_a101;

# How to validate layer2.layer2_erp_loc_a101 after loading
select * from layer2.layer2_erp_loc_a101;
select distinct CNTRY from layer2.layer2_erp_loc_a101;

# Data transformation on layer1_erp_px_cat_g1v2
select ID,
CAT,
SUBCAT,
MAINTENANCE
from Layer1.layer1_erp_px_cat_g1v2;

# Check for unwanted spaces / carriage returns in CAT, SUBCAT, and MAINTENANCE
select * from Layer1.layer1_erp_px_cat_g1v2 where trim(replace(CAT,char(13),'')) <> CAT ;
select * from Layer1.layer1_erp_px_cat_g1v2 where trim(replace(SUBCAT,char(13),'')) <> SUBCAT ;
select * from Layer1.layer1_erp_px_cat_g1v2 where trim(replace(MAINTENANCE,char(13),'')) <> MAINTENANCE;
select * from Layer1.layer1_erp_px_cat_g1v2 where trim(MAINTENANCE) != MAINTENANCE; # instead of != we use <> when combined with REPLACE()

# Check distinct CAT values (do the same for SUBCAT and MAINTENANCE as needed)
select distinct CAT from layer1.layer1_erp_px_cat_g1v2; # check for SUBCAT and also MAINTENANCE

# Normalize MAINTENANCE: convert empty/whitespace (after removing \r) to 'NA'
select distinct case when trim(replace(MAINTENANCE,char(13),''))='' then 'NA'
else trim(replace(MAINTENANCE,char(13),'')) end as MAINTENANCE from
layer1.layer1_erp_px_cat_g1v2;

# Validate MAINTENANCE values after loading into layer2.layer2_erp_px_cat_g1v2
select distinct MAINTENANCE from layer2.layer2_erp_px_cat_g1v2;
