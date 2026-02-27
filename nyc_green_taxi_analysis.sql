-- ===============================================================
-- Project: NYC Green Taxi Trip Analysis (2014)
-- Dataset: BigQuery Public Dataset
-- Source: bigquery-public-data.new_york_taxi_trips
--
-- Objective:
-- Perform exploratory analysis on 2014 NYC Green Taxi trips to
-- understand demand patterns, revenue drivers, rider behavior,
-- and operational performance.
--
-- Tools: Google BigQuery (Standard SQL)
-- ===============================================================


-- ---------------------------------------------------------------
-- Demand and Volume Analysis
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- 1. Top 10 Pickup Locations by Trip Volume
-- ---------------------------------------------------------------
SELECT 
  pickup_location_id,
  COUNT(pickup_location_id) AS rideCount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
GROUP BY pickup_location_id
ORDER BY rideCount DESC
LIMIT 10;

--Insight:
--Identifies high-demand pickup zones to inform driver allocation strategy

-- ---------------------------------------------------------------
-- 2. Trip Frequency by Hour of Day
-- ---------------------------------------------------------------
SELECT 
  EXTRACT(HOUR from pickup_datetime) as hourNum,
  COUNT(*) AS trips
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
GROUP BY hourNum
ORDER BY trips DESC;

--Insight:
--Identifies high-volume taxi demand hours to inform surge pricing strategies

-- ---------------------------------------------------------------
-- 3. Monthly Trip Volume & Month-over-Month Change
-- ---------------------------------------------------------------
WITH monthlyData AS (
  SELECT EXTRACT(month from pickup_datetime) AS monthNum, COUNT(*) AS tripCount
  FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
  GROUP BY monthNum
)

SELECT 
  monthNum, 
  tripCount, 
  tripCount-lag(tripCount) over (ORDER BY monthNum) AS delta
FROM monthlyData
ORDER BY monthNum;

--Insight:
--Identifies seasonal trends informing staffing and marketing strategies

-- ---------------------------------------------------------------
-- Rider Behavior
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- 4. Distribution of Trip Distances
-- ---------------------------------------------------------------
SELECT CASE
  WHEN trip_distance<2 THEN '<2'
  WHEN trip_distance<5 THEN '2<dist<5'
  WHEN trip_distance>=5 THEN '>5 miles'
END AS tripDist,
  COUNT(*) AS tripCount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
GROUP BY tripDist
ORDER BY tripCount DESC;

--Insight:
--Highlights the importance of efficient routing and fare optimization for short trips

-- ---------------------------------------------------------------
-- 5. Passenger Count Distribution (Proportion)
-- ---------------------------------------------------------------
SELECT CASE
  WHEN passenger_count=1 THEN '1'
  WHEN passenger_count=2 THEN '2'
  WHEN passenger_count=3 THEN '3'
  WHEN passenger_count>3 THEN '4+'
END AS passCount,
  COUNT(*)*1.0/sum(COUNT(*)) over() AS totalTrips
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
WHERE passenger_count>0
GROUP BY passCount;

--Insight:
--Highlights high use by low passenger count, providing insight on fleet allocation and vehicle type decisions

-- ---------------------------------------------------------------
-- 6. Trips Recorded with Zero Passengers
-- ---------------------------------------------------------------
SELECT COUNT(*)
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
WHERE passenger_count=0;

--Insight:
--Represents a need for data validation and cleaning

-- ---------------------------------------------------------------
-- Revenue and Financial Analysis
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- 7. Revenue by Vendor
-- ---------------------------------------------------------------
SELECT 
  vendor_id,
  sum(fare_amount) AS totalIncome
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
GROUP BY vendor_id
ORDER BY totalIncome DESC
LIMIT 10;

--Insight:
--Guides performance review and vendor allocation decisions

-- ---------------------------------------------------------------
-- 8. Total Revenue from Long-Distance Trips (>10 miles)
-- ---------------------------------------------------------------
SELECT 
  sum(ifnull(fare_amount,0)
    +ifnull(tip_amount,0)
    +ifnull(tolls_amount,0)
    +ifnull(extra,0)
    +ifnull(mta_tax,0)
    +ifnull(imp_surcharge,0)
    +ifnull(airport_fee,0)) AS totalRevenue
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
WHERE trip_distance>10;

--Insight:
--Identifies high income generated from longer routes, informing special pricing strategies or promotions

-- ---------------------------------------------------------------
-- 9. Revenue by Borough
-- ---------------------------------------------------------------
SELECT 
  zones.borough, 
  sum(rides.fare_amount) AS totalRevenue
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014` rides 
  LEFT JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` zones ON rides.dropoff_location_id=zones.zone_id
GROUP BY zones.borough
ORDER BY totalRevenue DESC;

--Insight:
--Identifies high revenue boroughs as well as underserved markets

-- ---------------------------------------------------------------
-- 10. Longest Trip Recorded
-- ---------------------------------------------------------------
SELECT trip_distance,
  fare_amount,
  tip_amount,
  total_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
ORDER BY trip_distance DESC
LIMIT 1;

--Insight:
--Extremely long trips are unusual so identifies either outliers or impure data

-- ---------------------------------------------------------------
-- 11. Median Fare by Payment Type
-- ---------------------------------------------------------------
SELECT 
  payment_type, 
  approx_quantiles(fare_amount,2)[OFFSET(1)] AS median
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
GROUP BY payment_type;

--Insight:
--Informs payment system strategy and fare modeling


-- ---------------------------------------------------------------
-- Operational Efficiency
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- 12. Highest Average Speed Trip (Filtered for Validity)
-- ---------------------------------------------------------------
WITH validTrips AS (
  SELECT *,
  trip_distance/(EXTRACT(hour FROM (dropoff_datetime-pickup_datetime))
    +EXTRACT(minute from (dropoff_datetime-pickup_datetime))/60
    +EXTRACT(second from (dropoff_datetime-pickup_datetime))/3600) AS avgMPH
  FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
  WHERE dropoff_datetime is not NULL
    AND pickup_datetime is not NULL
    AND dropoff_datetime>pickup_datetime
    AND passenger_count>0
    AND trip_distance<100
    AND trip_distance>0
    AND (EXTRACT(HOUR FROM (dropoff_datetime-pickup_datetime))
      +EXTRACT(MINUTE FROM (dropoff_datetime-pickup_datetime))/60
      +EXTRACT(SECOND FROM (dropoff_datetime-pickup_datetime))/3600)>.25
  )

SELECT
  vendor_id,
  pickup_datetime,
  dropoff_datetime,
  trip_distance,
  avgMPH
FROM validTrips
WHERE avgMPH<120
ORDER BY avgMPH DESC
LIMIT 1;

-- Filters applied to remove unrealistic or erroneous trips:
-- - Non-null timestamps
-- - Positive distance
-- - Duration > 15 minutes
-- - Passenger count > 0
-- - Distance < 100 miles
-- - Speed < 120 mph

--Insight:
--Identifies any outlier data that may skew analytics based on trip distance and speed



