CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null');

create or replace stage customer_ext_stage
  url='s3://nydocker-bucket-123/'
  credentials=(aws_key_id='' aws_secret_key='')
  file_format = csv_format;
  
show stages;
list @customer_ext_stage;


CREATE OR REPLACE PIPE customer_s3_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO customer_raw
  FROM @customer_ext_stage
  FILE_FORMAT = (FORMAT_NAME = csv_format)
  PATTERN = '.*customer_.*\\.csv';
  
show pipes;
select SYSTEM$PIPE_STATUS('customer_s3_pipe');

--truncate table customer_raw;

select count(*) from customer_raw;
