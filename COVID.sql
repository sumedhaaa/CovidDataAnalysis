select * from project.dbo.CovidDeaths

select * from project.dbo.CovidVaccinations

--select data that we will be using
select location, date, total_cases, new_cases, total_deaths, population from project.dbo.CovidDeaths

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
select Location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercent from project.dbo.CovidDeaths
--where Location='India'

--looking at total cases vs population
select Location, date, total_cases, population, (total_cases/population)*100 as CasesPercent from project.dbo.CovidDeaths
--where Location='India'

--looking at countries who have high infection rate compared with population
select Location, max(total_cases) as MaximumCases, population, max((total_cases/population)*100) as CasesPercent 
from project..CovidDeaths 
group by Location, population

--looking at countries with highest death count per population
select Location, max(cast(total_deaths as int)) as MaximumDeaths
from project.dbo.CovidDeaths
where continent is not null
group by Location
order by MaximumDeaths desc

--Breaking things down by continent
select  continent, max(cast(total_deaths as int)) as MaximumDeaths
from project.dbo.CovidDeaths
where continent is not null
group by continent
order by MaximumDeaths desc

--Global numbers
select sum(new_cases) as cases, sum(cast(new_deaths as int)) as deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from project.dbo.CovidDeaths
where continent is not null
--group by date
order by cases

--looking for total population vs vaccination
select dea.continent,dea.date,dea.location,dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingPeopleVaccinated
from project.dbo.CovidVaccinations vac
Join
project.dbo.CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date 
where dea.continent is not null

--USE CTE
with popvsvac (Continent, Location, Date, Population,new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent,dea.date,dea.location,dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingPeopleVaccinated
from project.dbo.CovidVaccinations vac
Join
project.dbo.CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date 
where dea.continent is not null
)

select *, (rollingPeopleVaccinated/Population)*100 from popvsvac

--creating  a view for future use
create view percentagepopulationvaccinated as
select dea.continent,dea.date,dea.location,dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingPeopleVaccinated
from project.dbo.CovidVaccinations vac
Join
project.dbo.CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date 
where dea.continent is not null
