CREATE OR REPLACE DATABASE DATA_S;

CREATE OR REPLACE STAGE aws_stage
    url='s3://bucketsnowflakes3';

LIST @aws_stage;

// Create table
CREATE OR REPLACE TABLE ORDERS (
ORDER_ID	VARCHAR(30)
,AMOUNT	NUMBER(38,0)
,PROFIT	NUMBER(38,0)
,QUANTITY	NUMBER(38,0)
,CATEGORY	VARCHAR(30)
,SUBCATEGORY	VARCHAR(30)); 

// Load data using copy command
COPY INTO ORDERS
    FROM @MANAGE_DB.external_stages.aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*OrderDetails.*';

SELECT * FROM ORDERS;

// Create a share object
CREATE OR REPLACE SHARE ORDERS_SHARE;

---- Setup Grants ----
// Grant usage on database
GRANT USAGE ON DATABASE DATA_S TO SHARE ORDERS_SHARE; 

// Grant usage on schema
GRANT USAGE ON SCHEMA DATA_S.PUBLIC TO SHARE ORDERS_SHARE; 

// Grant SELECT on table

GRANT SELECT ON TABLE DATA_S.PUBLIC.ORDERS TO SHARE ORDERS_SHARE; 

// Validate Grants
SHOW GRANTS TO SHARE ORDERS_SHARE;

---- Add Consumer Account ----
ALTER SHARE ORDERS_SHARE ADD ACCOUNT=<consumer-account-id>;

CREATE MANAGED ACCOUNT tech_joy_account
ADMIN_NAME = bhargav96_joy_admin,
ADMIN_PASSWORD = 'bhArgAv@18011996',
TYPE = READER;

// Make sure to have selected the role of accountadmin

// Show accounts
SHOW MANAGED ACCOUNTS;

-- Share the data -- 

ALTER SHARE ORDERS_SHARE 
ADD ACCOUNT = GOB97309;