SELECT *
From PortfolioProjectCovid..CovidDeaths
Where continent is not NULL
ORDER by 3,4
---------------------------------------------------------------------------------------------------------

-- SELECT * 
-- From PortfolioProjectCovid..CovidVaxx
-- ORDER by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid..CovidDeaths
ORDER by 1,2

SELECT Location, population
From PortfolioProjectCovid..CovidDeaths
--Where location like '%cyprus%'
GROUP by location, population
ORDER by 1,2


SELECT 
    Location,
    MAX(cast(total_cases as bigint)) as maxtest
From PortfolioProjectCovid..CovidDeaths
GROUP by location
ORDER by maxtest

---------------------------------------------------------------------------------------------------------
-- looking at the total cases vs the total deaths
-- Shows the likelihood od dying if you contract covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
Where location like '%states%'
ORDER by 1,2 
---------------------------------------------------------------------------------------------------------
-- Looking at the total cases vs the population 
-- Shows what percentage of the population got covid

SELECT Location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths
-- Where location like '%cyprus%'
ORDER by 1,2 
---------------------------------------------------------------------------------------------------------
-- What countries has the highest infection rate compared to population - by location - ALL

SELECT 
    Location,  
    Population, 
    MAX(total_cases) as HighestInfectionCount, 
    MAX((total_cases/population))*100 as PercentPopulationInfected

From PortfolioProjectCovid..CovidDeaths
-- Where location like '%states%'
GROUP by Location,  Population
ORDER by PercentPopulationInfected desc

---------------------------------------------------------------------------------------------------------
-- GPT4 edit from above - ALL 
-- Had to mess around with pulling the right data since the data type was off 
-- even with GPT4 I still had to go in with the basics to pull ti right information as it was very different
-- the TOP one is the one that displays the most accurate information (correct total_cases) - this was really tough to figure out but after research i found it 

SELECT 
    Location,  
    Population, 
    MAX(cast(total_cases as bigint)) as HighestInfectionCount, -- has to explicitly cas this as a bigint for te proper numbers to show up for the devision to add up.
    MAX(total_cases/Population)*100 as PercentPopulationInfected

From PortfolioProjectCovid..CovidDeaths
-- Where location like '%cyprus%'
GROUP by Location, Population
ORDER by PercentPopulationInfected desc;



SELECT -- this one might be displaying the max perday and not the overall max number of cases.
    Location,  
    Population, 
    MAX(total_cases) as HighestInfectionCount, 
    MAX(total_cases/Population)*100 as PercentPopulationInfected

From PortfolioProjectCovid..CovidDeaths
-- Where location like '%cyprus%'
GROUP by Location, Population
ORDER by PercentPopulationInfected desc;




---------------------------------------------------------------------------------------------------------
-- Showing Countries the highest death count per population - location

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
-- Where location like '%states%'
Where continent is not NULL
GROUP by Location
ORDER by TotalDeathCount desc

---------------------------------------------------------------------------------------------------------
--BREAKING IT DOWN BY CONTINENT
-- showing the continents with the highest death count - by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
-- Where location like '%states%'
Where continent is not NULL
GROUP by continent
ORDER by TotalDeathCount desc

---------------------------------------------------------------------------------------------------------
-- Global Numbers - failed following guide


SELECT date, 
SUM(new_cases), 
SUM(new_deaths), 
cast(SUM(cast(new_deaths as DECIMAL(38,2)))/SUM(cast(new_cases as DECIMAL(38,2))) as DECIMAL(38,2))*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
-- Where location like '%states%'
Where continent is not NULL
GROUP By date
ORDER by date

---------------------------------------------------------------------------------------------------------
-- Global Numbers
--- GPT 4 test 3 and this works

SELECT date, 
       SUM(CAST(new_cases AS DECIMAL(38, 2))) as TotalCases, 
       SUM(CAST(new_deaths AS DECIMAL(38, 2))) as TotalDeaths, 
       CASE WHEN SUM(CAST(new_cases AS DECIMAL(38, 2))) > 0 
            THEN CAST(SUM(CAST(new_deaths AS DECIMAL(38, 2))) / SUM(CAST(new_cases AS DECIMAL(38, 2))) * 100 AS DECIMAL(38, 2)) 
            ELSE 0 
       END AS DeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------
