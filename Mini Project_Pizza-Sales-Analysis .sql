create database pizza_db;
use pizza_db;
show tables;

select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

# if i want a pizza having red onion
select  * from pizza_types where ingredients like "% red onion%";

# MINI Project
-- Basic: 
-- 1. Retrieve the total number of orders placed. 
-- Objective: Understand the total volume of orders.
-- Total number of orders placed
select count(distinct order_id) as total_orders
from orders;

-- 2. Calculate the total revenue generated from pizza sales. 
-- Objective: Calculate the total revenue generated from all pizza orders.
select round(sum(o.quantity * p.price),2) "Total Sales" from order_details  o
join pizzas  p
 on p.pizza_id = o.pizza_id;
 
-- 3. Identify the highest-priced pizza. 
-- Objective: Find out which pizza is the most expensive.
select pt.name, p.price
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
order by p.price desc
limit 1;

-- 4. Identify the most common pizza size ordered. 
-- Objective: Determine which pizza size (e.g., small, medium, large) is ordered the most. 
select p.size, sum(od.quantity) as total_ordered
from order_details od
join pizzas p
on od.pizza_id = p.pizza_id
group by p.size
order by total_ordered desc limit 1;

-- 5. List the top 5 most ordered pizza types along with their quantities. 
-- Objective: ind out which pizza types are most frequently ordered.
 select p.pizza_type_id, sum(od.quantity) as most_ordered_type
 from pizza_types pt
 join pizzas p 
 on p.pizza_type_id = pt.pizza_type_id
 join order_details od
 on p.pizza_id = od.pizza_id
 group by p.pizza_type_id
 order by most_ordered_type desc limit 5 ;
 
-- Intermediate: 
-- 1. Join the necessary tables to find the total quantity of each pizza category ordered. 
-- Objective: Explore the relationship between pizza categories and quantities ordered. 
select pt.category, sum(od.quantity) as Total_Quantity
from order_details od
join pizzas p
on od.pizza_id = p.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.category;

-- 2. Determine the distribution of orders by hour of the day. 
-- Objective: Analyze how orders are distributed across different times of day.
SELECT HOUR(o.time) AS Hours_of_Day, COUNT(*) AS TotalOrders
FROM orders o
GROUP BY Hours_of_Day
ORDER BY Hours_of_Day;

-- 3. Join relevant tables to find the category-wise distribution of pizzas. 
-- Objective: Find out how pizzas from different categories are ordered. 
select pt.category, (sum(od.quantity)) as Total_orders
from order_details od
join pizzas p
on p.pizza_id = od.pizza_id
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id
group by pt.category
order by Total_orders;

-- 4. Group the orders by date and calculate the average number of pizzas ordered per day. 
-- Objective: Analyze daily order trends and average quantities. 
select o.date, avg(od.quantity) as avg_order_per_day
from orders o
join order_details od 
on o.order_id = od.order_id
group by o.date ;

-- 5. Determine the top 3 most ordered pizza types based on revenue. 
-- Objective: Identify the pizza types that generated the most revenue. 
select pt.pizza_type_id, sum(od.quantity * p.price) as Total_revenue
from pizzas p 
join pizza_types pt
on  p.pizza_type_id = pt.pizza_type_id
join order_details od 
on p.pizza_id = od.pizza_id
group by pt.pizza_type_id
order by Total_revenue desc limit 3;

-- Advanced: 
-- 1. Calculate the percentage contribution of each pizza type to total revenue. 
-- Objective: Understand each pizza's contribution to overall sales. 
SELECT pt.pizza_type_id,
    (SUM(od.quantity * p.price) / SUM(SUM(od.quantity * p.price)) OVER ()) * 100 
AS Percentage_Contribution
FROM order_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.pizza_type_id
ORDER BY Percentage_Contribution DESC;


-- 2. Analyze the cumulative revenue generated over time. 
-- Objective: Track how revenue accumulates over time. 

SELECT DATE(o.date) AS order_day,
  SUM(od.quantity * p.price) AS daily_revenue,
  SUM(SUM(od.quantity * p.price)) OVER (ORDER BY DATE(o.date)) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON p.pizza_id = od.pizza_id
GROUP BY DATE(o.date)
ORDER BY DATE(o.date);

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category. 
-- Objective: Find the highest-grossing pizzas within each category. 
SELECT category, name AS pizza_name, revenue
FROM (SELECT pt.category,pt.name,SUM(od.quantity * p.price) AS revenue,
ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank_in_category
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name) t
WHERE rank_in_category <= 3
ORDER BY category, revenue DESC;
