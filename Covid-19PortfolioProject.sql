-- Looking at the Tables
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- India's Covid-19 death rate on different dates
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%' and continent is not null
ORDER BY 1,2

-- India's Covid-19 cases percentage on different dates
SELECT location, date,population,total_cases, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%' and continent is not null
ORDER BY 1,2

-- Highest Infection rate of each country 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
where continent is not null
Group by location, population
ORDER BY 4 DESC

-- Total deaths in each Continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE continent is not null
Group by continent
ORDER BY 2 DESC

-- Total deaths where Continent is null
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE continent is null
Group by location
ORDER BY 2 DESC

-- Global numbers
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Sum of deaths each day worldwide
Select date, sum(new_cases) as TotalnewCases, sum(cast(new_deaths as int)) as Totalnewdeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as NewDeathpercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as TotalnewCases, sum(cast(new_deaths as int)) as Totalnewdeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as NewDeathpercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- lets see covid vaccination table

select *
from PortfolioProject..CovidVaccinations

select location, date, total_vaccinations, new_vaccinations
from PortfolioProject..CovidVaccinations
where location like '%india%'

-- joining the 2 tables
select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- looking at total Population vs Vaccinations
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, (vac.new_vaccinations/dea.population)*100 as VaccinationPercentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%india%'

select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Rolling people vaccinated 
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- To use RollingPeopleVaccinated in arithmetic operations as it is just created [CTE]
with PopvsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- create View to store data for later visualizations

create view PercentPopulation_Vaccinated as
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulation_Vaccinated