--Exploring Data Table which contains Covid Vaccinations Data
Select * 
From PortfolioProject..VaccinationsData
ORDER BY 3,4

--Exploring Data Table which contains Covid Deaths Data
Select * 
From dbo.CovidDeaths 
Order by 3,4 


Select Location, date, total_cases, new_cases, total_deaths, population
From 
PortfolioProject..CovidData
ORDER BY 1,2

--Exploring Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From 
PortfolioProject..CovidData 
where Location like '%Canada%'
ORDER BY 1,2 


--Exploring Total cases vs Population
Select Location,date, total_cases, Population, (total_cases/population)*100 as CovidPositivePercentage
From PortfolioProject..CovidData
where continent is not null
Order by 1,2

--Exploring Countries with highest infection rate compared to population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidData
where continent is not null
Group by Location, Population
Order by PercentPopulationInfected desc

--Exploring Countries with highest death count (per country)
Select Location,  Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidData
where continent is not null
Group by Location
Order by TotalDeathCount desc 

--Now Lets explore numbers for Continents

--Showing continent with highest Death Count

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidData
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers
Select  date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/ Sum(new_cases)*100 as DeathPercentage
From 
PortfolioProject..CovidData
where continent is not null
Group by date
ORDER BY 1,2 

--World Covid Numbers: Total Cases, Total Deaths and Death Percentage 
Select  Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/ Sum(new_cases)*100 as DeathPercentage
From 
PortfolioProject..CovidData 
where continent is not null
ORDER BY 1,2 

--Exploring Total Population vs Vaccinations 
Select cde.continent, cde.location, cde.date, cde.population, cva.new_vaccinations, SUM(convert(int, cva.new_vaccinations)) OVER (Partition by cde.location Order by cde.Location, cde.date) as  TotalVaccinationCount
From PortfolioProject..CovidData cde
Join PortfolioProject..VaccinationsData cva
	On cde.location= cva.location
	and cde.date = cva.date
where cde.continent is not null
order by 2,3


--USE CTE

With PopvsVac (continent, location, Date, Population,new_vaccinations, TotalVaccinationCount)
as 
(Select cde.continent, cde.location, cde.date, cde.population, cva.new_vaccinations, SUM(convert(int, cva.new_vaccinations)) OVER (Partition by cde.location Order by cde.Location, cde.date) as  TotalVaccinationCount
From PortfolioProject..CovidData cde
Join PortfolioProject..VaccinationsData cva
	On cde.location= cva.location
	and cde.date = cva.date
where cde.continent is not null
)
Select *, (TotalVaccinationCount/Population)*100
From PopvsVac

--TEMP Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations bigint,
TotalVaccinationCount bigint
)
Insert into #PercentPopulationVaccinated
Select cde.continent, cde.location, cde.date, cde.population, cva.new_vaccinations, SUM(convert(int, cva.new_vaccinations)) OVER (Partition by cde.location Order by cde.Location, cde.date) as  TotalVaccinationCount
From PortfolioProject..CovidData cde
Join PortfolioProject..VaccinationsData cva
	On cde.location= cva.location
	and cde.date = cva.date
--where cde.continent is not null

Select *, (TotalVaccinationCount/Population)*100
From #PercentPopulationVaccinated

--Creating view  to store
DROP VIEW if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
Select cde.continent, cde.location, cde.date, cde.population, cva.new_vaccinations, SUM(convert(int, cva.new_vaccinations)) OVER (Partition by cde.location Order by cde.Location, cde.date) as  TotalVaccinationCount
From PortfolioProject..CovidData cde
Join PortfolioProject..VaccinationsData cva
	On cde.location= cva.location
	and cde.date = cva.date
--where cde.continent is not null

Select * 
From PercentPopulationVaccinated
