select *
from PortFolio_Project..CovidDeaths
order by 3,4

select *
from PortFolio_Project..CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortFolio_Project..CovidDeaths
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from PortFolio_Project..CovidDeaths
where location like '%desh%'
order by 1,2

select location,date,total_cases,total_deaths,population,(total_cases/population) as positive_percentage
from PortFolio_Project..CovidDeaths
where location like '%desh%'
order by 1,2

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population)*100)as max_percentage
from PortFolio_Project..CovidDeaths
group by population,location
order by max_percentage desc

select location,max(total_deaths) as HighestDeath,population,max((total_deaths/population)) as death_percentage
from PortFolio_Project..CovidDeaths
group by location,population
order by death_percentage desc

 select continent, max(cast(total_deaths as int)) as TotalDeathscount
 from PortFolio_Project.dbo.CovidDeaths
 where continent is not null
 group by continent
 order by TotalDeathscount desc

select date,sum(new_cases)as total_new_cases,sum(cast(new_deaths as float))as total_death,(sum(cast(new_deaths as float))/sum(new_cases))*100 AS death_percentage
from PortFolio_Project..CovidDeaths
where continent is not null
group by date
order by 1

select sum(new_cases)as total_new_cases,sum(cast(new_deaths as float))as total_death,(sum(cast(new_deaths as float))/sum(new_cases))*100 AS death_percentage
from PortFolio_Project..CovidDeaths
where continent is not null
group by date
order by 1

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortFolio_Project..CovidDeaths dea
join PortFolio_Project..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortFolio_Project..CovidDeaths dea
join PortFolio_Project..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE
with abcd(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortFolio_Project..CovidDeaths dea
join PortFolio_Project..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select * ,(RollingPeopleVaccinated/population)*100
from abcd


--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortFolio_Project..CovidDeaths dea
join PortFolio_Project..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
order by 1

-- creating view
create view PercentPopulationVaccinated as 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortFolio_Project..CovidDeaths dea
join PortFolio_Project..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
select *
from PercentPopulationVaccinated
order by 1