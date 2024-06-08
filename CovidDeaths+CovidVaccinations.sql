SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
order by 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
--shows likelihood of dying if u contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND continent IS NOT NULL
order by 1,2

--looking at Total Cases vs Population
--shows what percentage of population that got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2

--Looking at countries with highest infection rates
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
order by 4 DESC


-- LET*S BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
--THESE ARE THE CORRECT CONTINENT NUMBERS
WHERE continent IS NULL
GROUP BY location
Order by TotalDeathCount desc



Create view DeathCountContinent as 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
--THESE ARE THE CORRECT CONTINENT NUMBERS
WHERE continent IS NULL
GROUP BY location


--Showing Countries with highest Death Count
--Convert to int, weird numbers like 998 998772 99872, use cast
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
--null continents are put into location column thats why we remove null continent
--is actually incorrect numbers for continents
WHERE continent IS NOT NULL
GROUP BY Location
Order by TotalDeathCount desc

--Showing continents with highest death count
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY continent
Order by TotalDeathCount desc

-- Global numbers
SELECT SUM((new_cases)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2

-- Looking at Total Population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.Location, dea.date) AS RollingPeopleVaccinated
--can't use aggregate functions with RollingPeopleVaccinated, using temptable below
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
Order by 2,3



--USE CTE

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.Location, dea.date) AS RollingPeopleVaccinated
--can't use aggregate functions with RollingPeopleVaccinated, using temptable below
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
--numeric data type instead of int/float
( 
continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.Location, dea.date) AS RollingPeopleVaccinated
--can't use aggregate functions with RollingPeopleVaccinated, using temptable below
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
Order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later vizualizations (tableau, powerbi)

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.Location, dea.date) AS RollingPeopleVaccinated
--can't use aggregate functions with RollingPeopleVaccinated, using temptable below
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order by 2,3

SELECT *
FROM PercentPopulationVaccinated


