-- PLEASE NOTE THAT ALL QUERIES BELOW ARE USING NATURAL DISASTER EVENTS FROM 1960-2025
-- this file contains all queries on our database for the project

use disasters;

-- query one: does a higher average GDP per capita (in constant 2015 USD) correlate with fewer 
-- deaths per flood event among countries that have experienced at least three flood disasters,
-- aggregated at the country level?
select 
    e.iso,
    i.country_name,
    round(avg(g.gdp_per_capita), 2) as avg_gdp_per_capita,
    avg(e.total_deaths) as avg_deaths_per_flood,
    count(*) as num_floods
from emdat e
join gdp g on e.iso = g.iso_code and e.start_year = g.year
join iso i on e.iso = i.iso_code
where 
    e.total_deaths is not null 
    and g.gdp_per_capita is not null
    and e.disaster_type = 'Flood'
group by 
    e.iso, i.country_name
having num_floods >= 3
-- remove 'desc' to see countries w/ least amt of deaths first
order by avg_deaths_per_flood desc;


-- query two: is there a correlation between literacy rates of a country and the number of people 
-- rendered homeless by tropical cyclones?
select 
    e.iso,
    i.country_name,
    e.start_year,
    round(l.rate, 2) as literacy_rate,
    count(e.disaster_id) as num_cyclones,
    sum(e.no_homeless) as total_homeless,
    round(sum(e.no_homeless) / count(e.disaster_id), 2) as avg_homeless_per_cyclone
from emdat e
join lit_rate l on e.iso = l.iso_code and e.start_year = l.year
join iso i on e.iso = i.iso_code
where 
    e.no_homeless is not null
    and l.rate is not null
    and e.disaster_subtype = 'Tropical cyclone'
group by 
    e.iso, i.country_name, e.start_year, l.rate
order by avg_homeless_per_cyclone desc, num_cyclones desc;


-- query 3: how does the average number of disasters per year relate to a country’s average 
-- life expectancy?
select 
    e.iso,
    i.country_name,
    round(avg(l.expectancy), 2) as avg_life_expectancy,
    round(count(e.disaster_id) / count(distinct e.start_year), 2) as avg_disasters_per_year
from emdat e
join life_exp l on e.iso = l.iso_code and e.start_year = l.year
join iso i on e.iso = i.iso_code
where l.expectancy is not null
group by e.iso, i.country_name
order by avg_disasters_per_year desc, avg_life_expectancy desc;

-- query 4: do countries with increasing disaster rates show slower growth in life expectancy over time
-- compared to countries with fewer disasters? (Do recurring disasters have a long-term impact on population
-- health/ are some countries resilient despite frequent extreme events?)
select 
    e.iso,
    i.country_name,
    e.start_year,
    count(e.disaster_id) as num_disasters,
    l.expectancy as life_expectancy
from emdat e
join life_exp l on e.iso = l.iso_code and e.start_year = l.year
join iso i on e.iso = i.iso_code
where l.expectancy is not null
group by e.iso, i.country_name, e.start_year, l.expectancy
order by e.iso, e.start_year;

-- query 5: do countries with higher GDP per capita maintain stronger life expectancy
-- trends over time despite experiencing frequent natural disasters, compared to lower-income countries?
select 
    e.iso,
    i.country_name,
    e.start_year,
    round(avg(g.gdp_per_capita), 2) as gdp_per_capita,
    case 
        when avg(g.gdp_per_capita) > 12695 then 1
        when avg(g.gdp_per_capita) between 1136 and 12695 then 2
        when avg(g.gdp_per_capita) < 1136 then 3
        else null
    end as income_group,
    round(avg(l.expectancy), 2) as life_expectancy,
    count(e.disaster_id) as num_disasters
from emdat e
join gdp g on e.iso = g.iso_code and e.start_year = g.year
join life_exp l on e.iso = l.iso_code and e.start_year = l.year
join iso i on e.iso = i.iso_code
where 
    g.gdp_per_capita is not null
    and l.expectancy is not null
group by 
    e.iso, i.country_name, e.start_year
order by 
    e.iso, e.start_year;

-- query 6: which types of disasters cause the most economic damage in countries with high urban density? 
select 
    e.disaster_type,
    count(e.disaster_id) as num_events,
    round(sum(e.total_damage_adjusted), 2) as total_damage,
    round(avg(e.total_damage_adjusted), 2) as avg_damage_per_event
from emdat e
join urb_pop u on e.iso = u.iso_code and e.start_year = u.year
where 
    e.total_damage_adjusted is not null
    and u.urb_pop_percentage > 75
group by 
    e.disaster_type
order by 
    total_damage desc;

-- query 7: How do major natural disasters (specifically floods, hurricanes, and earthquakes) affect international
-- tourism levels in affected countries, and how long does it take for tourism to recover?
with yearly_disasters as (
  select 
    e.iso,
    e.start_year,
    e.disaster_type,
    count(*) as disaster_count,
    round(sum(e.total_damage_adjusted), 2) as total_economic_damage
  from emdat e
  where 
    e.total_damage_adjusted is not null
    and e.disaster_type in ('flood', 'hurricane', 'earthquake')
  group by e.iso, e.start_year, e.disaster_type
),
tourism_data as (
  select 
    iso_code,
    year,
    round(max(tourism), 2) as arrivals
  from int_tour
  group by iso_code, year
)

select 
    yd.iso,
    i.country_name,
    yd.start_year as year,
    yd.disaster_type,
    yd.disaster_count,
    yd.total_economic_damage,
    round(g.gdp_per_capita, 2) as gdp_per_capita,
    t_before.arrivals as tourism_previous_year,
    t_current.arrivals as tourism_disaster_year,
    t_after.arrivals as tourism_following_year,

    case 
      when t_before.arrivals is not null and t_current.arrivals is not null then
        round((t_current.arrivals - t_before.arrivals) / t_before.arrivals * 100, 2)
      else null
    end as percent_change_during_year,

    case 
      when t_before.arrivals is not null and t_after.arrivals is not null then
        round((t_after.arrivals - t_before.arrivals) / t_before.arrivals * 100, 2)
      else null
    end as percent_change_after_one_year

from yearly_disasters yd
join iso i on yd.iso = i.iso_code
join gdp g on yd.iso = g.iso_code and yd.start_year = g.year
join tourism_data t_current on yd.iso = t_current.iso_code and yd.start_year = t_current.year
join tourism_data t_before on yd.iso = t_before.iso_code and t_before.year = yd.start_year - 1
join tourism_data t_after on yd.iso = t_after.iso_code and t_after.year = yd.start_year + 1

order by yd.start_year, yd.iso, yd.disaster_type;


-- query 8: what is the average natural disaster recovery time in low gdp countries vs high gdp countries?
select 
    e.iso,
    i.country_name,
    count(e.disaster_id) as num_disasters,
    round(avg(g.gdp_per_capita), 2) as avg_gdp_per_capita,
    avg(l.expectancy) as avg_life_expectancy,
    max(e.start_year) - min(e.start_year) as recovery_time
from emdat e
join gdp g on e.iso = g.iso_code and e.start_year = g.year
join life_exp l on e.iso = l.iso_code and e.start_year = l.year
join iso i on e.iso = i.iso_code
where g.gdp_per_capita is not null and l.expectancy is not null
group by e.iso, i.country_name, e.disaster_type
having recovery_time >= 2  -- Adjust for countries with multiple disasters
order by recovery_time asc;