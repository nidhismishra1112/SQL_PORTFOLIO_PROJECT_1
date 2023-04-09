select * from CovidDeaths
where continent is not null
order by 3,4

--select * from Covidvaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
where continent is not null
order by 1,2



----Lets look at the data of  the total cases vs total death
----shows likelihood of dying if you contract covid in your country

select location, date, total_cases, new_cases, (total_deaths/total_cases)* 100 as PercentageDeath
from CovidDeaths
where location like '%india%' and  continent is not null
order by 1,2


-----total cases vs population 
------shows what percentage of population got covid
select location, date,  population , total_cases ,(total_cases/population )* 100 as Percentageinfected
from CovidDeaths
where location like '%india%' and  continent is not null
order by 1,2


---countries with highest infection rate compared to population 


select location,  population , max(total_cases) as HighestInfectionCount,max((total_cases/population) )* 100as PercentPopulationInfected
from CovidDeaths
where  continent is not null
group by location, population
order by PercentPopulationInfected desc


---countries with highest death count per population


select location,  max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where  continent is not null
group by location
order by  HighestDeathCount desc

-----break this count by continent


select continent,  max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where  continent is not null
group by continent
order by  HighestDeathCount desc



---global numbers

select date, sum(new_cases) as totalnewCases,
sum(cast(new_deaths as int)) as TotalNewDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

select  sum(new_cases) as totalnewCases,
sum(cast(new_deaths as int)) as TotalNewDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2



-----------------------------------------------------------------------------------
--- looking at total population vs total vaccination 

select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) 
over(partition by d.location
order by d.location,d.date) as RollingPeopleVaccinated
from CovidDeaths d
join covidvaccination v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3

------------CTE

with PopvsVac (continet,location,date,population,new_vaccination, RollingPeopleVaccinated)
as (
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) 
over(partition by d.location
order by d.location,d.date) as RollingPeopleVaccinated
from CovidDeaths d
join covidvaccination v
on d.location=v.location
and d.date=v.date
where d.continent is not null
---order by 2,3 
)
 select *,(RollingPeopleVaccinated/population)*100 as percentage
 from PopvsVac



 ---------------temp table


 drop table if exists  #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric, RollingPeopleVaccinated numeric)


insert into #PercentPopulationVaccinated

 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) 
over(partition by d.location
order by d.location,d.date) as RollingPeopleVaccinated
from CovidDeaths d
join covidvaccination v
on d.location=v.location
and d.date=v.date
--where d.continent is not null
---order by 2,3 

select *,(RollingPeopleVaccinated/population)*100 as percentage
 from #PercentPopulationVaccinated


 -------creating view for later data visualization

 create view PercentPopulationVaccinated as
 
 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) 
over(partition by d.location
order by d.location,d.date) as RollingPeopleVaccinated
from CovidDeaths d
join covidvaccination v
on d.location=v.location
and d.date=v.date
--where d.continent is not null
---order by 2,3 

select * from PercentPopulationVaccinated
