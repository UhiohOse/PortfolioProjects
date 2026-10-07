select * 
from PortfolioProject..CovidDeaths$
where continent is not null 
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using
select Location , date, total_cases , new_cases , total_cases ,population
from PortfolioProject..CovidDeaths$
order by 1,2


--Looking at the Total Cases vs Total Deaths
--shows the likehood of dying if you contract covid in your country
select Location , date, total_cases  ,total_deaths, (total_deaths/total_cases*100) as Death_percentage
from PortfolioProject..CovidDeaths$
where location like '%nigeria%'
order by 1,2

-- looking at Total Cases vs population
--shows what percentage of population  got covid
select Location , date, population, total_cases   ,(total_cases/population *100) as percentpopulationinfected
from PortfolioProject..CovidDeaths$
where location like '%nigeria%'
order by 1,2 

--looking at countries with highest infection rate compared to population
select Location , population, max(total_cases) as Highestinfectioncount   ,(max(total_cases)/population *100) as percentpopulationinfected
from PortfolioProject..CovidDeaths$
--where location like '%nigeria%'
group by location , population
order by percentpopulationinfected desc

--LET'S BREAK  THINGS DOWN BBY CONTINENT


--showing the continent with the highest death count per population
select continent,  max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths$
--where location like '%nigeria%'
where continent is not null 
group by continent
order by Totaldeathcount desc

--showing countries with highest death count per population
select Location ,  max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths$
--where location like '%nigeria%'
where continent is not null 
group by location , population
order by Totaldeathcount desc


--GLOBAL NUMBERS
select   sum(new_cases) as totalcases ,sum(cast(new_deaths as int))as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths$
--where location like '%nigeria%'
WHERE continent is not null
--group by date
order by 1,2

--looking at total population vs vaccination
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by  dea.location)as rollingpeoplevaccinated

from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
order by 2,3


-- USE CTE
with PopvsVac(continent ,location , date , population ,new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by  dea.location order by dea.location ,
 dea.date)as rollingpeoplevaccinated

from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3
 )
 select * , (rollingpeoplevaccinated/population)*100
 from PopvsVac

 --TEMP TABLE
 IF OBJECT_ID('tempdb..#Percentpopulationvaccinated') IS NOT NULL
    DROP TABLE #Percentpopulationvaccinated
 CREATE TABLE #percentpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )

 insert into #percentpopulationvaccinated
 select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by  dea.location)as rollingpeoplevaccinated

from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
--WHERE dea.continent is not null
--order by 2,3

 select * , (rollingpeoplevaccinated/population)*100
 from #percentpopulationvaccinated


 --------------------------------------------------------------------------------------------------------------------------------
------------------------------Creating view to store data for later visualization------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
use PortfolioProject
go
 --IF OBJECT_ID('tempdb..#Percentpopulationvaccinated') IS NOT NULL
 --   DROP view #Percentpopulationvaccinated
 Create view percentpopulationvaccinated  as
 select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by  dea.location)as rollingpeoplevaccinated

from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3

--creating view for Looking at the Total Cases vs Total Deaths
--shows the likehood of dying if you contract covid in your country
create view  mortality_rate_of_nigeria_covid_case as
select Location , date, total_cases  ,total_deaths, (total_deaths/total_cases*100) as Death_percentage
from PortfolioProject..CovidDeaths$
where location like '%nigeria%'
--order by 1,2


--creating view for looking at Total Cases vs population
--shows what percentage of population  got covid
 create view  percentage_of_infected_Nigerians   as
select Location , date, population, total_cases   ,(total_cases/population *100) as percentpopulationinfected
from PortfolioProject..CovidDeaths$
where location like '%nigeria%'

-- Creating view for looking at countries with highest infection rate compared to population
create view percentpopulationinfected as
select Location , population, max(total_cases) as Highestinfectioncount   ,(max(total_cases)/population *100) as percentpopulationinfected
from PortfolioProject..CovidDeaths$
--where location like '%nigeria%'
group by location , population
--order by percentpopulationinfected desc


-- creating view for showing the continent with the highest death count per population
create view Total_death_count_per_continent as
select continent,  max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths$
--where location like '%nigeria%'
where continent is not null 
group by continent
--order by Totaldeathcount desc


-- creating view to show GLOBAL NUMBERS
create view Global_numbers as
select   sum(new_cases) as totalcases ,sum(cast(new_deaths as int))as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths$
--where location like '%nigeria%'
WHERE continent is not null
--group by date
--order by 1,2



-- Creating view for looking at total population vs vaccination
create view total_no_of_people_vaccinated as
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by  dea.location)as rollingpeoplevaccinated

from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3

--Create view for percent population vaccinated
create view percent_vaccinated as
--CREATE TABLE percentpopulationvaccinated_1
-- (
-- continent nvarchar(255),
-- location nvarchar(255),
-- date datetime,
-- population numeric,
-- new_vaccinations numeric,
-- rollingpeoplevaccinated numeric
-- )

-- insert into percentpopulationvaccinated_1
-- select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
--,sum(cast(vac.new_vaccinations as int)) OVER (partition by  dea.location)as rollingpeoplevaccinated

--from PortfolioProject..CovidDeaths$ dea
-- join PortfolioProject..CovidVaccinations$ vac
--    on dea.location=vac.location
--	and dea.date=vac.date
----WHERE dea.continent is not null
----order by 2,3

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS rollingpeoplevaccinated,
    (SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) * 1.0 / dea.population) * 100 AS percent_vaccinated   
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
GO

