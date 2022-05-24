--1 - looking at global data
select sum(new_cases) as total_cases,sum(convert(int,new_deaths)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths where continent is not null


--2 - looking at data continent wise
select location, max(total_cases) as highestTotalCaseCount, max(convert(integer,total_deaths)) as Totaldeathcount
from CovidDeaths where continent is null
and location in ('Europe','North America','South America','Asia','Africa','Oceania')
group by location order by Totaldeathcount desc


--3 - looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths Group by location,population order by PercentPopulationInfected desc


--4 - looking at countries with highest infection rate compared to population on each day
select location, population, date, max(total_cases) as highestinfectioncount, max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths Group by location,population,date order by PercentPopulationInfected desc