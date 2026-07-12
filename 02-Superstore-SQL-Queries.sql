Create Database salesproject;
Use salesproject;
Show Tables;
Describe salesproject;

CREATE TABLE salesproject  (
    row_id INT,
    order_id TEXT,
    order_date date,
    ship_date date,
    ship_mode TEXT,
    customer_id TEXT,
    segment TEXT,
    country TEXT,
    city TEXT,
    state TEXT,
    region TEXT,
    product_id TEXT,
    category TEXT,
    sub_category TEXT,
    product_name TEXT,
    sales DOUBLE,
    quantity INT,
    discount DOUBLE,
    profit DOUBLE
);

LOAD DATA LOCAL INFILE "C:/Users/Admin/Downloads/Salesproject.csv"
INTO TABLE salesproject
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT* FROM salesproject;

SELECT* FROM salesproject LIMIT 10;

-- 1) Overall Business Performance : 

SELECT count(*) as Total_orders,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit
FROM salesproject;

-- 2) Category Performance :

SELECT category,
sum(sales) AS total_sales,
SUM(profit) AS total_profit
FROM salesproject
GROUP BY category;

-- 3) Sales by Region :

SELECT region,
SUM(sales) AS Total_sales
FROM salesproject
GROUP BY region
ORDER BY Total_sales DESC;

-- 4) Discount Impact :

SELECT discount,
SUM(profit) AS total_profit
FROM salesproject
GROUP BY discount
ORDER BY discount;

-- 5) Top Customers (Revenue) :

SELECT
Customer_id,
SUM(sales) AS total_sales
FROM salesproject
GROUP BY Customer_id
ORDER BY SUM(sales) DESC
LIMIT 10;

-- 6) Top Loss Making Products (Sales) :

SELECT product_name,
SUM(profit) AS total_loss
FROM salesproject
GROUP BY product_name
ORDER BY total_loss ASC
LIMIT 10 ;

-- 7) Category-Wise Profit Margin :

SELECT category,
ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM salesproject
GROUP BY category;

-- 8) Monthly Sales Growth :

SELECT date_format(order_date,'%y-%m') AS month,
ROUND(SUM(sales),2) AS total_sales
FROM salesproject
GROUP BY month
ORDER BY month;

-- 9) Repeat vs New Customers:

SELECT customer_id,count(order_id) AS order_count
FROM salesproject
GROUP BY customer_id
HAVING order_count>1;

-- 10) REPEAT VS NEW CUSTOMERS (ADVANCED) :
SELECT customer_type,count(*) AS total_customers
FROM(SELECT customer_id,
CASE WHEN count(order_id) <=1 THEN "new "
ELSE "repeat"
END AS customer_type
FROM salesproject
GROUP BY customer_id)t
GROUP BY customer_type;

-- 11) CUSTOMER LIFETIME VALUE :

SELECT customer_id,
SUM(sales) AS total_spent,
SUM(profit) AS total_profit
FROM salesproject
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10; 

-- 12) Sales Contribution % By Category :

SELECT category,
ROUND(SUM(sales)*100/( SELECT SUM(sales) 
FROM salesproject),2) AS contribution_pct
FROM salesproject
GROUP BY category;

-- 13) Average Delivery Time By Ship Mode :

SELECT ship_mode,
ROUND(AVG(datediff(ship_date,order_date)),2) AS avg_delivery_days
FROM salesproject
GROUP BY ship_mode;

-- 14) Find Second Highest Salary :

 SELECT MAX(sales) AS SECOND_HIGHEST
FROM salesproject
WHERE sales < (SELECT MAX(sales) FROM salesproject);
    
-- 15) Find customers whose total sales are above the average customer sales.

WITH customer_sales AS (
    SELECT customer_id,
           SUM(sales) AS total_sales
    FROM salesproject
    GROUP BY customer_id
)
SELECT *
FROM customer_sales
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM customer_sales
);

-- 16) find categories whose total sales are above the average category sales :

WITH category_sales AS (
    SELECT category,
           SUM(sales) AS total_sales
    FROM salesproject
    GROUP BY category
)
SELECT *
FROM category_sales
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM category_sales
);

-- 17) Show Products whose Total Sales Are Greater Than 
-- Avg Total Sales of All Products :

 SELECT product_name,
       SUM(sales) AS total_sales
FROM salesproject
GROUP BY product_name
HAVING SUM(sales) >
(
    SELECT AVG(total_sales)
    FROM
    (
        SELECT SUM(sales) AS total_sales
        FROM salesproject
        GROUP BY product_name
    ) AS avg_sales
);

 
-- 18) Find Top 3 Customers By Sales :

SELECT * FROM(SELECT customer_id,
sum(sales) AS total_sales,
RANK() OVER (ORDER BY SUM(sales) DESC) AS Rnk
FROM salesproject
GROUP BY customer_id)t
WHERE Rnk<=3;

-- 19) Find Top Product in Each Category By Sales :

SELECT* FROM (SELECT category,product_name,
SUM(sales) AS total_sales,
RANK() OVER (PARTITION BY category ORDER BY SUM(sales) DESC) AS Rnk
FROM salesproject
GROUP BY category,product_name
)t
WHERE Rnk=1;

-- 20) Find Running Total Sales By Month
SELECT DATE_FORMAT(order_date,"%y-%m") AS MONTH,
ROUND(SUM(sales),2) AS monthly_sales,
ROUND(SUM(SUM(sales)) OVER (ORDER BY DATE_FORMAT(order_date,"%y-%m")),2) AS Running_total
FROM salesproject
GROUP BY DATE_FORMAT(order_date,"%y-%m"); 




