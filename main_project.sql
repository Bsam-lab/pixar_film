select * from academy;
select * from box_office;
select * from cleaned_pixar_people;
select * from genres;
select * from pixar_data_dictionary;
select * from pixar_film;
select * from public_response;

-- 1.	Financial Performance Analysis:
-- a	What are the top 5 highest-grossing Pixar films worldwide?
select * from box_office;
select film,box_office_worldwide from box_office order by 2 desc limit 5;

-- b	How have Pixar films performed financially over the years? What is the relationship between budget and box office earnings? Which films were the most profitable
select * from pixar_film;
select * from box_office;
-- i How have Pixar films performed financially over the years
select year(p.release_date) as year,count(year(p.release_date)) as number, case when budget > box_office_worldwide then 'loss' 
when budget < box_office_worldwide then 'profit' end as performance from pixar_film as p join box_office as b on p.film=b.film group by 1,3 order by 2 desc;

-- ii What is the relationship between budget and box office earnings
select * from box_office;
-- budget is the propose amount to be made why box office is the actual amount made.

-- iii Which films were the most profitable
-- confirmation
with profitable_films as(select film,box_office_worldwide,budget, box_office_worldwide - budget as roi 
from box_office where box_office_worldwide > budget order by 4 desc)
select film from profitable_films limit 1;

-- c	How does budget correlate with box office performance across different regions (US/Canada vs. International)?
select * from box_office;
-- budget is the value propose while box_office_us_canada is the  actual income generate from us and canada office and box_office_other is the amount generate in other country
-- while the box_office_worldwide is the sum of box_office in all country.

-- d	Which films achieved the highest return of investment (ROI), and how does this compare across different decades?
-- i Which films achieved the highest return of investment (ROI)
with decade as(select b.film,b.budget,b.box_office_worldwide,b.box_office_worldwide - b.budget as Roi,p.release_date,case when year(p.release_date) between 1995 and 2005 then '1st' 
when year(p.release_date) between 2006 and 2015 then '2nd' else '3rd' end as decades from box_office as b join pixar_film as p on b.film=p.film)
select b.film,b.budget, b.box_office_worldwide, b.box_office_worldwide - b.budget as Roi,d.release_date,d.decades from box_office as b join decade as d order by 4 desc
limit 1; 
-- ii and how does this compare across different decades?
with decade as(select b.film,b.budget,b.box_office_worldwide,b.box_office_worldwide - b.budget as Roi,p.release_date,case when year(p.release_date) between 1995 and 2005 then '1st' 
when year(p.release_date) between 2006 and 2015 then '2nd' else '3rd' end as decades from box_office as b join pixar_film as p on b.film=p.film),
sum_roi as(select decades , sum(Roi) as Total_ROI from decade group by 1),
lag_price as(select *, lag(total_roi,1,0) over (order by total_roi ) as Previous_Price from sum_roi)
select *, concat(round(coalesce(((total_roi - Previous_Price)/Previous_Price)*100,0),2),'','%') as Percentage from lag_price;

-- 2.	Audience and Critical Reception:
-- a	How do audience ratings (IMDB, Rotten Tomatoes, Metacritic) correlate with box office earnings?
select * from public_response;
select * from box_office;
select p.film,p.imdb_score + p.rotten_tomatoes_score + p.metacritic_score as total_rating,b.box_office_worldwide from public_response as p
join box_office as b on p.film=b.film order by 3 desc;

-- b	What is the distribution of Pixar films by CinemaScore rating, and how does it impact financial success?
select * from public_response;
-- i What is the distribution of Pixar films by CinemaScore rating
with cinema_rating as(select film,cinema_score, case when cinema_score='NA' then 'Not rated' when cinema_score='A-' then 'Less rated' when cinema_score='A' then 'Normal rating' when
cinema_score='A+' then 'Highly rated' end as Distribution from public_response)
select distribution,count(distribution) from cinema_rating group by 1;
-- ii and how does it impact financial success?
select p.film, p.cinema_score, b.box_office_worldwide, b.box_office_worldwide - b.budget as roi
from public_response as p join box_office as b on p.film=b.film order by 3 desc;
-- high cinema score lead to high_income

-- c	Have audience ratings improved or declined over the years?
select * from public_response;
select * from pixar_film;
with total as(select film,rotten_tomatoes_score + metacritic_score + imdb_score as total_audience_rating from public_response order by 2 desc)
select p.film, t.total_audience_rating, year(p.release_date) as year from pixar_film as p join total as t on p.film=t.film order by 2 desc; 
-- from the table it is Fluctuating 

-- 3.	Awards and Recognition:
-- a	Which Pixar films have won or been nominated for Academy Awards?

-- change status in toy story that have award type other
select * from academy;
set sql_safe_updates=0;
update academy set status= replace(status,'Won Special Achievement','Won') where film= 'Toy Story' and award_type='Other';
select film,award_type,status from academy where status= 'Nominated' or 'Won';
select film,count(film) as times_won_or_nominated from academy where status= 'Nominated' or 'Won' group by 1 order by 2 desc;

