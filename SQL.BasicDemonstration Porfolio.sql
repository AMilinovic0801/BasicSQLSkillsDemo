-- Creating a new table

if object_id ('Football_Data_2020') is not null drop table Football_Data_2020

create table Football_Data_2020
(
[Date] nvarchar(200),
Home_Team nvarchar(200),
Away_Team nvarchar(200),
Home_Score int,
Away_Score int,
Tournament nvarchar(200),
City nvarchar(200),
Country nvarchar(200),
Neutral nvarchar(200)
)

select *
from Football_Data_2020

-- Importing the data in bulk

bulk insert Football_Data_2020
from 'C:\Users\Antonio\Desktop\SQL Tutorial for Data Scientist 2022\results 2021.csv'
with (format = 'csv')

-- Filtering with select

select [Date], Home_Team, Away_Team, Home_Score, Away_Score
from Football_Data_2020


-- Conditioning the data within tables

select *
from Football_Data_2020
where Home_Team = 'Croatia'

select *
from Football_Data_2020
where Tournament <> 'Friendly'

select distinct Tournament
from Football_Data_2020

select *
from Football_Data_2020
where Country in ('Croatia', 'England', 'Serbia')
order by 1

select *
from Football_Data_2020
where Country not in ('Croatia', 'England', 'Serbia')
order by 1

select *
from Football_Data_2020
where Tournament like '%UEFA%'
order by 1

select Date, Tournament
from Football_Data_2020
where Tournament like 'FIFA%'
group by Date, Tournament
order by 1

select *
from Football_Data_2020
where Tournament not like '%UEFA%'
order by 1

select *
from Football_Data_2020
where Home_Score > 10
order by 4 desc

select *
from Football_Data_2020
where Home_Score < 10
order by 4 desc

select *
from Football_Data_2020
where Home_Score between 2 and 5
order by 4 desc

select *
from Football_Data_2020
where Home_Score < 10 and Tournament <> 'Friendly'
order by 4 desc

select *
from Football_Data_2020
where Tournament <> 'Friendly' or Away_Score > 10 and Home_Score < 10
order by 4 desc

-- Using Sub-Queries

-- Writes results for European counries only
select *
from Football_Data_2020
where Country in (select distinct Country From CountriesData where Region like '%Europe%')

-- Writes results for countries that have 5000000 population and more
select *
from Football_Data_2020
where Country in 
(select distinct Country 
from CountriesData where [Population] > 5000000)
order by 1

-- Selects the last date of our database and writes the results on that day
select *
from Football_Data_2020
where [Date] = (select max(Date) from Football_Data_2020)

-- Writes all countries (from table Football_Data_2020) that ever participated in UEFA games
select Country
from Football_Data_2020
where Country in
( select distinct Country 
from Football_Data_2020
where Tournament like '%UEFA%')
group by Country

-- Using IF and CASE statements

-- Using IF statement to change information (-UK) in Football_Data_2020 table

select [Date], Home_Team, Away_Team, Home_Score, Away_Score, iif(Country in ('England', 'Scotland', 'Wales', 'Northern Ireland'), Country + ' - UK', Country) as Country
from Football_Data_2020

-- Using CASE statement to ichange information (-UK) in Football_Data_2020 table

select [Date], Home_Team, Away_Team, Home_Score, Away_Score,
case
  when Country in ('England', 'Scotland', 'Wales', 'Northern Ireland') then  Country + ' - UK'
  else Country
end as Country
from Football_Data_2020

-- Using Update, Delete, Insert into and New Column 

-- Renaming England to England - UK

update Football_Data_2020
set Country = iif(Country = 'England', 'England - UK', Country)

select *
from Football_Data_2020
where Country like 'England%'

-- Replacing informatin in the table

update Football_Data_2020
set Country = replace(Country, 'Scotland', 'Scotland - UK')

select *
from Football_Data_2020
where Country like 'Scotland%'

-- Inserting new information in the table

insert into Football_Data_2020 values
('25/11/2022', 'Croatia', 'England - UK', 5, 4, 'FIFA World Cup', 'Doha', 'Quatar', 'TEST')

select *
from Football_Data_2020
where [Date] = '25/11/2022'

-- Deleteting information in the table

delete from Football_Data_2020
where Neutral = 'TEST'

select *
from Football_Data_2020
where Neutral = 'TEST'

-- Deleting a whole column

alter table Football_Data_2020
drop column Neutral

select *
from Football_Data_2020

-- Creating a new column

-- Only for this querie
select *, cast(Home_Score as varchar) + '-' + cast(Away_Score as varchar) as Score
from Football_Data_2020

