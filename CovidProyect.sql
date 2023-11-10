SELECT *
FROM PortafolioProyect..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortafolioProyect..CovidVaccinations
--order by 3,4

--Select Data that we are going to use

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortafolioProyect..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths

SELECT location,date,total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage 
FROM PortafolioProyect..CovidDeaths
WHERE location like '%states%' and  continent is not null
order by 1,2


--Look at the total cases vs population
--Shows what percentage of the population got infected

SELECT location,date,total_cases,population, (CONVERT(float, total_cases)/population)*100 as PercentPopulationInfected 
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(CONVERT(float,total_cases)) as HighestInfectionCount, MAX((CONVERT(float, total_cases)/population))*100 as PercentPopulationInfected  
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%'
Group By location, population
order by PercentPopulationInfected desc

--Showing Countries with the Highest death count per Population

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%'
where continent is not null
Group By location, population
order by TotalDeathCount desc

-- Break things down by continent

-- Showing the continents with highest death count

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers by day

SELECT date,Sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage 
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%' 
where continent is not null
Group by date
order by 1,2

-- Global Numbers

SELECT Sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage 
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%' 
where continent is not null
--Group by date
order by 1,2



-- Looking total Population vs Vaccinations

Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortafolioProyect..CovidDeaths dea
join PortafolioProyect..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3



-- Use CTE (Common Table Expression)

with PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortafolioProyect..CovidDeaths dea
join PortafolioProyect..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Use Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255) ,
location nvarchar (255) , 
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortafolioProyect..CovidDeaths dea
join PortafolioProyect..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Drop View if exists PercentPopulationVaccinated
USE PortafolioProyect
go
Create view PercentPopulationVaccinated as 
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortafolioProyect..CovidDeaths dea
join PortafolioProyect..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
from PercentPopulationVaccinated

/*

Queries used for Tableu Proyect

*/

--1.

SELECT Sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage 
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%' 
where continent is not null
--Group by date
order by 1,2

--Just a double check based off the data provided
-- numbers are extremly close so will keep them - The Second includes "International" location

--2.

--We take these out as they not include in the above queries and want to stay consistent 
-- European Union is part of Europe 

SELECT location ,sum(new_deaths) as TotalDeathCount
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%' 
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--3.

SELECT location, population, MAX(CONVERT(float,total_cases)) as HighestInfectionCount, MAX((CONVERT(float, total_cases)/population))*100 as PercentPopulationInfected  
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%'
Group By location, population
order by PercentPopulationInfected desc

--4.

SELECT location, population,date, MAX(CONVERT(float,total_cases)) as HighestInfectionCount, MAX((CONVERT(float, total_cases)/population))*100 as PercentPopulationInfected  
FROM PortafolioProyect..CovidDeaths
--WHERE location like '%states%'
Group By location, population, date
order by PercentPopulationInfected desc
