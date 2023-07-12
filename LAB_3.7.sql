USE SAKILA;
-- 1 Get number of monthly active customers.
select COUNT(distinct(customer_id)) AS Customer_counts, date_format(rental_date, '%M') AS M, 
date_format(rental_date, '%Y') AS Y 
from rental
group by M, Y;

-- 2 Active users in the previous month.
create or replace view active_customer as
select customer_id, convert(rental_date, date) as Activity_date,
date_format(convert(rental_date,date), '%M') as Activity_Month,
date_format(convert(rental_date,date), '%m') as Activity_Month_number,
date_format(convert(rental_date,date), '%Y') as Activity_year
from sakila.rental;

-- Checking the results
select * from sakila.active_customer;

-- Step 2: Computing the total number of active users by Year and Month with group by 
-- and sorting according to year and month NUMBER.

select Activity_year, Activity_Month_number, count(customer_id) as Active_customers from sakila.active_customer
group by Activity_year, Activity_Month_number
order by Activity_year asc, Activity_Month_number asc;

-- Step 3: Storing the results on a view for later use.

create view sakila.monthly_active_customers as
select 
   Activity_year, 
   Activity_Month_number, 
   count(customer_id) as Active_users 
from sakila.active_customer
group by Activity_year, Activity_Month_number
order by Activity_year asc, Activity_Month_number asc;

select * from monthly_active_customers;

# for each year using the lag function with lag = 1 (as we want the lag from one previous record)

create view sakila.calculate_percentage as
select 
   Activity_year, 
   Activity_Month_number,
   Active_users, 
   lag(Active_users,1) over (order by Activity_year, Activity_Month_number) as Last_month
from monthly_active_customers;

select * from calculate_percentage;

-- 3 Percentage change in the number of active customers.
select ROUND((Active_users/Last_month * 100), 2) AS Percentage_change from calculate_percentage;

-- 4 Retained customers every month.
select 
   Activity_year, 
   Activity_Month_number,  
   (Active_users - Last_month) as Retained_customers 
from calculate_percentage;