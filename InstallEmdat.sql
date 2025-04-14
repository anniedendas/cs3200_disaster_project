-- FILE TO INSTALL EMDAT DATABASE ON MYSQL, NEED TO INSERT YOUR OWN 
-- FILEPATH WHERE IT SAYS '/Users/shefaliverma/Downloads/EMDATdata1960-2025allcountries.csv' "

show variables where variable_name like '%local%';
set global local_infile=ON;

drop database if exists disasters;
create database disasters;
use disasters;

-- create emdat table
drop table if exists emdat;
CREATE TABLE emdat (
    disaster_id VARCHAR(50) primary key,
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

-- populate emdat table
LOAD DATA LOCAL 
INFILE '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/matched_emdat.csv' 
INTO TABLE emdat
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;

-- verify that you imported 16418 rows
SELECT count(*) FROM emdat;

-- verify that the data looks good
SELECT * FROM emdat;

-- update any 0 values to be NULL
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

-- dropping the attributes below because they will not be useful in our analysis
alter table emdat
drop column external_ids,
drop column location,
drop column origin,
drop column associated_types,
drop column admin_units;

describe emdat;

-- update existing adjusted columns to reflect constant 2015 usd (based on OECD inflation data)
update emdat
set reconstruction_costs_adjusted = reconstruction_costs_adjusted * 0.7149
where reconstruction_costs_adjusted is not null;

update emdat
set insured_damage_adjusted = insured_damage_adjusted * 0.7149
where insured_damage_adjusted is not null;

update emdat
set total_damage_adjusted = total_damage_adjusted * 0.7149
where total_damage_adjusted is not null;

-- create GDP table
drop table if exists gdp;
create table gdp (
	id int primary key auto_increment,
    iso_code char(3),
    year int,
    gdp_per_capita double
);

-- populate GDP table
load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_gdp_per_capita.csv'
into table gdp
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(iso_code, year, @gdp_val)
set gdp_per_capita = nullif(@gdp_val, '');

-- verify that you imported 13120 rows
select count(*) from gdp;

-- verify that the data looks good
select * from gdp;

-- create urban population table
drop table if exists urb_pop;
create table urb_pop (
	id int primary key auto_increment,
    iso_code char(3),
    year int,
    urb_pop_percentage double
);

-- populate urban population table
load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_urban_pop_percentage.csv'
into table urb_pop
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(iso_code, year, @urb_pop_percentage)
set urb_pop_percentage = nullif(@urb_pop_percentage, '');

-- verify that you imported 13120 rows
select count(*) from urb_pop;

-- verify that the data looks good
select * from urb_pop;

-- create literacy rates table
drop table if exists lit_rate;
create table lit_rate (
	id int primary key auto_increment,
    iso_code char(3),
    year int,
    rate double
);

-- populate literacy rates table
load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_literacy_rates.csv'
into table lit_rate
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(iso_code, year, @rate)
set rate = nullif(@rate, '');

-- verify that you imported 13120 rows
select count(*) from lit_rate;

-- verify that the data looks good
select * from lit_rate;

-- create life expectancy at birth table
drop table if exists life_exp;
create table life_exp (    
	id int primary key auto_increment,
	iso_code char(3),
    year int,
    expectancy double
);

-- populate life expectancy at birth table
load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_life_expectancy.csv'
into table life_exp
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(iso_code, year, @expectancy)
set expectancy = nullif(@expectancy, '');

-- verify that you imported 13120 rows
select count(*) from life_exp;

-- verify that the data looks good
select * from life_exp;

-- create international tourism table
drop table if exists int_tour;
create table int_tour (    
	id int primary key auto_increment,
	iso_code char(3),
    year int,
    tourism double
);

-- populate tourism rates table
load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_tourism.csv'
into table int_tour
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(iso_code, year, @tourism)
set tourism = nullif(@tourism, '');

-- verify that you imported 13120 rows
select count(*) from int_tour;

-- verify that the data looks good
select * from int_tour;

-- create ISO table (maps ISO codes to country names)
drop table if exists iso;
create table iso (
    id int primary key auto_increment,
    iso_code varchar(3) unique not null,
    country_name varchar(255) unique not null
);

-- populate the table
load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/iso.csv'
into table iso
fields terminated by ',' 
enclosed by '"' 
lines terminated by '\n' 
ignore 1 rows
(iso_code, country_name);

-- verify that you imported 205 rows
select count(*) from iso;

-- verify that the data looks good
select * from iso;



