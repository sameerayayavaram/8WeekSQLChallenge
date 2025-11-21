/* --------------------
   Case Study Questions
   --------------------*/

-- 1. How many pizzas were ordered?

SELECT
COUNT(*) AS order_count
FROM customer_orders_clean;

-- 2. How many unique customer orders were made?

SELECT
COUNT(DISTINCT order_id) AS unique_order_count
FROM customer_orders_clean;

-- 3. How many successful orders were delivered by each runner?

SELECT
runner_id,
COUNT(*) as order_count
FROM runner_orders_clean
WHERE distance != 0
GROUP BY runner_id
ORDER BY runner_id;

-- 4. How many of each type of pizza was delivered?

SELECT
pizza_name,
COUNT(*) as order_count
FROM customer_orders_clean
JOIN runner_orders_clean ON customer_orders_clean.order_id = runner_orders_clean.order_id
JOIN pizza_names ON customer_orders_clean.pizza_id = pizza_names.pizza_id
WHERE distance != 0
GROUP BY pizza_name
ORDER BY pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
customer_id,
pizza_name,
COUNT(customer_orders_clean.pizza_id) as pizza_count
FROM customer_orders_clean
JOIN pizza_names ON customer_orders_clean.pizza_id = pizza_names.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT
customer_orders_clean.order_id,
COUNT(*) AS pizza_count
FROM customer_orders_clean
JOIN runner_orders_clean ON customer_orders_clean.order_id = runner_orders_clean.order_id
WHERE distance != 0
GROUP BY customer_orders_clean.order_id
ORDER BY pizza_count DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
customer_orders_clean.customer_id,
SUM(
	CASE WHEN customer_orders_clean.exclusions is not NULL OR customer_orders_clean.extras is not NULL THEN 1
  	ELSE 0
  	END) AS at_least_1_change,
SUM(
  	CASE WHEN customer_orders_clean.exclusions is NULL AND customer_orders_clean.extras is NULL THEN 1
  	ELSE 0
  	END) AS no_change
FROM customer_orders_clean
JOIN runner_orders_clean ON customer_orders_clean.order_id = runner_orders_clean.order_id
WHERE cancellation is NULL
GROUP BY customer_orders_clean.customer_id
ORDER BY customer_orders_clean.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT 
COUNT(*) as changed_pizzas
FROM customer_orders_clean
JOIN runner_orders_clean ON customer_orders_clean.order_id = runner_orders_clean.order_id
WHERE cancellation is NULL AND customer_orders_clean.exclusions is not NULL AND customer_orders_clean.extras is not NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
EXTRACT(HOUR FROM order_time) AS hour_of_the_day,
COUNT(*) AS total_pizzas
FROM customer_orders_clean
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day;

-- 10. What was the volume of orders for each day of the week?

SELECT 
TO_CHAR(order_time,'Day') AS day_of_the_week,
COUNT(*) AS total_pizzas
FROM customer_orders_clean
GROUP BY day_of_the_week
ORDER BY day_of_the_week;
