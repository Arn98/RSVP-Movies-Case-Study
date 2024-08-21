USE imdb;


-- Q1. Find the total number of rows in each table of the schema?
SELECT table_name, table_rows from INFORMATION_SCHEMA.tables
WHERE TABLE_SCHEMA = 'imdb';




-- Q2. Which columns in the movie table have null values?
SELECT 
		SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_null, 
		SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_null, 
		SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_null,
		SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_null,
		SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_null,
		SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_null,
		SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_null,
		SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_null,
		SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_null

FROM movie;








-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
SELECT year, COUNT(year) AS number_of_movies 
FROM movie
GROUP BY year;

SELECT month(date_published) AS month_num, COUNT(month(date_published)) AS number_of_movies
FROM movie
GROUP BY month_num
ORDER BY month_num;











  
-- Q4. How many movies were produced in the USA or India in the year 2019??

SELECT country, COUNT(*) AS count_movies
FROM movie
WHERE (country='USA' OR country='India') AND year = 2019
GROUP BY country;




-- Q5. Find the unique list of the genres present in the data set?


SELECT DISTINCT genre AS Unique_Genres_List FROM genre;








/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT g.genre, COUNT(g.genre) AS number_of_movies, m.year 
FROM movie AS m
INNER JOIN genre AS g ON m.id = g.movie_id
GROUP BY g.genre, m.year
ORDER BY number_of_movies DESC
LIMIT 1;






-- Q7. How many movies belong to only one genre?


SELECT COUNT(movie_id) AS number_of_movies_with_one_genre
FROM (
    SELECT movie_id, COUNT(genre) AS number_of_genre_movies 
    FROM genre
    GROUP BY movie_id
    HAVING number_of_genre_movies = 1
) AS subquery;







-- Q8.What is the average duration of movies in each genre? 


SELECT g.genre, ROUND(AVG(m.duration), 2) AS avg_duration 
FROM movie AS m 
INNER JOIN genre AS g ON m.id = g.movie_id 
GROUP BY g.genre;



-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 



WITH genre_rankings AS(
SELECT genre,count(genre) AS movie_count, 
RANK() OVER(ORDER BY count(genre) DESC) AS genre_rank
FROM genre
GROUP BY genre)
SELECT * FROM genre_rankings
WHERE genre = 'Thriller';













-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?


SELECT 

	ROUND(MIN(avg_rating)) AS min_avg_rating,
    ROUND(MAX(avg_rating)) AS max_avg_rating,
	MIN(total_votes) AS min_total_votes,
    MIN(total_votes) AS max_total_votes,
	MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating 
    
FROM ratings;




-- Q11. Which are the top 10 movies based on average rating?

SELECT m.title, r.avg_rating, 
DENSE_RANK() OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM movie AS m
INNER JOIN
ratings AS r
ON m.id = r.movie_id
LIMIT 10;







-- Q12. Summarise the ratings table based on the movie counts by median ratings.

SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;





-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

SELECT m.production_company,COUNT(m.title) AS movie_count,
DENSE_RANK() OVER(ORDER BY COUNT(m.title) DESC) AS prod_company_rank
FROM movie AS m
INNER JOIN
ratings AS r
ON m.id = r.movie_id
WHERE production_company IS NOT NULL AND r.avg_rating > 8
GROUP BY production_company
LIMIT 2;








-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

SELECT g.genre, COUNT(g.movie_id) AS movie_count
FROM genre AS g
INNER JOIN
movie AS m
ON g.movie_id = m.id
INNER JOIN
ratings AS r
ON m.id = r.movie_id
WHERE (m.date_published BETWEEN '2017-03-01'AND '2017-03-31') AND (m.country = 'USA') AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;







-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?


SELECT m.title, r.avg_rating, g.genre
FROM movie AS m
INNER JOIN ratings AS r ON m.id = r.movie_id
INNER JOIN genre AS g ON m.id = g.movie_id
WHERE (m.title REGEXP '^The') AND (r.avg_rating > 8)
GROUP BY m.title, r.avg_rating, g.genre;



-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT count(movie_id) AS movies 
FROM 
ratings AS ratings
INNER JOIN 
movie AS movie
ON ratings.movie_id=movie.id
WHERE (movie.date_published BETWEEN '2018-04-01' AND '2019-04-01') AND (ratings.median_rating = 8)
GROUP BY ratings.median_rating;




