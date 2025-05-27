# Pixar film analysis
![image](https://github.com/user-attachments/assets/e805ef30-a4de-4f82-8a87-b5e2d1d9cbe7)

## Table of Contents
- [Introduction](#Introduction)
- [Dataset Overview](#Dataset-Overview)
- [Data Cleaning and Transformation](#Data-Cleaning-and-Transformation)
- [Data Exploration and Insight](#Data-Exploration-and-Insight)
- [Recommendation](#Recommendation)
- [Conclusion](#Conclusion)

  ### Introduction
This project explores a data-driven analysis of Pixar films using advanced SQL techniques. The goal is to uncover insights into film performance, production trends, and audience reception by querying and analyzing structured datasets related to Pixar's movie catalog.

To perform this analysis, I utilized several key SQL features:
- Window Functions to calculate running totals, rankings, and moving averages across films.
- Common Table Expressions (CTEs) to simplify complex queries and break down analysis into logical steps.
- Subqueries to filter and compare data within nested contexts.
- Joins to combine information from multiple related tables, such as film details, box office data, and critic scores.

This combination of techniques enabled a comprehensive look at Pixar’s production history, including trends in film ratings, release patterns, and commercial success.

  ### Dataset Overview
  The dataset used in this project contains detailed information about Pixar’s feature films, spanning multiple aspects of production, performance, and reception. It is structured into several interrelated tables to support in-depth SQL analysis.

🗂️ Key Tables & Fields:
1. pixar_films:
    - film_id (Primary Key).
    - film
    - title.
    - release_date.
    - run_time.
    - film_rating.
    - rating.
    
2. Public response.

3. Pixar_people:
    - film (Foreign key).
    - role_type.
    - name.
    
4. Genres.

5. box_office:
    - film(foreign key).
    - budget.
    - box_office_us_canada: amount generate in us and canada.
    - box_office_other: amount generate in other region.
    - box_office_worldwide: amount generate in box_office_us_canada + amount generate in box_office_other.
    
6. academy:
    - film(foreign key).
    - award_type: the nature of the award given.
    - status: current status.

### Data Cleaning and Transformation

To prepare the Pixar dataset for analysis, the following data cleaning and transformation steps were performed:

1. Standardized Date Formats

    - Converted release_date fields to consistent DATE format for accurate sorting and filtering.

2. Trimmed and Cleaned Text Fields

    - Removed extra spaces and standardized capitalization for film titles, genres, and names (e.g., "Toy story " → "Toy Story").

3. Handled Missing Values

    - Replaced or flagged nulls in key fields like box_offices and public_response.

    - Excluded records with critical missing data (e.g., film name or release date).

4. Unified Data Types

    - Ensured numerical fields (like budget, box_offices, and run_time) were cast to proper numeric types for calculations.
    
5. Created Derived Columns

    - Added calculated fields like profit (box_office_worldwide - budget) and year (extracted from release_date).

6. Resolved Duplicates and Inconsistencies

    - Deduplicated film records across tables using film name and release date as unique keys.

### Data Exploration and Insight
 1.	Financial Performance Analysis:

a. 	What are the top 5 highest-grossing Pixar films worldwide?
```sql
select film,box_office_worldwide from box_office order by 2 desc limit 5;
```
Insight: The top 5 films are: Inside Out 2

Incredibles 2

Toy Story 4

Toy Story 3

Finding Dory.

b.	How have Pixar films performed financially over the years? What is the relationship between budget and box office earnings? Which films were the most profitable.

i. How have Pixar films performed financially over the years?
```sql
select year(p.release_date) as year,count(year(p.release_date)) as number, case when budget > box_office_worldwide then 'loss' 
when budget < box_office_worldwide then 'profit' end as performance from pixar_film as p join box_office as b on p.film=b.film group by 1,3 order by 2 desc;
```
Insight: The analysis reveals that Pixar films have mostly been financially successful, with the majority of releases earning more revenue than their production budgets, resulting in a "profit" classification. The breakdown over the years shows consistent profitability, especially in years with multiple film releases.

In years where multiple films were released, such as 2017 and 2019, Pixar maintained a strong box office performance, with most of the films falling under the "profit" category. Only a few instances of "loss" are observed, indicating that Pixar generally manages production costs well relative to global earnings.

ii. What is the relationship between budget and box office earnings?
```sql
select * from box_office;
```
Insight: budget is the propose amount to be made why box office is the actual amount made.

iii. Which films were the most profitable
```sql
with profitable_films as(select film,box_office_worldwide,budget, box_office_worldwide - budget as roi 
from box_office where box_office_worldwide > budget order by 4 desc)
select film from profitable_films limit 1;
```
Insight: The most profitable movie is Inside out 2.

c. How does budget correlate with box office performance across different regions (US/Canada vs. International)?
```sql
select * from box_office;
```
Insight: budget is the value propose while box_office_us_canada is the  actual income generate from us and canada office and box_office_other is the amount generate in other country
while the box_office_worldwide is the sum of box_office in all country.

d. Which films achieved the highest return of investment (ROI), and how does this compare across different decades?

i. Which films achieved the highest return of investment (ROI).
```sql
with decade as(select b.film,b.budget,b.box_office_worldwide,b.box_office_worldwide - b.budget as Roi,p.release_date,case when year(p.release_date) between 1995 and 2005 then '1st' 
when year(p.release_date) between 2006 and 2015 then '2nd' else '3rd' end as decades from box_office as b join pixar_film as p on b.film=p.film)
select b.film,b.budget, b.box_office_worldwide, b.box_office_worldwide - b.budget as Roi,d.release_date,d.decades from box_office as b join decade as d order by 4 desc
limit 1;
```
Insight: The movie Inside out 2 make the highest return of investment(roi) with 1498030965 value.

ii. and how does this compare across different decades?
```sql
with decade as(select b.film,b.budget,b.box_office_worldwide,b.box_office_worldwide - b.budget as Roi,p.release_date,case when year(p.release_date) between 1995 and 2005 then '1st' 
when year(p.release_date) between 2006 and 2015 then '2nd' else '3rd' end as decades from box_office as b join pixar_film as p on b.film=p.film),
sum_roi as(select decades , sum(Roi) as Total_ROI from decade group by 1),
lag_price as(select *, lag(total_roi,1,0) over (order by total_roi ) as Previous_Price from sum_roi)
select *, concat(round(coalesce(((total_roi - Previous_Price)/Previous_Price)*100,0),2),'','%') as Percentage from lag_price;
```
Insight: This analysis calculates the Return on Investment (ROI) for each Pixar film, groups them by decade, and then compares the total ROI across three distinct time periods:

1st Decade (1995–2005)

2nd Decade (2006–2015)

3rd Decade (2016–present)

📊 Key Findings:
1. Top ROI Films:
Individual films like "Toy Story", "Finding Nemo", and "Inside Out" generated the highest ROI, where modest production budgets led to massive worldwide box office returns.

Decade-Level ROI Trends:

1st Decade (1995–2005):
Despite fewer releases, this era produced a strong ROI foundation. Films like Toy Story and Monsters, Inc. delivered huge returns relative to their lower budgets.

2nd Decade (2006–2015):
This period shows the highest total ROI, driven by hits like Up, Inside Out, and Toy Story 3, which balanced higher budgets with even high budget.

3rd Decade (2016–present):
While successful films like Coco and Soul emerged, the overall ROI growth has slowed, likely due to increasing budgets, market saturation, and the impact of streaming and the COVID-19 pandemic on box office earnings.

Percentage Growth Comparison:

The 2nd decade saw a significant percentage increase in ROI over the 1st, showcasing Pixar's commercial peak.

The 3rd decade showed a slower growth, indicating shifts in the industry and consumption models.


2.	Audience and Critical Reception:

a. How do audience ratings (IMDB, Rotten Tomatoes, Metacritic) correlate with box office earnings?

```sql
select p.film,p.imdb_score + p.rotten_tomatoes_score + p.metacritic_score as total_rating,b.box_office_worldwide from public_response as p
join box_office as b on p.film=b.film order by 3 desc;
```
Insight: From the result, it show that audience rating did not influence the income.

b. 	What is the distribution of Pixar films by CinemaScore rating, and how does it impact financial success?

i. What is the distribution of Pixar films by CinemaScore rating.
```sql
with cinema_rating as(select film,cinema_score, case when cinema_score='NA' then 'Not rated' when cinema_score='A-' then 'Less rated' when cinema_score='A' then 'Normal rating' when
cinema_score='A+' then 'Highly rated' end as Distribution from public_response)
select distribution,count(distribution) from cinema_rating group by 1;
```
Insight: The Cinema rating distribution is as follows: Normal rating:15

Highly rated: 7

Less rated:3

Not rated:3

ii. and how does it impact financial success?
```sql
select p.film, p.cinema_score, b.box_office_worldwide, b.box_office_worldwide - b.budget as roi,case when b.box_office_worldwide - b.budget > 1000000000 then 'high profit' 
when b.box_office_worldwide - b.budget >500000000 then 'profitable' when b.box_office_worldwide - b.budget > 0 then 'low profit' else 'loss' end as rating
from public_response as p join box_office as b on p.film=b.film order by 3 desc;
```
Insight: This show that high cinema rating lead to high return of investment(roi).

c. 	Have audience ratings improved or declined over the years?
```sql
with total as(select film,rotten_tomatoes_score + metacritic_score + imdb_score as total_audience_rating from public_response order by 2 desc),
rating as (select p.film, t.total_audience_rating as total_audience_rating, year(p.release_date) as year from pixar_film as p join total as t on p.film=t.film order by 3)
select *, lag(total_audience_rating,1,0) over (order by year ) as Previous_rating,concat(round(((total_audience_rating - lag(total_audience_rating,1,0) over (order by year ))
/lag(total_audience_rating,1,0) over (order by year ))*100,2),'%') as percentage_rating from rating;
```
Insight: From this table it is Fluctuating

3.	Awards and Recognition:
   
a.	Which Pixar films have won or been nominated for Academy Awards?
```sql
select film,count(film) as times_won_or_nominated from academy where status= 'Nominated' or 'Won' group by 1 order by 2 desc;
```
Insight: The table show the films that win or been nominated for the award.

b. How does winning an Oscar impact a film's financial success?
```sql
select a.film,count(a.film) as number_of_winning,b.box_office_worldwide from academy as a join
box_office as b on a.film=b.film where a.status= 'Won' group by 1,3 order by 2 desc,3 desc;
```
Insight: From this table we can see that income did not determine winning of award. 

c.	Which directors and writers have worked on the most award-winning Pixar films?
```sql
else 'less' end as rate from academy where status= 'Won'  group by 1 order by 2 desc)
select distinct a.film,c.name,c.role_type from academy as a join cleaned_pixar_people as c on a.film=c.film join win as w
on c.film=w.film where a.status='Won' and role_type in 
('Director','Screenwriter','Storywriter') and w.rate = 'most-award-winning';
```
Insight: The result is shown on the table.

4.	Genre Trends and Film Characteristics:
   
a.	Which genres (Adventure, Comedy, Fantasy, etc.) are most common among Pixar films?
```sql
select value,count(*) as count, case when count(*) between 1 and 5 then 'not really watch' when count(*) between 6 and 25 then 'average'
else 'most-common' end as category from genres where category = "Genre" group by 1;
```
Insight: Adventure and animation are most common genres in pixal films.

b.	What is the average runtime of Pixar films over different periods, and does it affect box office performance?
i. What is the average runtime of Pixar films over different periods.
```sql
select case when year(release_date) between 1995 and 2005 then '1st decade' when year(release_date) between 2006 and 2015 then '2nd decade' else '3rd decade'
end as period ,avg(run_time) as avg from pixar_film group by 1 order by 2 desc;
```
Insight: As display on the table.

ii. and does it affect box office performance?
```sql
with avg_period as(select case when year(release_date) between 1995 and 2005 then '1st decade' when year(release_date) between 2006 and 2015 then '2nd decade' else '3rd decade'
end as period ,avg(run_time) as avg from pixar_film group by 1),
sum_period as(select case when year(p.release_date) between 1995 and 2005 then '1st decade' when year(p.release_date) between 2006 and 2015 then '2nd decade' else '3rd decade'
end as period, sum(b.box_office_worldwide) as price_per_decade from pixar_film as p join box_office as b on p.film=b.film group by 1)
select a.period,a.avg,s.price_per_decade from avg_period as a join sum_period as s on a.period=s.period;
```
Insight: From the table, we can see that the runtime have impact on income. 

c.	Are certain genres more likely to receive higher critic or audience scores?
```sql
with genre_category as(select film,value from genres where category= 'Genre'),
audience_score as(select film, rotten_tomatoes_score + metacritic_score + imdb_score as total_audience_score from public_response),
total_genre as(select g.value,round(sum(a.total_audience_score),0) as total_per_genre from genre_category as g 
join audience_score as a on g.film=a.film group by 1 order by 2 desc)
select *, case when total_per_genre between 0 and 200 then 'critic score' when total_per_genre between 201 and 1000 then 'normal score' else 'good score'
end as audience_score from total_genre;
```
Insight: Yes.

5.	Creative Team Contributions

a.	Who are the most frequent directors, writers, and composers in Pixar's history?
```sql
with ranks as (select role_type,name,count(*) as number,rank() over(partition by role_type order by count(*) desc) as rannk 
from cleaned_pixar_people group by 1,2 order by 3 desc)
select role_type,name,number from ranks where rannk=1;
```
Insight: As seen in the table.

b.	Is there a correlation between specific creators and the success of films?
```sql
with creators_number as(select film, count(role_type) as number_of_creators from cleaned_pixar_people group by 1 order by 2 desc),
roi_table as(select film,budget, box_office_worldwide, box_office_worldwide - budget as Roi from box_office where box_office_worldwide > budget)
select r.film,r.box_office_worldwide,r.budget,r.roi,c.number_of_creators from roi_table as r join creators_number as c on r.film=c.film order by 4 desc;
```
Insight: Number of creators  did not enchance movies success rate.

c.	Which individuals have worked on the most financially successful and critically acclaimed Pixar films?

i. Which individuals have worked on the most financially successful?
``sql
with profitable_film as(select film,box_office_worldwide,budget,box_office_worldwide - budget as roi from box_office 
where box_office_worldwide > budget order by 4 desc limit 1)
select * from cleaned_pixar_people where film=(select film from profitable_film);
```
Insight: As seen in the table.

ii. critically acclaimed Pixar films?
```sql
with critically_film as(select film,box_office_worldwide,budget,box_office_worldwide - budget as roi from box_office where box_office_worldwide < budget
order by 4 limit 1)
select * from cleaned_pixar_people where film=(select film from critically_film);
```
Insight: As seen in the table.

### Recommendation
Based on the analysis of Pixar's box office and critical success, the following recommendations can help maintain and enhance their future impact:

1. Continue Focusing on Original, Emotion-Driven Stories
Pixar’s strength lies in its ability to tell heartfelt, meaningful stories. Maintaining this creative focus will preserve its emotional connection with audiences across all age groups.

2. Balance Films with Original Content
While films like Inside out 2,Toy Story 4 and Incredibles 2 perform well financially, Pixar should also invest in fresh ideas like Turning red,Soul and Onward, which bring innovation and critical acclaim.

3. Preserve High Animation and Production Quality
Pixar’s reputation is built on excellence in visual storytelling. Continuing to invest in advanced animation technology and strong art direction will help maintain this standard.

4. Appeal to a Global Audience
Pixar should continue to include diverse characters and culturally rich stories to connect with international viewers and expand its reach.

5. Strengthen Marketing and Release Timing
Strategic release dates (e.g., summer, holidays) and strong promotional campaigns contribute greatly to box office results. These should remain a priority for future releases.

### Conclusion
Pixar stands as a unique force in the film industry, consistently achieving both box office success and critical acclaim. With multiple films surpassing the billion-dollar mark, Pixar has proven its ability to captivate global audiences. At the same time, its commitment to emotionally rich storytelling, innovative animation, and universal themes has earned it widespread praise from critics and numerous prestigious awards, including multiple Academy Awards.


This combination of financial power and artistic quality is what sets Pixar apart from most studios. It doesn't just create movies for children — it creates meaningful, thought-provoking stories that resonate with all ages. Through this balance, Pixar has established itself not only as a commercial powerhouse but also as a cultural and creative icon in modern cinema.
