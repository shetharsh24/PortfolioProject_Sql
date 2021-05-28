select *
from ['covid-deaths$']

select location, date, total_cases, new_cases, total_deaths, population
from dbo.['covid-deaths$']
order by 1,2

-- Looking at Total Cases vs Total Deaths
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as [Death %]
from dbo.['covid-deaths$']
where location = 'India'
order by 1,2

-- Looking at Total Cases vs Population
select location, date, total_cases, new_cases, population, (total_cases/population)*100 as [Case %]
from dbo.['covid-deaths$']
where location = 'India'
order by 1,2

-- Looking at countries with highest infection rate
select location, max(total_cases) as maxinfected, population, max((total_cases/population)*100) as [Case %]
from dbo.['covid-deaths$']
group by location, population
order by [Case %] desc

-- Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as maxdeaths
from dbo.['covid-deaths$']
where continent is not null
group by location
order by maxdeaths desc

-- Looking at deaths by continents
select continent, max(cast(total_deaths as int)) as maxdeaths
from dbo.['covid-deaths$']
where continent is not null
group by continent
order by maxdeaths desc

-- Looking at new cases and deaths - Date wise
select date, sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as [death ratio]
from ['covid-deaths$']
where continent is not null
group by date

-- Total cases
select sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as [death ratio]
from ['covid-deaths$']
where continent is not null

select *
from ['covid-vaccinations$']

-- Looking at total population vs vaccination
select a.continent,a.location, a.date, a.population,coid_vacc_1$.new_vaccinations, 
SUM(CAST(coid_vacc_1$.new_vaccinations as int)) OVER (Partition by a.location order by a.location, a.date) as People_vaccinated_aggregate
from ['covid-deaths$'] a
join coid_vacc_1$ on
a.location = coid_vacc_1$.location
and
a.date = coid_vacc_1$.date
where a.continent is not null
order by 2,3

-- Using CTE
with popvsvac (continent, locaiton,date,population,new_vaccinations, People_vaccinated_aggregate)
as 
(
select a.continent,a.location, a.date, a.population,coid_vacc_1$.new_vaccinations, 
SUM(CAST(coid_vacc_1$.new_vaccinations as int)) OVER (Partition by a.location order by a.location, a.date) as People_vaccinated_aggregate
from ['covid-deaths$'] a
join coid_vacc_1$ on
a.location = coid_vacc_1$.location
and
a.date = coid_vacc_1$.date
where a.continent is not null
--order by 2,3
)
select *, (People_vaccinated_aggregate/population)*100 as [Percentage_vaccinated]
from popvsvac



-- Creating a view
create view Percentage_vaccinated as
select a.continent,a.location, a.date, a.population,coid_vacc_1$.new_vaccinations, 
SUM(CAST(coid_vacc_1$.new_vaccinations as int)) OVER (Partition by a.location order by a.location, a.date) as People_vaccinated_aggregate
from ['covid-deaths$'] a
join coid_vacc_1$ on
a.location = coid_vacc_1$.location
and
a.date = coid_vacc_1$.date
where a.continent is not null
--order by 2,3

