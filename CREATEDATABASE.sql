show variables where variable_name like '%local%';
set global local_infile = on;

drop database if exists disasters;
create database disasters;
use disasters;

-- iso table
drop table if exists iso;
create table iso (
    iso_code char(3) primary key,
    country_name varchar(255) unique not null
);

load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/iso.csv'
into table iso
fields terminated by ',' enclosed by '"' lines terminated by '\n' ignore 1 rows
(iso_code, country_name);

-- insert ISO codes that were missing in this dataset but are present in the World Bank datasets
insert into iso (iso_code, country_name) values
('SSD', 'South Sudan'), 
('SXM', 'Sint Maarten');

select * from iso;

-- gdp table
drop table if exists gdp;
create table gdp (
    id char(7) primary key,
    iso_code char(3),
    year int,
    gdp_per_capita double,
    foreign key (iso_code) references iso(iso_code)
);

load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_gdp_per_capita.csv'
into table gdp
fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 rows
(iso_code, year, @gdp_val)
set gdp_per_capita = nullif(@gdp_val, ''), id = concat(iso_code, year);


-- emdat table
drop table if exists emdat;
create table emdat (
    disaster_id varchar(50) primary key,
    historic varchar(3),
    classification_key varchar(50),
    disaster_group varchar(50),
    disaster_subgroup varchar(50),
    disaster_type varchar(50),
    disaster_subtype varchar(50),
    event_name varchar(255),
    iso varchar(10),
    country varchar(100),
    subregion varchar(100),
    region varchar(100),
    ofda_response varchar(3),
    appeal varchar(3),
    declaration varchar(3),
    aid_contribution double,
    magnitude double,
    magnitude_scale varchar(50),
    latitude double,
    longitude double,
    river_basin varchar(100),
    start_year int,
    start_month int,
    start_day int,
    end_year int,
    end_month int,
    end_day int,
    total_deaths int,
    no_injured int,
    no_affected int,
    no_homeless int,
    total_affected int,
    reconstruction_costs double,
    reconstruction_costs_adjusted double,
    insured_damage double,
    insured_damage_adjusted double,
    total_damage double,
    total_damage_adjusted double,
    cpi double,
    entry_date date,
    last_update date,
    id char(7),
    foreign key (id) references gdp(id)
);

-- load data into emdat table
load data local infile '/users/anniedendas/desktop/spring2025/cs3200/project/data/matched_emdat.csv'
into table emdat
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(
    disaster_id,
    historic,
    classification_key,
    disaster_group,
    disaster_subgroup,
    disaster_type,
    disaster_subtype,
    @external_ids,
    event_name,
    iso,
    country,
    subregion,
    region,
    @location,
    @origin,
    @associated_types,
    ofda_response,
    appeal,
    declaration,
    @aid_contribution,
    @magnitude,
    magnitude_scale,
    @latitude,
    @longitude,
    river_basin,
    @start_year,
    @start_month,
    @start_day,
    @end_year,
    @end_month,
    @end_day,
    @total_deaths,
    @no_injured,
    @no_affected,
    @no_homeless,
    @total_affected,
    @reconstruction_costs,
    @reconstruction_costs_adjusted,
    @insured_damage,
    @insured_damage_adjusted,
    @total_damage,
    @total_damage_adjusted,
    cpi,
    @admin_units,
    entry_date,
    last_update
)
set
    aid_contribution = nullif(@aid_contribution, ''),
    magnitude = nullif(@magnitude, ''),
    latitude = nullif(@latitude, ''),
    longitude = nullif(@longitude, ''),
    start_year = nullif(@start_year, ''),
    start_month = nullif(@start_month, ''),
    start_day = nullif(@start_day, ''),
    end_year = nullif(@end_year, ''),
    end_month = nullif(@end_month, ''),
    end_day = nullif(@end_day, ''),
    total_deaths = nullif(@total_deaths, ''),
    no_injured = nullif(@no_injured, ''),
    no_affected = nullif(@no_affected, ''),
    no_homeless = nullif(@no_homeless, ''),
    total_affected = nullif(@total_affected, ''),
    reconstruction_costs = nullif(@reconstruction_costs, ''),
    reconstruction_costs_adjusted = nullif(@reconstruction_costs_adjusted, ''),
    insured_damage = nullif(@insured_damage, ''),
    insured_damage_adjusted = nullif(@insured_damage_adjusted, ''),
    total_damage = nullif(@total_damage, ''),
    total_damage_adjusted = nullif(@total_damage_adjusted, '');

-- remove data from years not covered in World Bank datasets (2024+)
delete from emdat
where start_year > 2023;

-- assign id to match gdp(id) foreign key
update emdat
set id = concat(iso, start_year)
where start_year is not null and iso is not null;

-- inflation adjustment to 2015 usd
update emdat set reconstruction_costs_adjusted = reconstruction_costs_adjusted * 0.7149 where reconstruction_costs_adjusted is not null;
update emdat set insured_damage_adjusted = insured_damage_adjusted * 0.7149 where insured_damage_adjusted is not null;
update emdat set total_damage_adjusted = total_damage_adjusted * 0.7149 where total_damage_adjusted is not null;


-- urban population
drop table if exists urb_pop;
create table urb_pop (
    id char(7),
    iso_code char(3),
    year int,
    urb_pop_percentage double,
    foreign key (id) references gdp(id),
    foreign key (iso_code) references iso(iso_code)
);

load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_urban_pop_percentage.csv'
into table urb_pop
fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 rows
(iso_code, year, @urb_pop_percentage)
set urb_pop_percentage = nullif(@urb_pop_percentage, ''), id = concat(iso_code, year);

-- literacy rate
drop table if exists lit_rate;
create table lit_rate (
    id char(7),
    iso_code char(3),
    year int,
    rate double,
    foreign key (id) references gdp(id),
    foreign key (iso_code) references iso(iso_code)
);

load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_literacy_rates.csv'
into table lit_rate
fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 rows
(iso_code, year, @rate)
set rate = nullif(@rate, ''), id = concat(iso_code, year);

-- life expectancy
drop table if exists life_exp;
create table life_exp (
    id char(7),
    iso_code char(3),
    year int,
    expectancy double,
    foreign key (id) references gdp(id),
    foreign key (iso_code) references iso(iso_code)
);

load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_life_expectancy.csv'
into table life_exp
fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 rows
(iso_code, year, @expectancy)
set expectancy = nullif(@expectancy, ''), id = concat(iso_code, year);

-- tourism
drop table if exists int_tour;
create table int_tour (
    id char(7),
    iso_code char(3),
    year int,
    tourism double,
    foreign key (id) references gdp(id),
    foreign key (iso_code) references iso(iso_code)
);

load data local infile '/Users/anniedendas/Desktop/Spring2025/CS3200/Project/data/world_bank/wb_tourism.csv'
into table int_tour
fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 rows
(iso_code, year, @tourism)
set tourism = nullif(@tourism, ''), id = concat(iso_code, year);
