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
    
