select* from [indian census]..Data1$
select* from [indian census]..Data2

--number of rows and columns

select count(*) from [indian census]..Data1$
select count(*) from [indian census]..Data2

--dataset for Jharkhand and Bihar
select* from [indian census]..Data1$ 
where State in ('Jharkhand','Bihar','uttat praesh')


--population of india 
select sum(population) as Population from [indian census]..Data2

--average growth 
select avg(growth)*100 from [indian census]..Data1$

--average growth percentage of states
select state, avg(growth)*100 from [indian census]..Data1$ group by state

--average sex ratio
select state, round(avg(Sex_Ratio),0) as avg_sex_ratio from [indian census]..Data1$ 
group by state order by avg_sex_ratio desc

 --average literacy ratio
 select state, round(avg(Literacy),0) as avg_literacy_ratio from [indian census]..Data1$ 
 group by state having  round(avg(Literacy),0)>90 order by avg_literacy_ratio desc

 --top 3 states showing highest growth ratio
 select top 3 state, avg(growth)*100 from [indian census]..Data1$ group by state order by State desc

 -- bottom 3  states showing lowest sex ratio
 select top 3 state, round(avg(Sex_Ratio),0) as avg_sex_ratio from [indian census]..Data1$ 
group by state order by avg_sex_ratio asc;

--top and bottom state in literacy state
 
create table #topmoststates
  (state nvarchar(225),
  topmoststates float)

insert into #topmoststates
select state, round(avg(Literacy),0) as avg_literacy_ratio from [indian census]..Data1$ 
group by state order by avg_literacy_ratio desc

select top 3 * from #topmoststates order by #topmoststates.topmoststates desc


create table #bottomstates
  (state nvarchar(225),
  bottomstates float)

insert into #bottomstates
select state, round(avg(Literacy),0) as avg_literacy_ratio from [indian census]..Data1$ 
group by state order by avg_literacy_ratio desc

select top 3 * from #bottomstates order by #bottomstates.bottomstates asc


--join the two results in table using union operator
select* from(
select top 3 * from #topmoststates order by #topmoststates.topmoststates desc) a
union
select* from(
select top 3 * from #bottomstates order by #bottomstates.bottomstates asc) b


--states starting with 'a'
select  distinct state from [indian census]..Data1$ where lower(State) like 'a%'
select distinct state from [indian census]..Data1$ where lower(state) like 'a%' and lower(state) like '%m'


--joining the both the table to determine males and females
select* from [indian census]..Data1$ as a
select* from [indian census]..Data2 as b

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state,floor(c.population/(c.sex_ratio+1)) males,floor((c.population*c.sex_ratio)/(c.sex_ratio+1)) females from
 (select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from [indian census]..Data1$ as a 
 inner join [indian census]..Data2 as b 
 on 
 a.District=b.District) c)d
 group by state

 --finding the literacy rate
 select state,d.literate_people,d.illiterate_people from 
 (select c.district,c.state,round(c.literacy_ratio*c.population,0) literate_people, round((1-c.literacy_ratio)*c.population,0) illiterate_people from
 (select a.district, a.State,a.literacy/100 literacy_ratio,b.population from [indian census]..Data1$ as a inner join [indian census]..Data2 as b
 on a.District=b.district) c) d order by d.literate_people,d.illiterate_people asc

 --population in previous census
 select (f.previous_census_country_pop/f.current_census_country_pop) overall_percentage_increase from 
 (select sum(e.previous_census_total_pop) previous_census_country_pop,sum(e.current_census_total_pop) current_census_country_pop from
  (select d.state, sum(d.previous_census_population) previous_census_total_pop,sum(current_census_population) current_census_total_pop from
 (select c.district,c.state,floor(c.Population/(1+c.growth)) previous_census_population, c.population current_census_population from
 (select a.district, a.State,a.growth, b.population from [indian census]..Data1$ as a inner join [indian census]..Data2 as b
 on a.District=b.District) c) d group by State) e)f

 --calculate population density
 select a.District,a.state,(a.population/a.area)/100 population_density from
 (select district,state,Area_km2 area,Population from [indian census]..Data2) a order by state desc
  

--population vs area
select z.total_area/z.previous_census_country_pop as previous_census_pop_vs_area, z.total_area/z.current_census_country_pop as current_census_pop_vs_area from
(select q.*,r.total_area from(
select '1' as keyy, n.* from(
select sum(e.previous_census_total_pop) previous_census_country_pop,sum(e.current_census_total_pop) current_census_country_pop from
  (select d.state, sum(d.previous_census_population) previous_census_total_pop,sum(current_census_population) current_census_total_pop from
 (select c.district,c.state,floor(c.Population/(1+c.growth)) previous_census_population, c.population current_census_population from
 (select a.district, a.State,a.growth, b.population from [indian census]..Data1$ as a inner join [indian census]..Data2 as b
 on a.District=b.District) c) d group by State) e) n) q inner join (


 select '1' as keyy,p.* from
(select sum(area_km2) total_area from [indian census]..Data2)p) r on 
q.keyy=r.keyy) z