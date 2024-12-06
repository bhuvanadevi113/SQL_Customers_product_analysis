SELECT *
  FROM products
 LIMIT 5;
/*
Database contains eight tables:
Customers - It has customer data
Employees- all employee information
Offices- sales office information
Orders- customers' sales orders
OrderDetails- sales order line for each sales order
Payments - customers' payment records
Products- a list of scale model cars
ProductLines- a list of product line categories
*/

show tables;

-- Identifying tables, it's attributes and its rows.

Select "customers" as table_name, 
(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS where table_name='customers') as number_of_attributes,
count(*) as number_of_rows 
from customers 

union all 

Select "employees" as table_name, 
(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS where table_name='employees') as number_of_attributes,
count(*) as number_of_rows 
from employees

union all

Select "offices" as table_name, 
(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS where table_name='offices') as number_of_attributes,
count(*) as number_of_rows 
from offices

Union all

Select "orderdetails" as table_name, 
(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS where table_name='orderdetails') as number_of_attributes,
count(*) as number_of_rows 
from orderdetails

Union all

Select "orders" as table_name, 
(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS where table_name='orders') as number_of_attributes,
count(*) as number_of_rows 
from orders

Union all

Select "payments" as table_name, 
(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS where table_name='payments') as number_of_attributes,
count(*) as number_of_rows 
from payments

Union all

Select "productlines" as table_name, 
(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS where table_name='productlines') as number_of_attributes,
count(*) as number_of_rows 
from productlines 

Union All
Select "products" as table_name, 
(SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS where table_name='products') as number_of_attributes,
count(*) as number_of_rows 
from products ;


--  low stock 

WITH 
low_stock_table AS (
SELECT productCode, ROUND(SUM(quantityOrdered)*1.0/(SELECT quantityInStock
                                                      FROM products AS p
                                                     WHERE p.productCode =   
                                                           o.productCode),2)
                                                        AS low_stock
  FROM orderdetails AS o 
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10
),

product_to_restock AS (
SELECT productCode, SUM(quantityOrdered*priceEach) AS product_performance
  FROM orderdetails
 WHERE productCode IN (SELECT productCode FROM low_stock_table)
 GROUP BY productCode
 ORDER BY product_performance DESC
 LIMIT 10
)

SELECT productCode,productName,productLine
  FROM products
 WHERE productCode IN (SELECT productCode FROM product_to_restock);
 
 --  Finding the VIP Customers - Top 5

WITH profit_per_customer_table AS (
SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON od.orderNumber = o.orderNumber
  JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY o.customerNumber)
 
 SELECT c.contactLastName, c.contactFirstName, c.city,
        c.country, ppct.profit
   FROM customers AS c
   JOIN profit_per_customer_table AS ppct
     ON c.customerNumber = ppct.customerNumber
  ORDER BY ppct.profit DESC
  LIMIT 5;
  
--  Finding the Less Engaged Customers - Top 5  
  
  WITH profit_per_customer_table AS (
SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON od.orderNumber = o.orderNumber
  JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY o.customerNumber)
 
 SELECT c.contactLastName, c.contactFirstName, c.city,
        c.country, ppct.profit
   FROM customers AS c
   JOIN profit_per_customer_table AS ppct
     ON c.customerNumber = ppct.customerNumber
  ORDER BY ppct.profit 
  LIMIT 5;
  
  
-- Customer Lifetime Value (LTV) Average
  
  WITH profit_per_customer_table AS (
SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON od.orderNumber = o.orderNumber
  JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY o.customerNumber)
 
 SELECT AVG(ppct.profit) AS "The Average of (LTV)"
   FROM profit_per_customer_table AS ppct;