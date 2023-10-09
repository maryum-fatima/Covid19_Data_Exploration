--Data Exploration in SQL

--Total cases, New cases, Total deaths due to Covid-19 in each country

SELECT
	location, date, total_cases, new_cases, total_deaths, population
FROM
	[Portfolio Project]..CovidDeaths$
ORDER BY
	1,2



--Total cases vs Total deaths

--Shows Likelihood of dying if you contract covid in your country

SELECT
	location, date, total_cases, total_deaths, ROUND(((total_deaths/total_cases)*100), 2) AS DeathPercentage
FROM
	[Portfolio Project]..CovidDeaths$
WHERE 
	location = 'Pakistan'
ORDER BY
	1,2



--Total cases vs Population

-- Shows percentage of people got covid

SELECT
	location, date, total_cases, population, ROUND(((total_cases/population)*100), 2) AS InfectedPercentage
FROM
	[Portfolio Project]..CovidDeaths$
WHERE 
	location = 'Pakistan'
ORDER BY
	1,2



--Countries with highest infection rate compared to population

SELECT
	Location,  Population, MAX(total_cases) as Highest_Infection_Count, ROUND(MAX((total_cases/population)*100), 2) AS Highest_Infected_Percentage
FROM
	[Portfolio Project]..CovidDeaths$
GROUP BY
	location, population
ORDER BY
	Highest_Infected_Percentage DESC




--Showing countries with highest death count per population

SELECT
	Location, MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM
	[Portfolio Project]..CovidDeaths$
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	Total_Death_Count DESC



--Breaking things down by continent

--Continents with highest death count per population

SELECT
	Continent, MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM
	[Portfolio Project]..CovidDeaths$
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	Total_Death_Count DESC




--GLOBAL NUMBERS

SELECT
	date ,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM
	[Portfolio Project]..CovidDeaths$
WHERE
	continent IS NOT NULL
GROUP BY
	date
ORDER BY
	1, 2




--GLOBAL NUMBERS

SELECT
	SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM
	[Portfolio Project]..CovidDeaths$
WHERE
	continent IS NOT NULL
ORDER BY
	1, 2




--Total population vs Total vaccinations

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	[Portfolio Project]..CovidDeaths$ AS dea
JOIN 
	[Portfolio Project]..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
)

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From PopvsVac




--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	[Portfolio Project]..CovidDeaths$ AS dea
JOIN 
	[Portfolio Project]..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From #PercentPopulationVaccinated




--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	[Portfolio Project]..CovidDeaths$ AS dea
JOIN 
	[Portfolio Project]..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated