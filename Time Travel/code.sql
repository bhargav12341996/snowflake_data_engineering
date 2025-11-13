// Setting up table

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);

CREATE OR REPLACE FILE FORMAT MANAGE_DB.file_formats.csv_file
    type = csv
    field_delimiter = ','
    skip_header = 1;

CREATE OR REPLACE STAGE MANAGE_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = MANAGE_DB.file_formats.csv_file;

LIST @MANAGE_DB.external_stages.time_travel_stage;

COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv');

SELECT * FROM OUR_FIRST_DB.public.test;

// Use-case: Update data (by mistake)
UPDATE OUR_FIRST_DB.public.test
SET FIRST_NAME = 'Joyen' ;

// // // Using time travel: Method 1 - 2 minutes back
SELECT * FROM OUR_FIRST_DB.public.test at (OFFSET => -60*1.5)

---Truncate the data from table and then load the original data:
TRUNCATE OUR_FIRST_DB.public.test;

---Time travel Method 2:

---Getting the current timestamp in UTC:
-- Setting up UTC time for convenience
ALTER SESSION SET TIMEZONE ='UTC';
SELECT CURRENT_TIMESTAMP;

2025-10-14 01:18:16.966 +0000

UPDATE OUR_FIRST_DB.public.test
SET Job = 'Data Scientist';

SELECT * FROM OUR_FIRST_DB.public.test before (timestamp => '2025-10-14 01:13:16.966'::timestamp);

--- Before we jump onto method 3, lets truncate the table and freshly load the data into table again:
---Method 3: Using Query ID

TRUNCATE OUR_FIRST_DB.public.test;

COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv');

SELECT * FROM OUR_FIRST_DB.public.test;

// Altering table (by mistake)
UPDATE OUR_FIRST_DB.public.test
SET EMAIL = null;

--As of 10/13/2025; query history is under monitoring section:
//01bfb1b6-0206-a904-0013-5f4b0004e04e
SELECT * FROM OUR_FIRST_DB.public.test before (statement => '01bfb1b6-0206-a904-0013-5f4b0004e04e')


---Recovering data using time travel:

---Method 1: Bad method using QueryID (because we are overwriting on the same table data).

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test as
SELECT * FROM OUR_FIRST_DB.public.test before (statement => '01bfb1b6-0206-a904-0013-5f4b0004e04e');

SELECT * FROM OUR_FIRST_DB.public.test;

---Method 2: Using a dummy table to copy data from original table and then truncate original table and copy data 
---from dummy table to original table again. This helps us to time travel.

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test_backup as
SELECT * FROM OUR_FIRST_DB.public.test before (statement => '01bfb1b6-0206-a904-0013-5f4b0004e04e');

---Above code won't work because metadata has already been replaced. 

TRUNCATE OUR_FIRST_DB.public.test;

INSERT INTO OUR_FIRST_DB.public.test
SELECT * FROM OUR_FIRST_DB.public.test_backup;

SELECT * FROM OUR_FIRST_DB.public.test ;

---Dummy tables are really useful to perform upsert or SQL merge statements and also do some transformations.