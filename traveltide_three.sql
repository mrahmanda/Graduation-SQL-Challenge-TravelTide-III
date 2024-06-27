/*
Question #1:
Calculate the number of flights with a departure time during the work week (Monday through Friday) and the number of flights departing during the weekend (Saturday or Sunday).

Expected column names: working_cnt, weekend_cnt
*/

-- q1 solution:

SELECT
    SUM(CASE WHEN TO_CHAR(departure_time, 'Dy') IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri') THEN 1 ELSE 0 END) AS working_cnt,
    SUM(CASE WHEN TO_CHAR(departure_time, 'Dy') IN ('Sat', 'Sun') THEN 1 ELSE 0 END) AS weekend_cnt
    
FROMgit
    flights;


/*

Question #2: 
For users that have booked at least 2  trips with a hotel discount, it is possible to calculate their average hotel discount, and maximum hotel discount. write a solution to find users whose maximum hotel discount is strictly greater than the max average discount across all users.

Expected column names: user_id

*/

-- q2 solution:

WITH 
user_hotel_discounts AS (
    SELECT
        user_id,
        COUNT(DISTINCT trip_id) AS num_trips, -- num of trips per user
        MAX(hotel_discount_amount) AS max_hotel_discount, --Maximum hotel disc per user
        AVG(hotel_discount_amount) AS avg_hotel_discount --Average hotel disc per user
  
    FROM sessions
    WHERE hotel_discount = TRUE AND cancellation = FALSE AND trip_id IS NOT NULL
    GROUP BY user_id
    HAVING COUNT(DISTINCT trip_id) >= 2 -- to get the users with atleast 2 trips
)

SELECT user_id
FROM user_hotel_discounts
WHERE max_hotel_discount > (SELECT MAX(avg_hotel_discount) FROM user_hotel_discounts) -- Sub query to get the Maximum Average hotel disc among all user
;


/*
Question #3: 
when a customer passes through an airport we count this as one “service”.

for example:

suppose a group of 3 people book a flight from LAX to SFO with return flights. In this case the number of services for each airport is as follows:

3 services when the travelers depart from LAX

3 services when they arrive at SFO

3 services when they depart from SFO

3 services when they arrive home at LAX

for a total of 6 services each for LAX and SFO.

find the airport with the most services.

Expected column names: airport

*/

-- q3 solution:


--CTE to calculate total services for all Airports (Origin & Destination) based return flights & Seat bookings.
WITH 
temp_airport_services AS (
    SELECT origin_airport AS airport, 
  	CASE 
        WHEN return_flight_booked = TRUE
        THEN COUNT(*) * 2 * seats        -- Multiplied by 2 for return flights and seats to be considered separately
        WHEN return_flight_booked = FALSE
  			THEN COUNT(*) * seats 
        END AS services
  
    FROM flights
    GROUP BY origin_airport, return_flight_booked, seats
  
    UNION ALL 
  
    SELECT destination_airport AS airport, 
  	CASE 
        WHEN return_flight_booked = TRUE
        THEN COUNT(*) * 2 * seats
        WHEN return_flight_booked = FALSE
  			THEN COUNT(*) * seats 
        END AS services
  
    FROM flights
    GROUP BY destination_airport, return_flight_booked, seats
),

temp_airport AS (

    SELECT airport, SUM(services) AS total_services
    FROM temp_airport_services
    GROUP BY airport
)

SELECT airport

FROM temp_airport

GROUP BY airport, total_services

HAVING total_services = (SELECT MAX(total_services) from temp_airport)

--LIMIT 1 -- To get the Airport with Top most services
;



with cte0 as 
( 
    select origin_airport as airport, 
        sum(seats) + sum(seats*return_flight_booked::int) as serviced 

from flights group by origin_airport 

union all 

    select destination_airport as airport, 
        sum(seats) + sum(seats*return_flight_booked::int) as serviced 

    from flights group by destination_airport 
), 

cte1 as ( 
    select airport, sum(serviced) as total_served 
    
    from cte0 group by airport 
) 

select airport from cte1 
where total_served = (select max(total_served) from cte1)
;

--select return_flight_booked::int AS number from flights
--where trip_id = '108316-3f71172917544023b424fff1f03cdc77'

/*
Question #4: 
using the definition of “services” provided in the previous question, we will now rank airports by total number of services. 

write a solution to report the rank of each airport as a percentage, where the rank as a percentage is computed using the following formula: 

`percent_rank = (airport_rank - 1) * 100 / (the_number_of_airports - 1)`

The percent rank should be rounded to 1 decimal place. airport rank is ascending, such that the airport with the least services is rank 1. If two airports have the same number of services, they also get the same rank.

Return by ascending order of rank

E**xpected column names: airport, percent_rank**

Expected column names: airport, percent_rank
*/

-- q4 solution:


--CTE to calculate total services for all Airports (Origin & Destination) based return flights & Seat bookings.
WITH
temp_airport_services AS (
    SELECT origin_airport AS airport, 
           CASE 
               WHEN return_flight_booked = TRUE 
  						 THEN COUNT(*) * 2 * seats       -- Multiplied by 2 for return flights and seats to considered separately
               ELSE COUNT(*) * seats
           		 END AS services
    FROM flights
    GROUP BY origin_airport, return_flight_booked, seats

    UNION ALL

    SELECT destination_airport AS airport, 
           CASE 
               WHEN return_flight_booked = TRUE 
  						 THEN COUNT(*) * 2 * seats 
               ELSE COUNT(*) * seats
           		 END AS services
  
    FROM flights
    GROUP BY destination_airport, return_flight_booked, seats
),

--CTE to report the rank of each airport as a percentage & Return by ascending order of rank to the services
temp_ranked_airports AS (
    SELECT airport, 
           SUM(services) AS total_services,
           PERCENT_RANK() OVER (ORDER BY SUM(services) ASC)::NUMERIC AS percent_rank -- Window function to rank and replace the given formula in the question
  	
    FROM temp_airport_services
    GROUP BY airport
)

SELECT airport, 
			 ROUND(percent_rank * 100, 1) AS percent_rank -- Multiply by 100 to get as percentage
       
FROM temp_ranked_airports
ORDER BY percent_rank
;





------


--CTE to calculate total services for all Airports (Origin & Destination) based return flights & Seat bookings.
WITH
temp_airport_services AS (
    SELECT origin_airport AS airport, 
           CASE 
               WHEN return_flight_booked = TRUE 
  						 THEN 2 * seats       -- Multiplied by 2 for return flights and seats to considered separately
               ELSE seats
           		 END AS services
    FROM flights
    GROUP BY origin_airport, return_flight_booked, seats

    UNION ALL

    SELECT destination_airport AS airport, 
           CASE 
               WHEN return_flight_booked = TRUE 
  						 THEN 2 * seats 
               ELSE seats
           		 END AS services
  
    FROM flights
    GROUP BY destination_airport, return_flight_booked, seats
)

    SELECT airport, 
           -- SUM(services) AS total_services,
           ROUND(((PERCENT_RANK() OVER (ORDER BY SUM(services) ASC)::NUMERIC) * 100), 1) AS percent_rank -- Window function to rank and replace the given formula in the question
  	
    FROM temp_airport_services
    GROUP BY airport
    ORDER BY percent_rank
    ;




---
SELECT airport, 
			 ROUND(percent_rank * 100, 1) AS percent_rank -- Multiply by 100 to get as percentage
       
FROM temp_ranked_airports
ORDER BY percent_rank
;