SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3, 4

---select data that we are going to be using--

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


--looking at total cases vs total deaths (whats the percentage of the deaths from total cases)
--shows likelihood of dying if you contract covid in your country


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND WHERE continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
SELECT location, date,  population, total_cases, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--looking at Countries with Highest Infection Rate compared to Population

SELECT location,  population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
order by  PercentPopulationInfected DESC


--showing countries with highest death count per population

SELECT location,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
order by  TotalDeathCount DESC

--lets break things down by continent

SELECT continent,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by  TotalDeathCount DESC


--showing continents with the highest death count per population

SELECT continent,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by  TotalDeathCount DESC


--global numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as
	DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP By date
order by 1,2


--looking at total population vs vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
order by  2, 3

--using cte

WITH PopvsVac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)

AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--order by  2, 3)
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac 

--temp table

DROP Table if exists #PercentPopulationVaccinated
 CREATE Table #PercentPopulationVaccinated
 (
 continent nvarchar(225),
 location nvarchar(225),
 date datetime,
 Population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--order by  2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

---creating view to store data for later visulizations

CREATE view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--order by  2, 3

SELECT *
FROM PercentPopulationVaccinated