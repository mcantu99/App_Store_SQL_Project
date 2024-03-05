CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

** EXPLORATORY DATA ANALYSIS**

-- check the number of unique apps in both tables -- 

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined

-- Check for any missing values in key fields --

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS NULL OR user_rating ISNULL OR prime_genre ISNULL

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc IS NULL 

-- Find out the number of apps per genre -- 

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

-- Find overview of apps ratings -- 

SELECT min(user_rating) AS MinRating,
	   max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore

-- Get the distribution of app prices -- 

SELECT 
	(price / 2) *2 AS PriceBinStart,
    ((price / 2) *2) + 2 AS PriceBinEnd,
    COUNT(*) AS NumApps
From AppleStore
GROUP BY PriceBinStart
ORDER by PriceBinStart


** DATA ANALYSIS **

-- Determine when wether paid apps have higher rating than free apps -- 

SELECT CASE
			WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
       End AS App_Type,
       avg(user_rating) AS AvgRating
FROM AppleStore
GROUP BY App_Type

-- Check if apps with more supported languages have higher ratings --

SELECT CASE 	
			WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
       END AS language_bucket,
       avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

-- Check the genres with low ratings -- 

SELECT prime_genre,
	   avg(user_rating) As Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC

-- Check if there is a correlation between the length of the apps description and the user rating -- 

SELECT CASE 
			WHEN length(b.app_desc) <500 THEN 'Short'
            when length(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
            ELSE 'Long'
       END AS description_length_bucket,
       avg(a.user_rating) AS Avg_Rating
from 
	AppleStore AS A 
JOIN 
	appleStore_description_combined AS B
ON a.id = b.id 

GROUP BY description_length_bucket
ORDER BY Avg_Rating DESC

-- Check the top rated apps for each genre -- 

SELECT
	prime_genre,
    track_name,
    user_rating
FROM (
  	  SELECT
  	  prime_genre,
      track_name,
      user_rating,
  	  RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
      FROM AppleStore
  	 ) AS a 
WHERE
 a.rank = 1
 
 ** FINAL COMMENTARY AND OBSERVATIONS ** 
 -- Paid apps have better ratings,
 -- Apps supporting over 10-30 languages have better ratings
 -- Finance and Book apps have the lowest ratings
 -- Longer description apps have better ratigns
 -- A new App should aim for a rating of 3.5 or above
 -- Games and Entertainment are the leading competition