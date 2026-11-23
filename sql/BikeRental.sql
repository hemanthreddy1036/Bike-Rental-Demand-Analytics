-- ============================================================
-- PROJECT: BIKE RENTAL DEMAND ANALYSIS (PRCP-1018)
-- TOOL: MySQL
-- DATASET: Capital Bikeshare (day.csv and hour.csv)
-- PURPOSE: Analyze bike rental demand by season, weather and time
-- ============================================================

-- ============================================================
-- 1. DATABASE CREATION
-- ============================================================

CREATE DATABASE bike_rental;

-- ============================================================
-- 2. SELECT DATABASE
-- ============================================================

USE bike_rental;

-- ============================================================
-- 3. DATABASE VERIFICATION
-- ============================================================

SHOW DATABASES;

SELECT DATABASE();

-- ============================================================
-- 4. PREVIEW DATA
-- ============================================================

SELECT *
FROM `day`
LIMIT 10;

SELECT *
FROM `hour`
LIMIT 10;

-- ============================================================
-- 5. TOTAL NUMBER OF RECORDS
-- ============================================================

SELECT COUNT(*) AS total_day_records
FROM `day`;

SELECT COUNT(*) AS total_hour_records
FROM `hour`;

-- ============================================================
-- 6. DATASET STRUCTURE
-- ============================================================

DESCRIBE `day`;

DESCRIBE `hour`;

-- ============================================================
-- 7. CHECK MISSING VALUES (NULL) - DAY DATA
-- ============================================================

SELECT
    SUM(instant IS NULL) AS instant_missing,
    SUM(dteday IS NULL) AS dteday_missing,
    SUM(season IS NULL) AS season_missing,
    SUM(yr IS NULL) AS yr_missing,
    SUM(mnth IS NULL) AS mnth_missing,
    SUM(holiday IS NULL) AS holiday_missing,
    SUM(weekday IS NULL) AS weekday_missing,
    SUM(workingday IS NULL) AS workingday_missing,
    SUM(weathersit IS NULL) AS weathersit_missing,
    SUM(temp IS NULL) AS temp_missing,
    SUM(atemp IS NULL) AS atemp_missing,
    SUM(hum IS NULL) AS hum_missing,
    SUM(windspeed IS NULL) AS windspeed_missing,
    SUM(casual IS NULL) AS casual_missing,
    SUM(registered IS NULL) AS registered_missing,
    SUM(cnt IS NULL) AS cnt_missing
FROM `day`;

-- ============================================================
-- 8. CHECK MISSING VALUES (NULL) - HOUR DATA
-- ============================================================

SELECT
    SUM(instant IS NULL) AS instant_missing,
    SUM(dteday IS NULL) AS dteday_missing,
    SUM(hr IS NULL) AS hr_missing,
    SUM(weathersit IS NULL) AS weathersit_missing,
    SUM(temp IS NULL) AS temp_missing,
    SUM(hum IS NULL) AS hum_missing,
    SUM(windspeed IS NULL) AS windspeed_missing,
    SUM(cnt IS NULL) AS cnt_missing
FROM `hour`;

-- ============================================================
-- 9. CHECK DUPLICATE RECORDS
-- ============================================================

SELECT
    dteday,
    COUNT(*) AS duplicate_count
FROM `day`
GROUP BY dteday
HAVING COUNT(*) > 1;

SELECT
    dteday,
    hr,
    COUNT(*) AS duplicate_count
FROM `hour`
GROUP BY dteday, hr
HAVING COUNT(*) > 1;

-- ============================================================
-- 10. CHECK STRANGE HUMIDITY VALUES
-- ============================================================

SELECT COUNT(*) AS hum_zero_days
FROM `day`
WHERE hum = 0;

SELECT COUNT(*) AS hum_zero_hours
FROM `hour`
WHERE hum = 0;

-- ============================================================
-- 11. CHECK HOURLY TOTALS MATCH DAILY TOTALS
-- ============================================================

SELECT COUNT(*) AS mismatched_days
FROM `day` d
JOIN (
    SELECT dteday, SUM(cnt) AS hourly_total
    FROM `hour`
    GROUP BY dteday
) h
ON d.dteday = h.dteday
WHERE d.cnt <> h.hourly_total;

-- ============================================================
-- 12. CHECK CASUAL + REGISTERED = TOTAL COUNT
-- ============================================================

SELECT COUNT(*) AS rows_where_sum_differs
FROM `day`
WHERE cnt <> casual + registered;

-- ============================================================
-- 13. DAILY RENTAL STATISTICS
-- ============================================================

SELECT
    MIN(cnt) AS minimum_rentals,
    MAX(cnt) AS maximum_rentals,
    ROUND(AVG(cnt), 2) AS average_rentals
FROM `day`;

-- ============================================================
-- 14. YEAR-WISE RENTAL ANALYSIS
-- ============================================================

SELECT
    CASE WHEN yr = 0 THEN 2011 ELSE 2012 END AS year,
    COUNT(*) AS total_days,
    ROUND(AVG(cnt), 0) AS average_daily_rentals,
    SUM(cnt) AS total_rentals
FROM `day`
GROUP BY yr
ORDER BY yr;

-- ============================================================
-- 15. YEARLY GROWTH PERCENTAGE
-- ============================================================