-- b	How does winning an Oscar impact a film's financial success?
select * from academy;
select * from box_office;
select a.film,count(a.film) as number_of_winning,b.box_office_worldwide from academy as a join
box_office as b on a.film=b.film where a.status= 'Won' group by 1,3 order by 2 desc,3 desc;
-- from this table we can see that income did not determine win of award. 

-- c	Which directors and writers have worked on the most award-winning Pixar films?
select * from academy;
select * from cleaned_pixar_people;
with win as (select film,count(film) as times_win, case when count(film) >1 then 'most-award-winning'
else 'less' end as rate from academy where status= 'Won'  group by 1 order by 2 desc)
select distinct a.film,c.name,c.role_type from academy as a join cleaned_pixar_people as c on a.film=c.film join win as w
on c.film=w.film where a.status='Won' and role_type in 
('Director','Screenwriter','Storywriter') and w.rate = 'most-award-winning';

-- 4.	Genre Trends and Film Characteristics:
-- a	Which genres (Adventure, Comedy, Fantasy, etc.) are most common among Pixar films?
select * from genres;
select * from box_office;
select * from pixar_film;
select value,count(*) as count, case when count(*) between 1 and 5 then 'not really watch' when count(*) between 6 and 25 then 'average'
else 'most-common' end as category from genres where category = "Genre" group by 1;

-- b	What is the average runtime of Pixar films over different periods, and does it affect box office performance?
-- i  What is the average runtime of Pixar films over different periods
select case when year(release_date) between 1995 and 2005 then '1st decade' when year(release_date) between 2006 and 2015 then '2nd decade' else '3rd decade'
end as period ,avg(run_time) as avg from pixar_film group by 1 order by 2 desc;

-- ii and does it affect box office performance?
select * from pixar_film;
select * from box_office;
with avg_period as(select case when year(release_date) between 1995 and 2005 then '1st decade' when year(release_date) between 2006 and 2015 then '2nd decade' else '3rd decade'
end as period ,avg(run_time) as avg from pixar_film group by 1),
sum_period as(select case when year(p.release_date) between 1995 and 2005 then '1st decade' when year(p.release_date) between 2006 and 2015 then '2nd decade' else '3rd decade'
end as period, sum(b.box_office_worldwide) as price_per_decade from pixar_film as p join box_office as b on p.film=b.film group by 1)
select a.period,a.avg,s.price_per_decade from avg_period as a join sum_period as s on a.period=s.period;

-- c	Are certain genres more likely to receive higher critic or audience scores?
select * from genres;
select * from public_response;
with genre_category as(select film,value from genres where category= 'Genre'),
audience_score as(select film, rotten_tomatoes_score + metacritic_score + imdb_score as total_audience_score from public_response),
total_genre as(select g.value,round(sum(a.total_audience_score),0) as total_per_genre from genre_category as g 
join audience_score as a on g.film=a.film group by 1 order by 2 desc)
select *, case when total_per_genre between 0 and 200 then 'critic score' when total_per_genre between 201 and 1000 then 'normal score' else 'good score'
end as audience_score from total_genre;

-- 5.	Creative Team Contributions:
-- a	Who are the most frequent directors, writers, and composers in Pixar's history?
select * from cleaned_pixar_people;
select distinct role_type from cleaned_pixar_people;
with ranks as (select role_type,name,count(*) as number,rank() over(partition by role_type order by count(*) desc) as rannk 
from cleaned_pixar_people group by 1,2 order by 3 desc)
select role_type,name,number from ranks where rannk=1;

-- b	Is there a correlation between specific creators and the success of films?
select * from cleaned_pixar_people;
with creators_number as(select film, count(role_type) as number_of_creators from cleaned_pixar_people group by 1 order by 2 desc),
roi_table as(select film,budget, box_office_worldwide, box_office_worldwide - budget as Roi from box_office where box_office_worldwide > budget)
select r.film,r.box_office_worldwide,r.budget,r.roi,c.number_of_creators from roi_table as r join creators_number as c on r.film=c.film order by 4 desc;
-- so number of creators  did not enchance movies success rate

-- c	Which individuals have worked on the most financially successful and critically acclaimed Pixar films?

select * from cleaned_pixar_people;
select * from box_office;
-- i Which individuals have worked on the most financially successful
with profitable_film as(select film,box_office_worldwide,budget,box_office_worldwide - budget as roi from box_office 
where box_office_worldwide > budget order by 4 desc limit 1)
select * from cleaned_pixar_people where film=(select film from profitable_film);

-- ii critically acclaimed Pixar films?
with critically_film as(select film,box_office_worldwide,budget,box_office_worldwide - budget as roi from box_office where box_office_worldwide < budget
order by 4 limit 1)
select * from cleaned_pixar_people where film=(select film from critically_film);