-- Q17. Do German movies get more votes than Italian movies? 


with german_summary AS (
SELECT SUM(r.total_votes) AS german_total_votes,
RANK() OVER(ORDER BY SUM(r.total_votes)) AS unique_id
FROM movie AS m
INNER JOIN ratings AS r
ON m.id=r.movie_id
WHERE m.languages LIKE '%German%'
), italian_summary AS (
SELECT SUM(r.total_votes) AS italian_total_votes,
RANK() OVER(ORDER BY sum(r.total_votes)) AS unique_id
FROM movie AS m
INNER JOIN ratings AS r
ON m.id=r.movie_id
WHERE m.languages LIKE '%Italian%'
) SELECT *,
CASE
	WHEN german_total_votes > italian_total_votes THEN 'Yes' ELSE 'No'
    END AS 'German_Movie_Is_Popular_Than_Italian_Movie'
FROM german_summary
INNER JOIN
italian_summary
USING(unique_id);    





-- Q18. Which columns in the names table have null values??


SELECT COUNT(*)-COUNT(name) AS name_nulls, 
		COUNT(*)-COUNT(height) AS height_nulls, 
		COUNT(*)-COUNT(date_of_birth) AS date_of_birth_nulls, 
		COUNT(*)-COUNT(known_for_movies) AS known_for_movies_nulls
FROM names; 








-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

WITH genre_top3 AS (
    SELECT g.genre, COUNT(g.movie_id) AS movie_count
    FROM movie AS m
    INNER JOIN genre AS g ON m.id = g.movie_id
    INNER JOIN ratings AS r ON m.id = r.movie_id
    WHERE r.avg_rating > 8
    GROUP BY g.genre
    ORDER BY movie_count DESC
    LIMIT 3
)
SELECT n.name AS director_name, COUNT(m.id) AS movie_count
FROM names AS n
INNER JOIN director_mapping AS d ON n.id = d.name_id
INNER JOIN movie AS m ON d.movie_id = m.id
INNER JOIN genre AS g ON m.id = g.movie_id
INNER JOIN ratings AS r ON m.id = r.movie_id
WHERE r.avg_rating > 8 
    AND g.genre IN (SELECT genre FROM genre_top3)
GROUP BY director_name
ORDER BY movie_count DESC
LIMIT 3;








-- Q20. Who are the top two actors whose movies have a median rating >= 8?

SELECT DISTINCT name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM ratings AS r
INNER JOIN role_mapping AS rm
ON rm.movie_id = r.movie_id
INNER JOIN names AS n
ON rm.name_id = n.id
WHERE median_rating >= 8 AND category = 'actor'
GROUP BY name
ORDER BY movie_count DESC
LIMIT 2;









-- Q21. Which are the top three production houses based on the number of votes received by their movies?

SELECT production_company, SUM(r.total_votes) AS vote_count,
DENSE_RANK() OVER(ORDER BY sum(r.total_votes)DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN
ratings AS r 
ON m.id= r.movie_id
GROUP BY production_company
LIMIT 3;







-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?

SELECT 
    nm.name AS actor_name, 
    SUM(r.total_votes) AS total_votes, 
    COUNT(DISTINCT m.id) AS movie_count,
    ROUND(SUM(r.avg_rating * r.total_votes) /
 
SUM(r.total_votes), 2) AS
 
actor_avg_rating,
    RANK() OVER (
        ORDER
 
BY ROUND(SUM(r.avg_rating
 
* r.total_votes) /
 
SUM(r.total_votes), 2) DESC
    ) AS actor_rank
FROM movie AS m
INNER JOIN ratings AS r ON m.id = r.movie_id
INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
INNER JOIN names AS nm ON rm.name_id = nm.id
WHERE rm.category = 'actor' AND m.country = 'India'
GROUP BY nm.name
HAVING movie_count >= 5
LIMIT 3;







-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 

SELECT nm.name AS actress_name,
       SUM(r.total_votes) AS total_votes,
       COUNT(DISTINCT m.id) AS movie_count,
       ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) AS actress_avg_rating,
       RANK() OVER (ORDER BY ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) DESC) AS actress_rank
FROM movie AS m
INNER JOIN ratings AS r ON m.id = r.movie_id
INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
INNER JOIN names AS nm ON rm.name_id = nm.id
WHERE rm.category = 'actress' AND m.country LIKE '%India%' AND m.languages LIKE '%Hindi%'
GROUP BY nm.name
HAVING COUNT(CASE WHEN m.country = 'India' THEN 1 END) >= 3
LIMIT 5;











