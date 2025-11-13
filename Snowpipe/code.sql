// Create table first
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.employees (
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  department STRING
  );

  // Create file format object
CREATE OR REPLACE file format MANAGE_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;

 // Create stage object with integration object & file format object
CREATE OR REPLACE stage MANAGE_DB.external_stages.csv_folder
    URL = 's3://dwh-snowflake-course-bhargav/snowpipe/'
    STORAGE_INTEGRATION = s3_init
    FILE_FORMAT = MANAGE_DB.file_formats.csv_fileformat;

--- In the first run, this should be blank, because snowpipe folder does not have anything in it.
LIST @MANAGE_DB.external_stages.csv_folder;


// Create schema to keep all the pipe objects organized:
CREATE OR REPLACE SCHEMA MANAGE_DB.pipes;

// Define pipe
CREATE OR REPLACE pipe MANAGE_DB.pipes.employee_pipe
auto_ingest = TRUE --to auto load the data
AS
COPY INTO OUR_FIRST_DB.PUBLIC.employees
FROM @MANAGE_DB.external_stages.csv_folder; 

// Describe pipe get the notification_channel and copy it for S3 event 
DESC pipe MANAGE_DB.pipes.employee_pipe;

SELECT * FROM OUR_FIRST_DB.PUBLIC.employees;

-- Manage pipes -- 

DESC pipe MANAGE_DB.pipes.employee_pipe;

SHOW PIPES;

SHOW PIPES like '%employee%';

SHOW PIPES in database MANAGE_DB;

SHOW PIPES in schema MANAGE_DB.pipes;

SHOW PIPES like '%employee%' in Database MANAGE_DB;