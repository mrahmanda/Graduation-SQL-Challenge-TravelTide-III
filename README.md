# Graduation-SQL-Challenge-TravelTide-III

## SQL Challenge: TravelTide III 

☝️
### Challenge
TravelTide is an online booking platform for travel, specializing in discount airplane tickets and hotel accommodations.


## Question #1: 
Calculate the number of flights with a departure time during the work week (Monday through Friday) and the number of flights departing during the weekend (Saturday or Sunday).


Expected column names: working_cnt, weekend_cnt
💡


## Question #2: 
For users that have booked at least 2  trips with a hotel discount, it is possible to calculate their average hotel discount, and maximum hotel discount. write a solution to find users whose maximum hotel discount is strictly greater than the max average discount across all users.

Expected column names: user_id
💡


## Question #3: 
When a customer passes through an airport we count this as one “service”. 
For example:

Suppose a group of 3 people book a flight from LAX to SFO with return flights. In this case the number of services for each airport is as follows:

3 services when the travelers depart from LAX

3 services when they arrive at SFO

3 services when they depart from SFO

3 services when they arrive home at LAX

For a total of 6 services each for LAX and SFO.

Find the airport with the most services.


Expected column names: airport

💡


## Question #4: 
Using the definition of “services” provided in the previous question, we will now rank airports by total number of services. 

Write a solution to report the rank of each airport as a percentage, where the rank as a percentage is computed using the following formula: 

percent_rank = (airport_rank - 1) * 100 / (the_number_of_airports - 1)

The percent rank should be rounded to 1 decimal place. airport rank is ascending, such that the airport with the least services is rank 1. If two airports have the same number of services, they also get the same rank.

Return by ascending order of rank

Expected column names: airport, percent_rank
