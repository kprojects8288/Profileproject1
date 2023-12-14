
SELECT *
FROM PortfolioProject.dbo.[Covid-deaths]
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject.dbo.[Covid-Vaccinations]
--ORDER BY 3,4

-- Total cases vs Total Deaths 
-- Shows likelihood of dying 

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.[Covid-deaths]
--WHERE location like '%states%'
ORDER BY 1,2

--total cases vs population 
-- percentage of population  who got covid

SELECT location, date, total_cases, population,  (total_cases/population)*100 as Percentpopulationinfected
FROM PortfolioProject.dbo.[Covid-deaths]
WHERE continent is not null
ORDER BY 1,2

-- Countries with Highest infection rates 
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as Percentpopulationinfected
FROM PortfolioProject.dbo.[Covid-deaths]
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY 4 desc

--Highest death count per population

SELECT location,  MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject.dbo.[Covid-deaths]
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY 2 desc

--breaking down by continent
--continents with highest deathcount

SELECT continent,  MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject.dbo.[Covid-deaths]
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY 2 desc

-GLobal NUmbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.[Covid-deaths]
WHERE continent is not NULL
Group by date
ORDER BY 1,2


--Total population vs Vaccinations

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.[Covid-deaths] dea
JOIN PortfolioProject.dbo.[Covid-Vaccinations] vac
  on  dea.location = vac.location
  and dea.date =  vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2,3

--Using CTE method

With PopvsVac (continent, location, date, population,new_vaccinations, rollingpeoplevaccinated) 
as
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.[Covid-deaths] dea
JOIN PortfolioProject.dbo.[Covid-Vaccinations] vac
  on  dea.location = vac.location
  and dea.date =  vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)

SELECT *,(rollingpeoplevaccinated/population)*100 
FROM PopvsVac


--USING temp table

DROP TABLE if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT into #PercentagePopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.[Covid-deaths] dea
JOIN PortfolioProject.dbo.[Covid-Vaccinations] vac
  on  dea.location = vac.location
  and dea.date =  vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *,(rollingpeoplevaccinated/population)*100 
FROM #PercentagePopulationVaccinated

--CREATING VIEWS to store data for later visualisations

Create View PrcentagePopulationVaccinated  as
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.[Covid-deaths] dea
JOIN PortfolioProject.dbo.[Covid-Vaccinations] vac
  on  dea.location = vac.location
  and dea.date =  vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3 