-- Q24. Select thriller movies as per avg rating and classify them in the following category: 


SELECT title,r.avg_rating,
	CASE 
		WHEN avg_rating > 8 THEN 'Superhit movies'
		WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
		WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
		WHEN avg_rating < 5 THEN 'Flop movies'
	END AS avg_rating_category
FROM movie AS m
INNER JOIN genre AS g
ON m.id=g.movie_id
INNER JOIN ratings AS r
ON m.id=r.movie_id
WHERE genre='thriller'
ORDER BY r.avg_rating DESC;







-- Q25. What is the genre-wise running total and moving average of the average movie duration? 


SELECT genre,
	ROUND(AVG(duration)) AS avg_duration,
	SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
	ROUND(AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING),2) AS moving_avg_duration

FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;









-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 


WITH top_3_genre AS
( 	
	SELECT genre, COUNT(movie_id) AS number_of_movies
    FROM genre AS g
    INNER JOIN movie AS m
    ON g.movie_id = m.id
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
    LIMIT 3
),

top_5 AS
(
	SELECT genre,
			year,
			title AS movie_name,
			worlwide_gross_income,
			DENSE_RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
        
	FROM movie AS m 
    INNER JOIN genre AS g 
    ON m.id= g.movie_id
	WHERE genre IN (SELECT genre FROM top_3_genre)
)

SELECT *
FROM top_5
WHERE movie_rank<=5;









-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?


SELECT production_company ,count(m.id)AS movie_count, 
RANK() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id=r.movie_id
WHERE median_rating>=8 AND production_company IS NOT NULL AND position(',' IN languages)>0
GROUP BY production_company
LIMIT 2;










-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

SELECT n.name, SUM(r.total_votes) AS total_votes,
       COUNT(DISTINCT rm.movie_id) AS movie_count,
       AVG(r.avg_rating) AS avg_rating,
       DENSE_RANK() OVER (ORDER BY AVG(r.avg_rating) DESC) AS actress_rank
FROM names AS n
INNER JOIN role_mapping AS rm ON n.id = rm.name_id
INNER JOIN ratings AS r ON r.movie_id = rm.movie_id
INNER JOIN genre AS g ON r.movie_id = g.movie_id
WHERE rm.category = 'actress' AND r.avg_rating > 8 AND g.genre = 'drama'
GROUP BY n.name
ORDER BY avg_rating DESC
LIMIT 3;







/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations*/



WITH movie_date_information AS
(
SELECT d.name_id, name, d.movie_id,
	   m.date_published, 
       LEAD(date_published, 1) OVER(PARTITION BY d.name_id ORDER BY date_published, d.movie_id) AS next_movie_date
FROM director_mapping d
	 JOIN names AS n 
     ON d.name_id=n.id 
	 JOIN movie AS m 
     ON d.movie_id=m.id
),

date_diff AS
(
	 SELECT *, DATEDIFF(next_movie_date, date_published) AS diff
	 FROM movie_date_information
 ),
 
 avg_inter_days AS
 (
	 SELECT name_id, AVG(diff) AS avg_inter_movie_days
	 FROM date_diff
	 GROUP BY name_id
 ),
 
 final_output AS
 (
	 SELECT d.name_id AS director_id,
		 name AS director_name,
		 COUNT(d.movie_id) AS number_of_movies,
		 ROUND(avg_inter_movie_days) AS avg_inter_movie_days,
		 ROUND(AVG(avg_rating),2) AS avg_rating,
		 SUM(total_votes) AS total_votes,
		 MIN(avg_rating) AS min_rating,
		 MAX(avg_rating) AS max_rating,
		 SUM(duration) AS total_duration,
		 ROW_NUMBER() OVER(ORDER BY COUNT(d.movie_id) DESC) AS director_rank
	 FROM
		 names AS n 
         JOIN director_mapping AS d 
         ON n.id=d.name_id
		 JOIN ratings AS r 
         ON d.movie_id=r.movie_id
		 JOIN movie AS m 
         ON m.id=r.movie_id
		 JOIN avg_inter_days AS a 
         ON a.name_id=d.name_id
	 GROUP BY director_id
 )
 SELECT *	
 FROM final_output
 LIMIT 9; 





