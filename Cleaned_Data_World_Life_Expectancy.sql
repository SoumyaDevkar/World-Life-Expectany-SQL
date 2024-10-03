SELECT * 
FROM world_life_expectancy
;

# We are trying to delete the duplicate
# Here our idea is to first CONCAT Ciuntry, Year, then we will Count on CONCAT to find is there anything which is > 1 
# If there is anything > 1 then we will delete that row, for that we need row_id as well , we will do that later

SELECT Country, Year, 
CONCAT(Country, Year)
FROM world_life_expectancy
;

# We did a Count on CONCAT fn to see is there anything which is repeating.

SELECT Country, Year, 
CONCAT(Country, Year), 
COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year
;

# we found the repeating values down query
SELECT Country, Year, 
CONCAT(Country, Year), 
COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year
HAVING COUNT(CONCAT(Country, Year)) > 1
;

# Now we need find their row_id to delete that

SELECT *
FROM(
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year)) AS Row_num
	FROM world_life_expectancy) AS Row_table
	WHERE Row_num > 1
;

# we found the row_id, now we will delete the row_id

DELETE FROM world_life_expectancy
WHERE Row_ID IN (
SELECT Row_ID
FROM(
SELECT Row_ID, 
CONCAT(Country, Year),
ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year)) AS Row_num
FROM world_life_expectancy) AS Row_table
WHERE Row_num > 1)
;

# Let's see if it get deleted or not

SELECT * 
FROM world_life_expectancy
;
# We did it, we cleaned all the overlapping values which were repeating in the "YEAR COLUMN"
# Now there is no more duplicate year for a specific country
# for eg- afg -2022
#         afg -2022
# we deleted the duplicate 



# ----------------- NOW WE WILL INSERT VALUE IN THE STATUS COLUMN------------------------------------#
# #If there are blanks or null values in the Status column we will update value in the blank cloumn with respect to the Country

SELECT * 
FROM world_life_expectancy
;

# To check is there any null Blank in Status
SELECT Country,Status 
FROM world_life_expectancy
WHERE Status = ''
;

# To check is there any null Values in Status
SELECT Country,Status 
FROM world_life_expectancy
WHERE Status IS NULL
;

SELECT DISTINCT Status
FROM world_life_expectancy
WHERE Status <> ''
;

SELECT DISTINCT (Country)
FROM world_life_expectancy
WHERE Status <> 'Developing'
;


SELECT DISTINCT (Country)
FROM world_life_expectancy
WHERE Status = 'Developed'
;


UPDATE world_life_expectancy t1 
JOIN world_life_expectancy t2 
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;


UPDATE world_life_expectancy t1 
JOIN world_life_expectancy t2 
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

# Now we will fill the blanks in the life expentancy column

SELECT * 
FROM world_life_expectancy
;

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;
# blanks in the two rows
# we will fill that by taking avg from next year and previous year of the same country
# for that we have to do self join

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
 t2.Country, t2.Year, t2.`Life expectancy`, 
 t3.Country, t3.Year, t3.`Life expectancy`,
 ROUND((t2.`Life expectancy`+ t3.`Life expectancy`) / 2, 1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.YEAR = t2.YEAR - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.YEAR = t3.YEAR + 1
WHERE t1. `Life expectancy` = ''
;

# now we will put the average value in the first table and update it

UPDATE  world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.YEAR = t2.YEAR - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.YEAR = t3.YEAR + 1
SET t1.`Life expectancy`=  ROUND((t2.`Life expectancy`+ t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = ''
;

SELECT * 
FROM world_life_expectancy
;


