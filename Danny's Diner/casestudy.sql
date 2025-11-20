/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
customer_id,
SUM(menu.price) as total_amount
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id ASC;

-- 2. How many days has each customer visited the restaurant?

SELECT 
customer_id,
COUNT(DISTINCT sales.order_date) as days
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH orders AS (
  SELECT
  sales.customer_id,
  sales.order_date,
  menu.product_name,
  DENSE_RANK() OVER (
    PARTITION BY sales.customer_id
    ORDER BY sales.order_date) as rank
  FROM sales
  JOIN menu ON sales.product_id = menu.product_id
) 
SELECT
customer_id,
product_name
FROM orders
WHERE rank = 1
GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
product_name,
COUNT(sales.product_id) as times_purchased
FROM menu
JOIN sales ON menu.product_id = sales.product_id
GROUP BY menu.product_name
ORDER BY times_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH most_popular AS (
  SELECT
  sales.customer_id,
  menu.product_name,
  COUNT(*) as order_count,
  DENSE_RANK() OVER (
	PARTITION BY sales.customer_id
  	ORDER BY COUNT(*) DESC) as rank
  FROM sales
  JOIN menu ON sales.product_id = menu.product_id
  GROUP BY sales.customer_id, menu.product_name
)
SELECT
  customer_id, 
  product_name,
  order_count
FROM most_popular
WHERE rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH member_orders AS (
SELECT
	sales.customer_id, 
    sales.product_id,
    --sales.order_date,
    RANK() OVER (
      PARTITION BY sales.customer_id
      ORDER BY sales.order_date ASC) as rank
FROM sales
JOIN members ON sales.customer_id = members.customer_id
WHERE sales.order_date >= members.join_date
)
SELECT
	customer_id,
    product_name
FROM member_orders
JOIN menu ON member_orders.product_id = menu.product_id
WHERE rank = 1
ORDER BY customer_id;

-- 7. Which item was purchased just before the customer became a member?

WITH nonmember_orders AS (
  SELECT
	sales.customer_id, 
  	sales.product_id, 
  	sales.order_date, 
  	RANK() OVER (
      PARTITION BY sales.customer_id
      ORDER BY sales.order_date DESC) as rank
  FROM sales
  JOIN members ON sales.customer_id = members.customer_id
  WHERE sales.order_date < members.join_date
)
SELECT
	customer_id, 
    product_name
FROM nonmember_orders
JOIN menu ON nonmember_orders.product_id = menu.product_id
WHERE rank = 1
ORDER BY customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
sales.customer_id,
COUNT(sales.product_id) as total_items,
SUM(menu.price) as total_amount  
FROM sales
JOIN members ON sales.customer_id = members.customer_id
AND sales.order_date < members.join_date
JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
sales.customer_id,
SUM(
CASE 
  WHEN menu.product_name = 'sushi' THEN menu.price*2*10
  ELSE menu.price*10
  END 
  ) AS points
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT
sales.customer_id,
SUM(
  CASE
  	WHEN sales.order_date BETWEEN members.join_date AND members.join_date+6 THEN menu.price*2*10
  	WHEN menu.product_name = 'sushi' THEN menu.price*2*10
  	ELSE menu.price*10
  END
  ) AS total_points
FROM sales
JOIN menu ON sales.product_id = menu.product_id
JOIN members ON sales.customer_id = members.customer_id
WHERE sales.order_date <= '2021-01-31'
GROUP BY sales.customer_id
ORDER BY sales.customer_id;
