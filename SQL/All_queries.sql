select  * from CovidDeaths order by 3,4

--selecting the columns we want
select location, date, total_cases, new_cases, total_deaths, population from CovidDeaths order by 1,2

--loooking at total cases vs total deaths in India
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent from CovidDeaths 
where location like '%india%' order by 1,2

--looking at total cases vs population in India
select location, date, total_cases,population, (total_cases/population)*100 as TotalcasePercent from CovidDeaths 
where location like '%india%' order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths Group by location,population order by PercentPopulationInfected desc

select location, population, date, max(total_cases) as highestinfectioncount, max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths Group by location,population,date order by PercentPopulationInfected desc


--looking at countries with highest death count per population
select location, population,  max(convert(integer,total_deaths)) as highestdeathcount, max((total_deaths/population)*100) percentPopulationDied
from CovidDeaths where continent is not null
group by location,population order by highestdeathcount desc


--looking at data continent wise
select continent, max(total_cases) as highestTotalCaseCount, max(convert(integer,total_deaths)) as Totaldeathcount
from CovidDeaths where continent is not null
group by continent order by Totaldeathcount desc

select location, max(total_cases) as highestTotalCaseCount, max(convert(integer,total_deaths)) as Totaldeathcount
from CovidDeaths where continent is null
and location in ('Europe','North America','South America','Asia','Africa','Oceania')
group by location order by Totaldeathcount desc


--looking at global data
select sum(new_cases) as total_cases,sum(convert(int,new_deaths)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths where continent is not null

---------------------------------------------------------------------------------------------

select * from CovidVaccinations order by 3,4

-----------looking at total population vs vaccinations------------------
select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations  
from CovidDeaths cd JOIN CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 1,2,3

select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint,new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as DailyPeopleVaccinated
from CovidDeaths cd JOIN CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3

--use CTE to use column PeopleVaccinated
with cte as
(
select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint,new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as DailyPeopleVaccinated
from CovidDeaths cd JOIN CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null 
--order by 2,3				--cannot use order by in CTE
)
select *, (DailyPeopleVaccinated/population)*100 as PopVsVac from cte


--creating and using temp table
if OBJECT_ID(N'tempdb..#PercentPopulationVaccinated') is not NULL		     --alternate ways - If exists(select [name] from tempdb.sys.tables where [name] like '#PercentPopulationVaccinated%')           --DROP table if exists #PercentPopulationVaccinated - works only for SQL server 2016 or higher        
begin 
drop table #PercentPopulationVaccinated;
end

create Table #PercentPopulationVaccinated   
(
continent varchar(255),
location varchar(255),
date datetime,
population float,
new_vaccinations bigint,
DailyPeopleVaccinated float
)

Insert into #PercentPopulationVaccinated
select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint,new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as DailyPeopleVaccinated
from CovidDeaths cd JOIN CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null 

select *,(DailyPeopleVaccinated/population)*100 as PopVsVac from #PercentPopulationVaccinated order by 2,3

----------------creating a view------------------------
Create view PercentPopulationVaccinated as
select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint,new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as DailyPeopleVaccinated
from CovidDeaths cd JOIN CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null 

select * from PercentPopulationVaccinated