SELECT
    ROUND(100 * (AVG(CASE WHEN yr = 1 THEN cnt END) /
                 AVG(CASE WHEN yr = 0 THEN cnt END) - 1), 1) AS growth_percentage
FROM `day`;

-- ============================================================
-- 16. SEASON-WISE RENTAL ANALYSIS
-- ============================================================

SELECT
    season,
    CASE season
        WHEN 1 THEN 'Winter'
        WHEN 2 THEN 'Spring'
        WHEN 3 THEN 'Summer'
        ELSE 'Fall'
    END AS season_name,
    COUNT(*) AS total_days,
    ROUND(AVG(cnt), 0) AS average_rentals
FROM `day`
GROUP BY season
ORDER BY season;

-- ============================================================
-- 17. MONTH-WISE RENTAL ANALYSIS
-- ============================================================

SELECT
    mnth AS month,
    ROUND(AVG(cnt), 0) AS average_rentals
FROM `day`
GROUP BY mnth
ORDER BY mnth;

-- ============================================================
-- 18. WEEKDAY-WISE RENTAL ANALYSIS
-- ============================================================

SELECT
    weekday,
    ROUND(AVG(cnt), 0) AS average_rentals
FROM `day`
GROUP BY weekday
ORDER BY weekday;

-- ============================================================
-- 19. WORKING DAY ANALYSIS
-- ============================================================

SELECT
    workingday,
    COUNT(*) AS total_days,
    ROUND(AVG(cnt), 0) AS average_rentals
FROM `day`
GROUP BY workingday;

-- ============================================================
-- 20. HOLIDAY ANALYSIS
-- ============================================================

SELECT
    holiday,
    COUNT(*) AS total_days,
    ROUND(AVG(cnt), 0) AS average_rentals
FROM `day`
GROUP BY holiday;

-- ============================================================
-- 21. WEATHER-WISE RENTAL ANALYSIS
-- ============================================================

SELECT
    weathersit,
    CASE weathersit
        WHEN 1 THEN 'Clear'
        WHEN 2 THEN 'Mist/Cloudy'
        WHEN 3 THEN 'Light Rain/Snow'
        ELSE 'Heavy Rain/Snow'
    END AS weather_name,
    COUNT(*) AS total_days,
    ROUND(AVG(cnt), 0) AS average_rentals
FROM `day`
GROUP BY weathersit
ORDER BY weathersit;

-- ============================================================
-- 22. TEMPERATURE BAND ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN temp * 47 - 8 < 5 THEN '1. Below 5C'
        WHEN temp * 47 - 8 < 15 THEN '2. 5 to 15C'
        WHEN temp * 47 - 8 < 25 THEN '3. 15 to 25C'
        ELSE '4. Above 25C'
    END AS temperature_band,
    COUNT(*) AS total_days,
    ROUND(AVG(cnt), 0) AS average_rentals
FROM `day`
GROUP BY temperature_band
ORDER BY temperature_band;

-- ============================================================
-- 23. REGISTERED USER PERCENTAGE
-- ============================================================

SELECT
    ROUND(SUM(registered) * 100.0 / SUM(cnt), 1) AS registered_percentage
FROM `day`;

-- ============================================================
-- 24. CASUAL VS REGISTERED USERS BY WORKING DAY
-- ============================================================

SELECT
    workingday,
    ROUND(AVG(casual), 0) AS average_casual,
    ROUND(AVG(registered), 0) AS average_registered
FROM `day`
GROUP BY workingday;

-- ============================================================
-- 25. HOUR-WISE RENTAL ANALYSIS
-- ============================================================

SELECT
    hr AS hour_of_day,
    ROUND(AVG(cnt), 0) AS average_rentals
FROM `hour`
GROUP BY hr
ORDER BY hr;

-- ============================================================
-- 26. TOP 5 BUSIEST HOURS
-- ============================================================

SELECT
    hr AS hour_of_day,
    ROUND(AVG(cnt), 0) AS average_rentals
FROM `hour`
GROUP BY hr
ORDER BY average_rentals DESC
LIMIT 5;

-- ============================================================
-- 27. HOURLY DEMAND: WORKING DAY VS NON-WORKING DAY
-- ============================================================

SELECT
    hr AS hour_of_day,
    ROUND(AVG(CASE WHEN workingday = 1 THEN cnt END), 0) AS working_day,
    ROUND(AVG(CASE WHEN workingday = 0 THEN cnt END), 0) AS non_working_day
FROM `hour`
GROUP BY hr
ORDER BY hr;

-- ============================================================
-- 28. TOP 5 DAYS WITH HIGHEST RENTALS
-- ============================================================

SELECT
    dteday,
    cnt,
    weathersit,
    temp
FROM `day`
ORDER BY cnt DESC
LIMIT 5;

-- ============================================================
-- 29. TOP 5 DAYS WITH LOWEST RENTALS
-- ============================================================

SELECT
    dteday,
    cnt,
    weathersit,
    temp
FROM `day`
ORDER BY cnt ASC
LIMIT 5;
-- ============================================================
-- 30. MONTH-WISE COMPARISON: 2011 VS 2012
-- ============================================================

SELECT
    mnth AS month,
    ROUND(AVG(CASE WHEN yr = 0 THEN cnt END), 0) AS year_2011,
    ROUND(AVG(CASE WHEN yr = 1 THEN cnt END), 0) AS year_2012
FROM `day`
GROUP BY mnth
ORDER BY mnth;