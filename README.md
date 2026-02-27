# NYC Green Taxi Trip Analysis (2014)

## Project Overview
This project analyzes New York City Green Taxi trips in 2014 using BigQuery. The goal is to uncover insights about **demand patterns, revenue drivers, rider behavior, and operational performance**, demonstrating SQL skills applied to real-world data.

## Skills Demonstrated
- **SQL Querying:** Aggregations, joins, window functions, CASE statements, approximate statistics.
- **Data Modeling:** Understanding table relationships, handling nulls, cleaning and validating data.
- **Analytical Thinking:** Translating business questions into actionable queries and insights.
- **Operational Insights:** Identifying patterns to inform staffing, fleet allocation, and pricing strategies.


## Business Insights
- High-demand pickup locations are concentrated in business districts and transit hubs, guiding driver allocation.
- Trip volume peaks during morning and evening commute hours, highlighting opportunities for surge pricing and optimized scheduling.
- Most trips are short (under 5 miles) and single-passenger, informing fleet composition and routing efficiency.
- Long-distance trips and certain boroughs contribute disproportionately to revenue, guiding pricing strategy and resource allocation.
- Median fares vary by payment type, providing insight into customer behavior and fare modeling.
- Data cleaning is crucial: outliers in trip duration, distance, and passenger count can skew operational analysis.

## Tools & Data
- **Platform:** Google BigQuery (Standard SQL)
- **Dataset:** `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
- **Additional Resources:** `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom`
