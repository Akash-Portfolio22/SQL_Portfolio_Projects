Create database Pizzahut;
Create Table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);
select * from orders;
select count(*) from orders;

Create Table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

Select * from order_details;
Select count(*) from order_details;

-- Retrieve the total number of orders placed.
select count(order_id) as Total_Orders from orders;

-- Calculate the total revenue generated from pizza sales.
select
Round(sum(order_details.quantity * pizzas.price), 2) as total_sales
from order_details
Join pizzas on
order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types.name, pizzas.price
from pizza_types
Join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price Desc limit 1;

-- Identify the most common pizza size ordered. 
select pizzas.size, count(order_details.order_details_id) as count_orders
from pizzas
Join order_details on
pizzas.pizza_id = order_details.pizza_id
Group by pizzas.size order by count_orders desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types
Join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on
pizzas.pizza_id = order_details.pizza_id
Group by pizza_types.name order by quantity Desc limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.quantity) as quantity
from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on
pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by quantity desc;

-- Determine the distribution of orders by hour of the day.
select * from orders;
select hour(order_time) as hour, count(order_id) as order_count
from orders
group by hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
select * from pizza_types;
select category, count(pizza_type_id)
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(pizzas_perday), 0) as pizzas_order_perday
from
(select orders.order_date, sum(order_details.quantity) as pizzas_perday
from orders
join order_details on
orders.order_id = order_details.order_id
group by orders.order_date) as pizzas_ordered;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on
order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category, Round((sum(order_details.quantity * pizzas.price)/(select sum(order_details.quantity * pizzas.price)
from order_details 
join pizzas on order_details.pizza_id = pizzas.pizza_id)) *100, 2) as revenue
from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on
order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
from order_details
join pizzas on
order_details.pizza_id = pizzas.pizza_id
join orders on
orders.order_id = order_details.order_id
group by orders.order_date order by revenue desc) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue, rn
from
(select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on
order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name order by revenue desc) as a) as b
where rn<=3;