
-- J. Rachlin
-- Database Design
-- Importing data into MySQL

-- Step 1. Configure the server to allow data to be imported 
--  from anywhere on your local file system

show variables where variable_name like '%local%';
set global local_infile=ON;

-- Step 2. Configure the MySQL client to also process
-- locally imported files. To do this:
-- a) Close this connection. Edit your root connection.
-- b) Under the advanced tab add the line OPT_LOCAL_INFILE=1
-- c) Reopen the root connection


-- Step 3. Create the database
DROP DATABASE IF EXISTS gad;
CREATE DATABASE gad;


-- Step 4. Make gad the active database
USE gad;


-- Step 5. Create a table schema to hold the data

CREATE TABLE gad (
  gad_id int, 
  association text,
  phenotype text,
  disease_class text,
  chromosome text,
  chromosome_band text,
  dna_start int,
  dna_end int,
  gene text,
  gene_name text,
  reference text,
  pubmed_id int,
  year int,
  population text
) ;

-- Step 6. import your data!
-- file path for windows would look something like 'C:\\users\\carterithier\\Downloads\\gad.csv
LOAD DATA LOCAL 
INFILE '/Users/carterithier/Downloads/gad.csv' -- mac file path version
INTO TABLE gad
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;

use gad;
-- Step 7. Verify that you imported 39910 rows.
SELECT count(*) FROM gad;

-- Step 8. Verify that the data looks good!
SELECT * FROM gad;





