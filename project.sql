-- TABLE DESCRIPTIONS

-- customers: customer data
SELECT 'customers' AS table_name,
       13 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM customers

UNION ALL

-- employees: all employee information
SELECT 'employees' AS table_name,
       8 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM employees

UNION ALL

-- offices: sales office information
SELECT 'offices' AS table_name,
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM offices

UNION ALL

-- orderDetails: sales order line for each sales order
SELECT 'orderDetails' AS table_name,
       5 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM orderDetails
  
UNION ALL

-- orders: customers' sales orders
SELECT 'orders' AS table_name,
       7 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM orders
  
UNION ALL

-- payments: customers' payment records
SELECT 'payments' AS table_name,
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM payments
  
UNION ALL

-- productLines: a list of product line categories
SELECT 'productLines' AS table_name,
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM productLines
  
UNION ALL

-- products: a list of scale model cars
SELECT 'products' AS table_name,
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM products;

-- Question 1: Which Products Should We Order More of or Less of?

SELECT productCode, 
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
                                                FROM products AS p
                                               WHERE od.productCode = p.productCode), 2) AS lowStock
  FROM orderdetails AS od
 GROUP BY productCode
 ORDER BY lowStock DESC
 LIMIT 10;

SELECT productCode,
       SUM(quantityOrdered * priceEach) AS prodPerformance
  FROM orderdetails AS od
 GROUP BY productCode  
 ORDER BY prodPerformance DESC
 LIMIT 10;

-- Question 1a: Which Products Should We Order More of?
-- Combine the previous two queries using a Common Table Expression CTE)

WITH 
lowStockTable AS (
SELECT productCode,
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
                                                FROM products AS p
                                               WHERE od.productCode = p.productCode), 2) AS lowStock
  FROM orderdetails AS od
 GROUP BY productCode
 ORDER BY lowStock DESC
 LIMIT 10
)
SELECT productCode, 
       SUM(quantityOrdered * priceEach) AS prodPerformance
  FROM orderdetails AS od
 WHERE productCode IN (SELECT productCode 
                         FROM lowStockTable)
 GROUP BY productCode  
 ORDER BY prodPerformance DESC
 LIMIT 10;

-- Low in Stock Products that are High Performing

WITH 
lowStockTable AS (
SELECT productCode,
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
                                                FROM products AS p
                                               WHERE od.productCode = p.productCode), 2) AS lowStock
  FROM orderdetails AS od
 GROUP BY productCode
 ORDER BY lowStock 
 LIMIT 10
)
SELECT productName AS highPerformingProducts, productLine
  FROM products AS p
 WHERE productCode IN ('S12_1099', 'S18_2795', 'S32_1374', 'S700_3167', 'S50_4713')
 GROUP BY productCode;

-- Question 1b: Which Products Should We Order Less of?

WITH 
lowStockTable AS (
SELECT productCode,
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
                                                FROM products AS p
                                               WHERE od.productCode = p.productCode), 2) AS lowStock
  FROM orderdetails AS od
 GROUP BY productCode
 ORDER BY lowStock 
 LIMIT 10
)
SELECT productCode, 
       SUM(quantityOrdered * priceEach) AS prodPerformance
  FROM orderdetails AS od
 WHERE productCode IN (SELECT productCode 
                         FROM lowStockTable)
 GROUP BY productCode  
 ORDER BY prodPerformance 
 LIMIT 10;

-- High in Stock Products that are Low Performing

WITH 
lowStockTable AS (
SELECT productCode,
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
                                                FROM products AS p
                                               WHERE od.productCode = p.productCode), 2) AS lowStock
  FROM orderdetails AS od
 GROUP BY productCode
 ORDER BY lowStock 
 LIMIT 10
)
SELECT productName AS lowPerformingProducts, productLine
  FROM products AS p
 WHERE productCode IN ('S32_2206', 'S24_3432', 'S700_2466', 'S12_3380', 'S18_2870')
 GROUP BY productCode;

-- Question 2a: How Should We Match Marketing and Communication Strategies to Customer Behavior?

SELECT o.customerNumber,
       ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)), 2) AS profit
  FROM products AS p
  JOIN orderdetails AS od
    ON p.productCode = od.productCode
  JOIN orders AS o
    ON od.orderNumber = o.orderNumber
 GROUP BY o.customerNumber
 ORDER BY profit DESC
 LIMIT 10;

-- Question 2b: Finding the VIP and Less Engaged Customers

WITH
profitTable AS (
SELECT o.customerNumber,
       ROUND(SUM(quantityOrdered * (priceEach - buyPrice)), 2) AS profit
  FROM products AS p
  JOIN orderdetails AS od
    ON p.productCode = od.productCode
  JOIN orders AS o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
 )
 SELECT contactLastName, 
        contactFirstName,
        city,
        country,
        pt.profit
   FROM customers AS c
   JOIN profitTable AS pt
     ON pt.customerNumber = c.customerNumber
  ORDER BY pt.profit DESC
  LIMIT 5;
 
WITH
profitTable AS (
SELECT o.customerNumber,
       ROUND(SUM(quantityOrdered * (priceEach - buyPrice)), 2) AS profit
  FROM products AS p
  JOIN orderdetails AS od
    ON p.productCode = od.productCode
  JOIN orders AS o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
 )
 SELECT contactLastName, 
        contactFirstName,
        city,
        country,
        pt.profit
   FROM customers AS c
   JOIN profitTable AS pt
     ON pt.customerNumber = c.customerNumber
  ORDER BY pt.profit 
  LIMIT 5;

-- Question 3: How Much Can We Spend on Acquiring New Customers?

WITH
profitTable AS (
SELECT o.customerNumber,
       ROUND(SUM(quantityOrdered * (priceEach - buyPrice)), 2) AS profit
  FROM products AS p
  JOIN orderdetails AS od
    ON p.productCode = od.productCode
  JOIN orders AS o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
 )
SELECT ROUND(AVG(pt.profit), 2) AS averageProfit
  FROM profitTable AS pt;

-- TABLE ASSOCIATIONS
-- customers.salesRepEmployeeNumber 
--    = employees.employeeNumber
-- employees.officeCode 
--    = offices.officeCode
-- customers.customerNumber 
--    = orders.customerNumber
--    = payments.customerNumber
-- orderdetails.orderNumber 
--    = orders.orderNumber
-- orderdetails.productCode
--    = products.productCode
-- productlines.productLine
--    = products.productLine