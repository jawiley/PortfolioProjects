-- COVID STATISTICS WORLDWIDE
-- https://ourworldindata.org/covid-deaths
-- DATA AS OF 20220118


--Verify data import
--Exclude continent and world groupings

SELECT *
FROM PortfolioProjectCOVID..CovidDeaths_20220118
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Selecting relevant columns

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectCOVID..CovidDeaths_20220118
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if  you contract COVID organized by Country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjectCOVID..CovidDeaths_20220118
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if  you contract COVID in United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjectCOVID..CovidDeaths_20220118
WHERE continent IS NOT NULL
and location LIKE '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population in United States
-- Shows what percentage of population got COVID (does not differentiate if unique individual vs subsequent infection)

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationInfectionPercentage
FROM PortfolioProjectCOVID..CovidDeaths_20220118
WHERE continent IS NOT NULL
and location LIKE '%states%'
ORDER BY 1,2


-- Looking at coutnries with highest infection count compared to population (does not differentiate if unique individual vs subsequent infection)

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases)/population)*100 AS PopulationInfectionPercentage
FROM PortfolioProjectCOVID..CovidDeaths_20220118
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopulationInfectionPercentage DESC


-- Showing countries with highest death count

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjectCOVID..CovidDeaths_20220118
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continent with highest death count
-- Excludes income groupings

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjectCOVID..CovidDeaths_20220118
WHERE continent IS NULL
and location NOT LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjectCOVID..CovidDeaths_20220118
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Checking vaccination dataset

SELECT *
FROM PortfolioProjectCOVID..CovidVaccinations_20220118


--Join death and vaccination data

SELECT *
FROM PortfolioProjectCOVID..CovidDeaths_20220118 dea
JOIN PortfolioProjectCOVID..CovidVaccinations_20220118 vac
	ON dea.location = vac.location
	AND dea.date = vac.date

	
-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProjectCOVID..CovidDeaths_20220118 dea
JOIN PortfolioProjectCOVID..CovidVaccinations_20220118 vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProjectCOVID..CovidDeaths_20220118 dea
JOIN PortfolioProjectCOVID..CovidVaccinations_20220118 vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM PopvsVac


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProjectCOVID..CovidDeaths_20220118 dea
JOIN PortfolioProjectCOVID..CovidVaccinations_20220118 vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated