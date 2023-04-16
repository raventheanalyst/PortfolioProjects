SELECT * 
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

--Select that data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2 


-- looking at the Total Cases vs Total Deaths (Shows Liklihood of dying if you contract Covid in the US/your country)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE Location LIKE '%states'
ORDER BY 1,2 


--Looking at the Total Cases vs Poulation
Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
WHERE Location LIKE '%states'
ORDER BY 1,2 


--Looking at Countries with Highest Infection Rate compared to Population (What population of your country has gotten COVID) 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE Location LIKE '%states'
GROUP BY Location, population
ORDER BY 4 DESC

-- BREAKING THINGS DOWN BY CONTINENT
 

--Showing the Countries with the Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths
--WHERE Location LIKE '%states'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing Continents with the Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths
--WHERE Location LIKE '%states'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE Location LIKE '%states'
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2 

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated, 
(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea 
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3 

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea 
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac



-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea 
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations 

Create View PercentPopulationView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea 
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3


Select *
FROM PercentPopulationView 