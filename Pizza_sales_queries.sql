create database pizzahut;

select * from pizzahut.orders;
select * from pizzahut.pizzas;
select * from pizzahut.order_details;
select * from pizzahut.pizza_types;

#Basic:
#1.Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    pizzahut.orders;


#2.Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS Total_Revenue
FROM
    pizzahut.pizzas p
        JOIN
    pizzahut.order_details o ON p.pizza_id = o.pizza_id;


#3.Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizzahut.pizzas p
        JOIN
    pizzahut.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

#4.Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(od.quantity) AS count_orders
FROM
    pizzahut.pizzas p
        JOIN
    pizzahut.order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY count_orders DESC
LIMIT 1;

#5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) AS quantities
FROM
    pizzahut.pizzas p
        JOIN
    pizzahut.order_details od ON p.pizza_id = od.pizza_id
        JOIN
    pizzahut.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY quantities DESC
LIMIT 5;



                               -- Intermediate:
                               
                               
-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category AS pizza_category,
    SUM(od.quantity) AS total_quantity
FROM
    pizzahut.order_details od
        JOIN
    pizzahut.pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizzahut.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour,
    COUNT(order_id) AS distribution_of_orders
FROM
    pizzahut.orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id) AS pizzas
FROM
    pizzahut.pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        pizzahut.orders o
    JOIN pizzahut.order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;



-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.pizza_type_id,
    pt.name,
    SUM(od.quantity * p.price) AS Total_revenue
FROM
    pizzahut.pizza_types pt
        JOIN
    pizzahut.pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    pizzahut.order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.pizza_type_id , pt.name
ORDER BY total_revenue DESC
LIMIT 3;



										-- Advanced:
                                        
                                        
-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    CONCAT(ROUND((SUM(od.quantity * p.price) / (SELECT 
                            ROUND(SUM(o.quantity * p.price), 2) AS Total_Revenue
                        FROM
                            pizzahut.pizzas p
                                JOIN
                            pizzahut.order_details o ON p.pizza_id = o.pizza_id)) * 100,
                    2),
            '%') AS revenue
FROM
    pizzahut.pizza_types pt
        JOIN
    pizzahut.pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    pizzahut.order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;


#### total revenue 
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS Total_Revenue
FROM
    pizzahut.pizzas p
        JOIN
    pizzahut.order_details o ON p.pizza_id = o.pizza_id;
    
    
    
-- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over(order by order_date) as cum_revenue
from
(
select o.order_date, sum(od.quantity*p.price) as revenue
from pizzahut.orders o 
join pizzahut.order_details od 
on o.order_id=od.order_id
join pizzahut.pizzas p 
on od.pizza_id=p.pizza_id
group by o.order_date) as Sales;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name,revenue
from 
(select category,name,revenue,
rank() over( partition by category order by revenue desc) as rn 
from
(select pt.category,pt.name,sum(od.quantity*p.price) as revenue
from pizzahut.pizza_types pt 
join pizzahut.pizzas p 
on pt.pizza_type_id=p.pizza_type_id
join pizzahut.order_details od 
on od.pizza_id=p.pizza_id
group by pt.category,pt.name) as a) as b
where rn<=3;

                         #-----------OR-------------

with cte as(
select pt.category,pt.name,sum(od.quantity*p.price) as revenue,
rank() over( partition by category order by sum(od.quantity*p.price) desc) as rn 
from pizzahut.pizza_types pt 
join pizzahut.pizzas p 
on pt.pizza_type_id=p.pizza_type_id
join pizzahut.order_details od 
on od.pizza_id=p.pizza_id
group by pt.category,pt.name
) 
select category,name,revenue
from cte 
where rn<=3