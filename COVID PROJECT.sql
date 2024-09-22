
Select * 
from PortfolioProject..CovidDeaths$
where continent is not null 
order by 3,4


--Select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

select Location,date ,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

-- looking at total cases vs total daeths
-- likelihood of dying if you contract covid in your country
select location ,date,total_cases,total_deaths , (total_deaths/total_cases)*100 as Deathpercantage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

select location,date,population,total_cases,(total_cases/population)*100 as  percentageofpopulationEffected
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,MAX(total_cases)as highsetinfectioncount,MAX((total_cases/population))*100 as percentageofpopulationEffected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by location,population
order by percentageofpopulationEffected desc


--	BY CONTINENT
select location,MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
where continent is  null 
group by location
order by totaldeathcount desc



--showing counties with the higest death count per population
select location,MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null 
group by location
order by totaldeathcount desc


-- global numbers 
 
 Select  SUM(new_cases) as totalcases,SUM(cast( new_deaths as int) ) as totaldeath, SUM(cast( new_deaths as int) )/SUM(new_cases)*100 as deathpercentage
 from PortfolioProject.. CovidDeaths$
 where continent is not null
 --group by date
 order by 1,2


 -- looking at totalk population vs vaccination 

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(cast(new_vaccinations as int )) over (partition by dea.location , dea.date ) as rollpeoplevacc
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

 
 -- using CTE

 with popsnvac(continent,location ,date,population ,new_vaccinations,rollpeoplevacc)
 as(
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location,dea.date ) as rollpeoplevacc
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
select * , (rollpeoplevacc/population)*100
from popsnvac



--temp table

drop table if exists #percentpopvac
create table #percentpopvac
(continent nvarchar(255),
location nvarchar(255),
date datetime,
popluation numeric,
new_vaccination numeric,
rollpeoplevacc numeric)


 insert into #percentpopvac
   select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location,dea.date ) as rollpeoplevacc
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * ,(rollpeoplevacc/popluation)*100
from #percentpopvac


-- createing veiw to  store data for later visualizations


create view percentpop as
   select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location,dea.date ) as rollpeoplevacc
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from percentpop





