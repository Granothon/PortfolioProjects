Select *
From PortfolioProject..covidVaccinations
Order by 3, 4

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..covidDeaths
Where location like '%inlan%'
Order by 1, 2

-- Looking at Total Cases vs Population
--- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 As InfectionRate
From PortfolioProject..covidDeaths
Order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 As InfectionRate
From PortfolioProject..covidDeaths
Group by location, population
Order by InfectionRate desc

-- Looking at Countries with Highest Death Count compared to Population
Select location, population, MAX(total_deaths) as total_deaths, Max((total_deaths/population))*100 as DeathPopulationPercentage
From PortfolioProject..covidDeaths
Group by location, population
Order by DeathPopulationPercentage desc

-- Looking at Continents with Highest Death Count
Create View ContinentDeathCount as
Select location, MAX(total_deaths) as TotalDeathCount 
From PortfolioProject..covidDeaths
Where continent is null 
and location in ('Europe', 'South America', 'North America', 'Asia', 'Africa', 'Oceania')
Group by location, population
--Order by TotalDeathCount desc


-- GLOBAL NUMBERS

-- total
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as
DeathPercentage
From PortfolioProject..covidDeaths
where continent is not null
Order by 1, 2

-- by Date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as
DeathPercentage
From PortfolioProject..covidDeaths
where continent is not null
Group by date
Order by 1, 2


-- Looking at Total Population vs Vaccinations

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as Bigint)) Over (Partition By dea.location Order By dea.location, dea.date)
  as RollingPeopleVaccinated

FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (CAST(RollingPeopleVaccinated as FLOAT)/Population)*100 as RollingVaccinationPercent
From PopvsVac

ORDER by 2, 3

-- USE TEMP TABLE
DROP Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as Bigint)) Over (Partition By dea.location Order By dea.location, dea.date)
  as RollingPeopleVaccinated

FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationPercent
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as Bigint)) Over (Partition By dea.location Order By dea.location, dea.date)
  as RollingPeopleVaccinated

FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

Select *
From PercentPopulationVaccinated