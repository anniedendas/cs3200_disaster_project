-- FILE TO INSTALL EMDAT DATABASE ON MYSQL, NEED TO INSERT YOUR OWN 
-- FILEPATH WHERE IT SAYS '/Users/shefaliverma/Downloads/EMDATdata1960-2025allcountries.csv' "

show variables where variable_name like '%local%';
set global local_infile=ON;

drop database if exists disasters;
CREATE DATABASE disasters;
use disasters;

CREATE TABLE emdat (
    disaster_id VARCHAR(50) PRIMARY KEY,
    historic VARCHAR(3),
    classification_key VARCHAR(50),
    disaster_group VARCHAR(50),
    disaster_subgroup VARCHAR(50),
    disaster_type VARCHAR(50),
    disaster_subtype VARCHAR(50),
    external_ids VARCHAR(255),
    event_name VARCHAR(255),
    iso VARCHAR(10),
    country VARCHAR(100),
    subregion VARCHAR(100),
    region VARCHAR(100),
    location TEXT,
    origin VARCHAR(50),
    associated_types TEXT,
    ofda_response VARCHAR(3),
    appeal VARCHAR(3),
    declaration VARCHAR(3),
    aid_contribution DOUBLE,
    magnitude DOUBLE,
    magnitude_scale VARCHAR(50),
    latitude DOUBLE,
    longitude DOUBLE,
    river_basin VARCHAR(100),
    start_year INT,
    start_month INT,
    start_day INT,
    end_year INT,
    end_month INT,
    end_day INT,
    total_deaths INT,
    no_injured INT,
    no_affected INT,
    no_homeless INT,
    total_affected INT,
    reconstruction_costs DOUBLE,
    reconstruction_costs_adjusted DOUBLE,
    insured_damage DOUBLE,
    insured_damage_adjusted DOUBLE,
    total_damage DOUBLE,
    total_damage_adjusted DOUBLE,
    cpi DOUBLE,
    admin_units VARCHAR(255),
    entry_date DATE,
    last_update DATE
);

LOAD DATA LOCAL 
INFILE '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/emdat.csv' 
INTO TABLE emdat
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;


use disasters;
-- Step 7. Verify that you imported 39910 rows.
SELECT count(*) FROM emdat;

-- Step 8. Verify that the data looks good!
SELECT * FROM emdat;



UPDATE emdat
SET
    reconstruction_costs = NULL
WHERE reconstruction_costs = 0;

UPDATE emdat
SET
    reconstruction_costs_adjusted = NULL
WHERE reconstruction_costs_adjusted = 0;

UPDATE emdat
SET
    insured_damage = NULL
WHERE insured_damage = 0;

UPDATE emdat
SET
    insured_damage_adjusted = NULL
WHERE insured_damage_adjusted = 0;

UPDATE emdat
SET
    total_damage = NULL
WHERE total_damage = 0;

UPDATE emdat
SET
    total_damage_adjusted = NULL
WHERE total_damage_adjusted = 0;

UPDATE emdat
SET
    end_day = NULL
WHERE end_day = 0;

UPDATE emdat
SET
    start_day = NULL
WHERE start_day = 0;

UPDATE emdat
SET
    start_month = NULL
WHERE start_month = 0;

UPDATE emdat
SET
    end_month = NULL
WHERE end_month = 0;

UPDATE emdat
SET
    start_year = NULL
WHERE start_year = 0;

UPDATE emdat
SET
    end_year = NULL
WHERE end_year = 0;

UPDATE emdat
SET
    total_deaths = NULL
WHERE total_deaths = 0;

UPDATE emdat
SET
    no_injured = NULL
WHERE no_injured = 0;

UPDATE emdat
SET
    no_affected = NULL
WHERE no_affected = 0;

UPDATE emdat
SET
    no_homeless = NULL
WHERE no_homeless = 0;

UPDATE emdat
SET
    total_affected = NULL
WHERE total_affected = 0;

UPDATE emdat
SET
    aid_contribution = NULL
WHERE aid_contribution = 0;

UPDATE emdat
SET
    latitude = NULL
WHERE latitude = 0;

UPDATE emdat
SET
    magnitude = NULL
WHERE magnitude = 0;

UPDATE emdat
SET
    longitude = NULL
WHERE longitude = 0;


select * from emdat;
select distinct disaster_subgroup from emdat;
