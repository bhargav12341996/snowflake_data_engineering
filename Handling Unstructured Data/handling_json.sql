CREATE OR replace stage manage_db.external_stages.jsonstage
url = 's3://bucketsnowflake-jsondemo';

CREATE or replace file format manage_db.file_formats.json_format
type = json;

list @manage_db.external_stages.jsonstage;

CREATE DATABASE our_first_db;

//Creating a new table named as json_raw which has a column named raw_file with data type as variant:
CREATE or replace table our_first_db.public.json_raw(
 raw_file variant
);

copy into our_first_db.public.JSON_RAW
from @manage_db.external_stages.jsonstage
file_format = manage_db.file_formats.json_format
files=('HR_data.json');

SELECT * FROM our_first_db.public.JSON_RAW;

SELECT RAW_FILE:city AS City, RAW_FILE:first_name AS First_Name from our_first_db.public.JSON_RAW;

//Other way:
SELECT $1:city CITY, $1:first_name First_Name FROM our_first_db.public.json_raw;

SELECT $1:city CITY, $1:first_name::string First_Name FROM our_first_db.public.json_raw;

SELECT 
    RAW_FILE:id::int as id,
    RAW_FILE:first_name::string as first_name,
    RAW_FILE:last_name::string as last_name,
    RAW_FILE:gender::string as gender
FROM OUR_FIRST_DB.public.json_raw;

//Handling nested data:
SELECT Raw_file:job FROM our_first_db.public.json_raw;

SELECT Raw_file:job.salary AS SALARY, Raw_file:job.title AS job_title  FROM our_first_db.public.json_raw;

SELECT Raw_file:prev_company as previous_company
FROM OUR_FIRST_DB.public.json_raw;

//extracting only first value:
SELECT Raw_file:prev_company[0] as previous_company
FROM OUR_FIRST_DB.public.json_raw;

SELEct RAW_FILE:spoken_languages as spoken_languages
from our_first_db.public.json_raw;

//handling list of values by flattening:
//Flattening spoken language key:
CREATE OR REPLACE TABLE Languages AS
select
      RAW_FILE:first_name::STRING as First_name,
      f.value:language::STRING language,
      f.value:level::STRING level
from OUR_FIRST_DB.PUBLIC.JSON_RAW, table(flatten(RAW_FILE:spoken_languages)) f;

SELECT * FROM OUR_FIRST_DB.public.languages;
