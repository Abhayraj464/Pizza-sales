use pizza_shop;

-- 1. Retrieve the total number of orders placed. 

select count(order_id) as Total_number_of_order_placed from order_details;

-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
    
    -- 3. Identify the highest-priced pizza.
    
    SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


 -- 4. Identify the most common pizza size ordered.
 
 SELECT 
    pizzas.size , count(order_details.order_details_id) as pizza_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    group by  pizzas.size
    order by pizza_ordered desc limit 1;
    
    
    -- 5. List the top 5 most ordered pizza types along with their quantities.
    
    SELECT 
    pizza_types.name, sum(order_details.quantity) as quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    group by pizza_types.name
    order by quantity desc limit 5;
    
    
    -- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
    
    select pizza_types.category, sum(order_details.quantity) as quantity from pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    group by pizza_types.category
    order by quantity desc;
    
    
    -- 7. Determine the distribution of orders by hour of the day. 
    
    select hour(order_time) as hour, count(order_id) as order_count from orders
    group by hour;
    
    
    -- 8. Join relevant tables to find the category-wise distribution of pizzas.
    
    select category, count(name) as distribution_count from pizza_types
    group by category;
    
   -- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
  
  
  select round(avg(quantity),0) from
   ( SELECT 
    orders.order_date, sum(order_details.quantity) as quantity
FROM
    order_details
        JOIN
    orders ON order_details.order_id = orders.order_id
    group by orders.order_date) as order_quantity;
    
    
    -- 10. Determine the top 3 most ordered pizza types based on revenue.
   
   
   select pizza_types.name,sum(order_details.quantity * pizzas.price) as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    group by pizza_types.name
    order by revenue desc limit 3; 
    
    
    
    -- 11. Calculate the percentage contribution of each pizza type to total revenue.
    
    SELECT 
    pizza_types.category,
    round((sum(order_details.quantity * pizzas.price) / (select round(sum(order_details.quantity * pizzas.price),2) as total_sales 
    from 
    order_details join pizzas on order_details.pizza_id = pizzas.pizza_id) *100),2) as percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    group by pizza_types.category
    order by percentage desc ;
    
    
    -- 12. Analyze the cumulative revenue generated over time.
    
   select order_date,
   round(sum(revenue) over(order by order_date),2) as cum_revenue
   from
   ( SELECT orders.order_date, 
    sum(order_details.quantity * pizzas.price) as revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    orders ON order_details.order_id = orders.order_id
    group by orders.order_date) as sales;
    
    
    
    -- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
    
  select category, name, revenue
  from
  ( select category, name, revenue,
   rank() over(partition by category order by revenue desc) as pizaa_ranking
   from
   (SELECT 
    pizza_types.category, pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    group by pizza_types.category,pizza_types.name) as pizza_revenue) as pizza_catg
    where pizaa_ranking <= 3;