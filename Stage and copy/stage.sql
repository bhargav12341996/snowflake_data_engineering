CREATE OR REPLACE DATABASE MANAGE_DB;

CREATE OR REPLACE SCHEMA external_stages;

//Creating external stage:
CREATE or replace stage aws_stage
    url = 's3://dwh-snowflake-course-bhargav'
    credentials = (aws_key_id = 'AKIA2DWV7OIUIYTMBI4J', aws_secret_key = 'W+5vYSK7aJPmyIuBmVa/VC4CVwb+XLks/82JeMxy');

// Description of external stage:
DESC STAGE aws_stage;

// Alter external stage by modifying  the credentials:
ALTER STAGE aws_stage
 set credentials = (aws_key_id = 'XYZ_DUMMY_ID', aws_secret_key = '987xyz');

 // Modifying existing stage with a new s3 bucket that is publicly available:
 CREATE or replace stage aws_stage
 url = 's3://bucketsnowflakes3';  

 // To list all the files in the staging:
 LIST @aws_stage;

 // Creating orders table in Public Schema:
 CREATE or REPLACE TABLE manage_db.public.orders (
    order_id varchar(30),
    amount int,
    profit int,
    quantity int,
    category varchar(30),
    subcategory varchar(30)
 );

 SELECT * FROM Orders;

 COPY INTO manage_db.public.orders
 FROM @aws_stage 
 file_format=(type=csv field_delimiter = "," skip_header = 1)
 files= ('OrderDetails.csv')

// Transformation in Snowflake while loading:

CREATE or REPLACE TABLE MANAGE_DB.public.orders_ex(
    order_id varchar(30),
    amount int
)

COPY INTO MANAGE_DB.Public.orders_ex
FROM (SELECT s.$1,s.$2 FROM @MANAGE_DB.external_stages.aws_stage s)
file_format=(type=csv field_delimiter = "," skip_header = 1)
files= ('OrderDetails.csv')

SELECT * FROM orders_ex;

// Transformation in Snowflake while loading:

CREATE or REPLACE TABLE MANAGE_DB.public.orders_ex1(
    order_id varchar(30),
    amount int,
    profit int,
    category_substring varchar(100)
);

COPY INTO MANAGE_DB.Public.orders_ex1
FROM (SELECT s.$1,s.$2,s.$3,
CASE WHEN CAST(s.$3 as int) < 0 THEN 'not profitable' ELSE 'profitable' END
FROM @MANAGE_DB.external_stages.aws_stage s)
file_format=(type=csv field_delimiter = "," skip_header = 1)
files= ('OrderDetails.csv');

SELECT * FROM MANAGE_DB.Public.orders_ex1;