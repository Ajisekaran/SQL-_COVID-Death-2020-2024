select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,total_deaths),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- looking at Total Cases vs Population 
-- shows the what percentage of population got covid

Select Location, date, Population, total_cases,(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population
Select Location, Population,MAX( total_cases) as HighestInfectionCount,(MAX(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location,population
order by PercentPopulationInfected desc

-- showing Countries with Highest Death Count Per Population

Select Location,MAX(cast( total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT



-- showing continents with the highest death count per population

Select continent,MAX(cast( total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM( new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs vaccinations

Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, COUNT(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
  dea.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, COUNT(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
  dea.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, COUNT(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
  dea.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, COUNT(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
  dea.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
From PercentPopulationVaccinated 