-- Modified Global Deaths 

SELECT date, 
       SUM(new_cases) as TotalCases, 
       SUM(new_deaths) as TotalDeaths, 
       CASE WHEN SUM(CAST(new_cases AS DECIMAL(38, 2))) > 0 
            THEN CAST(SUM(CAST(new_deaths AS DECIMAL(38, 2))) / SUM(CAST(new_cases AS DECIMAL(38, 2))) * 100 AS DECIMAL(38, 2)) 
            ELSE 0 
       END AS DeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------
-- Looking at total population vs vaxx

SELECT 
dea.continent, 
dea.location, dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProjectCovid..CovidDeaths dea
JOIN PortfolioProjectCovid..CovidVaxx vac
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

---------------------------------------------------------------------------------------------------------
--using CTE 
-- Looking at total population vs vaxx

with PopvsVac (continent,location,date,population, new_vaccinations, RollingPeopleVaccinated) AS

(
Select
dea.continent, 
dea.location, 
dea.date, 
dea.population,
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProjectCovid..CovidDeaths dea
JOIN PortfolioProjectCovid..CovidVaxx vac
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
)
SELECT *, cast((RollingPeopleVaccinated/population)*100 AS DECIMAL (10,2))
FROM PopvsVac
ORDER BY location, date;
---------------------------------------------------------------------------------------------------------

------ GPT4 help with syntax for vaccinated by continent
--- CTE

WITH PopvsVac (continent, location, population, new_vaccinations, RollingPeopleVaccinated) AS
(
    SELECT
        dea.continent, 
        dea.location, 
        dea.population,
        vac.new_vaccinations,
        MAX(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date rows unbounded preceding) as RollingPeopleVaccinated
    FROM 
        PortfolioProjectCovid..CovidDeaths dea
        JOIN PortfolioProjectCovid..CovidVaxx vac
            ON dea.[location] = vac.[location]
            and dea.[date] = vac.[date]
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    continent, 
    MAX(cast(RollingPeopleVaccinated/population*100 as DECIMAL(10,2))) as MaxRollingPeopleVaccinated
FROM 
    PopvsVac
GROUP BY 
    continent
ORDER BY 
    continent;

------------------------------------------------------------------------------------------------------------------------
--- TempTable with error on selsect
Drop table if exists #PercentPopulationVaxx
CREATE TABLE #PercentPopulationVaxx
(

continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population  NUMERIC,
new_vaccinations numeric,
RollingPeopleVaccinated NUMERIC
)

INSERT into #PercentPopulationVaxx
SELECT
        dea.continent, 
        dea.location, 
        dea.population,
        vac.new_vaccinations,
        MAX(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date rows unbounded preceding) as RollingPeopleVaccinated
    FROM 
        PortfolioProjectCovid..CovidDeaths dea
        JOIN PortfolioProjectCovid..CovidVaxx vac
            ON dea.[location] = vac.[location]
            and dea.[date] = vac.[date]
    WHERE 
        dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 as percentPop
FROM #PercentPopulationVaxx

------------------------------------------------------------------------------------------------------------------------
--------GPT4 help to correct the issue from above 

Drop table if exists #PercentPopulationVaxx
CREATE TABLE #PercentPopulationVaxx
(
    continent NVARCHAR(255),
    LOCATION NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT into #PercentPopulationVaxx
SELECT
    dea.continent, 
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    MAX(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date rows unbounded preceding) as RollingPeopleVaccinated
FROM 
    PortfolioProjectCovid..CovidDeaths dea
    JOIN PortfolioProjectCovid..CovidVaxx vac
        ON dea.[location] = vac.[location]
        and dea.[date] = vac.[date]
WHERE 
    dea.continent IS NOT NULL

SELECT 
    *,
    cast(RollingPeopleVaccinated/population*100 as DECIMAL(10,2)) as MaxRollingPeopleVaccinated -- needs to be explicit wit hthe result of the devision CAST to be numeric
FROM 
    #PercentPopulationVaxx;


