Select * from [dbo].[CovidDeaths];

-- Queries
Select continent, location, date, total_cases, new_cases, total_deaths, population
From [dbo].[CovidDeaths]
Order By location, date;


-- COUNTRIES WISE EXPLORATION

-- Total Cases vs Total Deaths.
-- Percentage of Death by Total Cases.
Select location, date, total_cases, total_deaths, round((total_deaths/NULLIF(total_cases, 0))*100, 5) as DeathPercentage
From [dbo].[CovidDeaths]
--Where location = 'India'
Where continent<>location
Order By location, date;


-- Total Cases vs Population
-- Shows what percentage of population got Covid.
Select location, date, new_cases, total_cases, population, round((total_cases/NULLIF(population, 0))*100, 5) as PercentagePopulationInfected
From [dbo].[CovidDeaths]
--Where location = 'India'
Where location<>continent
Order By location, date;


-- Country having highest Infection Rates
Select location, max(total_cases) as TotalInfectionCount, population, max((total_cases/NULLIF(population, 0)))*100 as PercentagePopulationInfected
From [dbo].[CovidDeaths]
Where continent<>location
Group By location, population
Order By PercentagePopulationInfected Desc;


-- Countries having Highest Death Count by Population.
Select location, max(total_deaths) as TotalDeathCount, population, max((total_deaths/NULLIF(population, 0)))*100 as PercentageDeaths
From [dbo].[CovidDeaths]
Where continent<>location
Group By location, population
Order By TotalDeathCount DESC;


-- CONTINENTS WISE EXPLORATION

-- Continent wise Death Count and Death Percentage of Infected Persons.
Select continent, sum(new_deaths) as TotalDeathCount, sum(new_cases) as PopulationInfected, round((sum(new_deaths)/sum(new_cases))*100, 5) as DeathPercentage
From [dbo].[CovidDeaths]
Where continent<>location
Group By continent
Order By DeathPercentage DESC;


-- Date Wise Infection and Death Rate.
Select date, sum(new_cases) as NewCases, sum(new_deaths) as NewDeaths, round((sum(new_deaths)/NULLIF(sum(new_cases), 0))*100, 5) as DeathPercentage
From [dbo].[CovidDeaths]
--where location = 'India'
where continent<>location
Group By date
Order By date;


-- Global Numbers
Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, round((sum(new_deaths)/NULLIF(sum(new_cases), 0))*100, 5) as DeathPercentage
From [dbo].[CovidDeaths]
Where continent<>location;


-- Vaccinations Exploration
Select * from [dbo].[CovidVaccinations];


-- CTE
With PopVsVac as 
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
	From [dbo].[CovidDeaths] as dea
	Join [dbo].[CovidVaccinations] as vac
	On dea.date = vac.date and dea.location = vac.location
	Where dea.continent<>dea.location
	)

Select *, round((total_vaccinations/NULLIF(population, 0))*100, 5) as PercentageVaccinated from PopVsVac
Order By location, date;


-- TEMP TABLE
Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	total_vaccinations numeric
	)

Insert Into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
	From [dbo].[CovidDeaths] as dea
	Join [dbo].[CovidVaccinations] as vac
	On dea.date = vac.date and dea.location = vac.location
	Where dea.continent<>dea.location

Select *, round((total_vaccinations/NULLIF(population, 0))*100, 5) as PercentageVaccinated from #PercentPopulationVaccinated
Order By location, date;


-- CREATE VIEW

-- View Global Data of Infection and Deaths
Create or Alter View GlobalNumbers as
Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, round((sum(new_deaths)/NULLIF(sum(new_cases), 0))*100, 5) as DeathPercentage
From [dbo].[CovidDeaths]
Where continent<>location;


-- View of Total Vaccinated people by Location
Create or Alter View PercentPopulationVaccinated as
With PopVsVac as 
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
	From [dbo].[CovidDeaths] as dea
	Join [dbo].[CovidVaccinations] as vac
	On dea.date = vac.date and dea.location = vac.location
	Where dea.continent<>dea.location
	)
Select *, round((total_vaccinations/NULLIF(population, 0))*100, 5) as PercentageVaccinated from PopVsVac
