// Create schema to keep things organized:
CREATE OR REPLACE SCHEMA MANAGE_DB.file_formats;

// Create file format Object inside schema:
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.my_file_format;

//See properties of file format object: By default csv is created as file format
DESC file format MANAGE_DB.FILE_FORMATS.my_file_format;

//Altering the properties of file format:
ALTER FILE FORMAT MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT
SET SKIP_HEADER=1;

//Replacing properties of file format:
CREATE or REPLACE file format MANAGE_DB.FILE_FORMATS.my_file_format
TYPE=JSON,
TIME_FORMAT = AUTO;

//We can alter the properties of file_format but we cannot chnage/alter file format very easily. We can only replace the file format.

//Creating new CSV file format:
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.csv_file_format
TYPE = CSV,
FIELD_DELIMITER = ",",
SKIP_HEADER=1;

DESC file format MANAGE_DB.FILE_FORMATS.csv_file_format;

TRUNCATE MANAGE_DB.PUBLIC.ORDERS;

SELECT * FROM MANAGE_DB.PUBLIC.ORDERS;

COPY INTO MANAGE_DB.PUBLIC.ORDERS
FROM @Manage_db.external_stages.aws_stage
file_format = (FORMAt_NAME = MANAGE_DB.file_formats.csv_file_format)
files = ('OrderDetails.csv')