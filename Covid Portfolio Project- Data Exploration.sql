Select *
from CovidDeaths
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
order by 1,2

-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at the total cases vs population
--shows what percentage of pop contracted covid 
select location, date, total_cases, population,(total_cases/population)*100 as InfectionPercentage 
from CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to pop 
select location, population,MAX(total_cases) as TotalInfectionCases,
MAX((total_cases/population))*100 as InfectionPercentage 
from CovidDeaths
Group By location, population
order by InfectionPercentage desc

--showing countries with the highest death count per pop
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null 
Group By location
order by TotalDeathCount desc

--showing continent with highest death count 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null 
Group By location
order by TotalDeathCount desc

--Global Numbers

select date, SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDeaths,
SUM(Cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentageGlobal
from CovidDeaths
where continent is not null 
Group By date
order by 1,2

select SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDeaths,
SUM(Cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentageGlobal
from CovidDeaths
where continent is not null 
order by 1,2


--Looking at total pop vs vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Use a cte 

with PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--use temp table 
drop table if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date Datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)
insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopVaccinated


--creating view to store data for later visualizations 

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3 

select *
from PercentPopulationVaccinated
