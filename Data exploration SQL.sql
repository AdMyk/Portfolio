/*
The "Covid 19 Data Exploration" project is a data analysis project that uses SQL to explore data related to the COVID-19 pandemic. The project utilizes various SQL techniques such as joins, CTE's, windows functions, aggregate functions, data type conversions, and formatting to extract insights and generate various statistics such as total cases vs total deaths, total cases vs population, countries with highest infection rate, continents with highest death count, global numbers and total population vs vaccinations. The project provides a detailed analysis of the data and provides a deeper understanding of the impact of the pandemic on different locations and continents.
*/

SELECT *
	FROM CovidDeaths
	WHERE continent is not null 
	ORDER BY 3,4


-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM CovidDeaths
	WHERE continent is not null 
	ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location,date,total_cases, ISNULL(total_deaths,0) AS 'Total Deaths',ISNULL(FORMAT((CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT)*100),'0.00'),0) AS DeathPercentage
	FROM CovidDeaths
	WHERE location like '%Poland%'	
	ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases, ISNULL(FORMAT((CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)*100),'0.00'),0) AS PercentPopulationInfected
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, CAST(Max((total_cases/CAST(population AS FLOAT)))*100 AS DECIMAL(16,2)) AS PercentPopulationInfected
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY Location, Population
	ORDER BY 4 DESC


	-- Countries with Highest Death Count per Population

SELECT Location, Population, MAX(total_deaths) AS HighestDeathCount, CAST(Max((total_deaths/CAST(population AS FLOAT)))*100 AS DECIMAL(16,2)) AS DeathsPercentage
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY Location, Population
	ORDER BY 4 DESC


	-- BREAK DOWN BY CONTINENT

	-- Showing contintents with the highest death count

SELECT location,MAX(total_deaths) as TotalDeaths	
	FROM CovidDeaths 
	WHERE continent IS NULL AND location NOT IN ('World','International','European Union')
	GROUP BY location
	ORDER BY TotalDeaths DESC


	-- Continents with Highest Death Count per Population

SELECT continent, MAX(Population) Population, MAX(total_deaths) AS HighestDeathCount, CAST(Max((total_deaths/CAST(population AS FLOAT)))*100 AS DECIMAL(16,2)) AS DeathsPercentage
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY 4 DESC



	-- Continents with Highest Infection Count per Population

SELECT continent, MAX(Population) Population, MAX(total_cases) AS HighestInfectionCount, CAST(Max((total_cases/CAST(population AS FLOAT)))*100 AS DECIMAL(16,2)) AS PercentPopulationInfected
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY 4 DESC


--GLOBAL NUMBERS

SELECT date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	FROM CovidDeaths
	WHERE continent is not null AND date > '2020-01-22'
	GROUP BY date
	ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM CovidDeaths dea
		JOIN CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
	ORDER BY 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *,
	 ROUND((CAST(RollingPeopleVaccinated as float)/CAST(Population AS float))*100,2) as Vaccination_rate
	
FROM PopvsVac;