-- Permament column update

alter table Football_Data_2020
add Score varchar(10)

update Football_Data_2020
set Score = cast(Home_Score as varchar(50)) + '-' + cast(Away_Score as varchar(50))

select *
from Football_Data_2020



-- Using Aggregated functions

-- Using TEMP TABLE to sum information about goals for Croatia

drop table if exists #Temp_GoalsSummary

create table #Temp_GoalsSummary
(Home_Team varchar(200),
Tournament varchar (200),
TotalHomeGoals int,
TotalAwayGoals int,
TotalGoals float,
TotalHomeGames int,
NumberOfGames int)

insert into #Temp_GoalsSummary
select Home_Team, Tournament, sum(Home_Score) as TotalHomeGoals, sum(Away_Score) as TotalAwayGoals
, (sum(Home_Score)+sum(Away_Score)) as TotalGoals, count(Home_Team) as NumberOfGames, count(Home_Team) as TotalHomeGames
from Football_Data_2020
where Home_Team = 'Croatia'
group by Home_Team, Tournament

select *
from #Temp_GoalsSummary

-- Using Temp Table to calculate the number of goals per game per tournament for Croatia

select *, (TotalGoals/NumberOfGames) as GoalsPerGame
from #Temp_GoalsSummary

-- Using CTE to display Average Score for Croatia

with CTE_GoalsPerGame as
(select *, (TotalGoals/NumberOfGames) as GoalsPerGame
from #Temp_GoalsSummary)

select Home_Team, round(avg(GoalsPerGame), 2) as AvgScore
from CTE_GoalsPerGame
group by Home_Team

-- Another way to view Average score for Croatia

select Home_Team,(select (round(avg(TotalGoals/NumberOfGames), 2)) as GoalsPerGame from #Temp_GoalsSummary)
from #Temp_GoalsSummary
group by Home_Team

-- Average Home games per Home Team

select Home_Team, count(Score) as NumberOfGames, round(avg(cast(Home_Score as float)), 2) as AvgHomeScore
from Football_Data_2020
group by Home_Team
order by 3 desc


-- Maximum Home goals by Home Team

select Home_Team, max(Home_Score) as MaxHomeGoals
from Football_Data_2020
Group by Home_Team
order by 2 desc

-- Populating new table

if object_id('CountriesData') is not null drop table CountriesData

create table CountriesData
( Country nvarchar(200),
Region nvarchar (200),
[Population] int,
AreaSqMi float,
PopDensityPerSqMi float,
CoastlineCoastAreaRatio float,
NetMigration float,
InfantMortalityRatePer1000Berths float,
GDPPerCapita float,
LiteracyPerc float,
Phonesper1000 float,
ArablePerc float,
CropsPerc float,
OtherPerc float,
Climate float,
Birthrate float,
Deathrate float,
Agriculture float,
Industry float,
[Service] float)

bulk insert CountriesData
from 'C:\Users\Antonio\Desktop\SQL Tutorial for Data Scientist 2022\countries of the world.csv'
with (format = 'csv')

select *
from CountriesData

--Display Country with minimum GDP per capita

select top 10 Country, min(GDPPerCapita) as MinGDPperCapita
from CountriesData
where GDPPerCapita is not null
Group by Country
order by 2

-- Using Joins

-- Displaying the total home goals and GDPperCapita for all Countries using the Join function

select Home_Team, Region, sum(Home_Score) as SumHomeScore, GDPPerCapita
from Football_Data_2020
join CountriesData
   on Football_Data_2020.Home_Team = CountriesData.Country
group by Home_Team, Region, GDPPerCapita
order by 1

-- Displaying Total Home score per region

select coun.Region, sum(foot.Home_Score) as TotalHomeGoalsPerRegion
from Football_Data_2020 as foot
join CountriesData as coun
   on foot.Home_Team = coun.Country
group by coun.Region
order by 2 desc

-- Displaying Cross join

select *
from Football_Data_2020 as foot
cross join CountriesData as coun

-- Using views to store the data for visualization

-- View for Home Goals Per Region

create view HomeScorePerRegion as

select coun.Region, sum(foot.Home_Score) as TotalHomeGoalsPerRegion
from Football_Data_2020 as foot
join CountriesData as coun
   on foot.Home_Team = coun.Country
group by coun.Region


select *
from HomeScorePerRegion

-- View for top 10 Countries with lowest GDP

create view LowestGDP as

select top 10 Country, min(GDPPerCapita) as MinGDPperCapita
from CountriesData
where GDPPerCapita is not null
Group by Country
order by 2

select *
from LowestGDP