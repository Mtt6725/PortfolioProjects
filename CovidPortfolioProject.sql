Select *
From PortfolioProject ..CovidDeaths
Where continent is not NULL
Order by 3,4


Select *
From PortfolioProject ..CovidVaccinations
Order by 3,4


--Select data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not NULL
Order by 1,2


-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Where continent is not NULL
Order by 1,2


-- Looking at Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as infection_rate
From PortfolioProject..CovidDeaths
Where location like '%states%'
AND continent is not NULL
Order by 1,2


-- Countries with highest Infection Rate vs Total Population

Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infection_rate
From PortfolioProject..CovidDeaths
Group by location, population
Order by infection_rate desc


-- Shows countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location
Order by total_death_count desc


-- Showing continets with the highest death count per population


Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Group by continent
Order by total_death_count desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
	as death_percentage 
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by date
Order by 1,2

-- GLOBAL DEATH RATE
Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
	as death_percentage 
From PortfolioProject..CovidDeaths
Where continent is not NULL
Order by 1,2



-- Total population vs vaccincation

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.date, dea.location)
	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
Order by 2,3


-- Using common table expression

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as vaccination_rate
From PopvsVac



-- TEMPORARY TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date numeric,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated


-- creating view to store for visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL


Select *
From PercentPopulationVaccinated
