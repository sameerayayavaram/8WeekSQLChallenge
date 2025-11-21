CREATE TABLE customer_orders_clean AS 
SELECT
order_id,
customer_id,
pizza_id, 
CASE 
WHEN exclusions = '' OR exclusions LIKE 'null' THEN NULL
ELSE exclusions
END AS exclusions,
CASE
WHEN extras = '' OR extras LIKE 'null' THEN NULL
ELSE extras
END AS extras,
order_time
FROM customer_orders;

CREATE TABLE runner_orders_clean AS
SELECT
order_id,
runner_id, 
CASE WHEN pickup_time in ('null','') THEN NULL 
ELSE pickup_time  :: TIMESTAMP
END AS pickup_time,
CASE WHEN distance in ('null','') THEN 0
ELSE TRIM('km' FROM distance)::NUMERIC
END AS distance,
CASE WHEN duration in ('null','') THEN 0
ELSE TRIM(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'mins',''),'minute',''))::INT
END AS duration,
CASE WHEN cancellation in ('null','') THEN NULL
ELSE cancellation
END AS cancellation
FROM runner_orders;
