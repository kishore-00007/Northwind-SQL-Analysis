USE Northwind;

-- 1. Calculate Total Sales for all orders
-- Total sales is typically calculated as (unitPrice * quantity) for each order detail.
SELECT
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalRevenue
FROM
    OrderDetail od;

-- 2. Calculate the Average Order Value
-- Average order value is Total Revenue / Number of unique orders
SELECT
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) / COUNT(DISTINCT od.orderId) AS AverageOrderValue
FROM
    OrderDetail od;

-- 3. Total Sales by Product Category
-- This requires joining OrderDetail, Product, and Category tables.
SELECT
    c.categoryName,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    OrderDetail od
INNER JOIN
    Product p ON od.productId = p.productId
INNER JOIN
    Category c ON p.categoryId = c.categoryId
GROUP BY
    c.categoryName
ORDER BY
    TotalSales DESC;

-- 4. Total Sales by Product
-- Identify the top-selling products.
SELECT
    p.productName,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    OrderDetail od
INNER JOIN
    Product p ON od.productId = p.productId
GROUP BY
    p.productName
ORDER BY
    TotalSales DESC
LIMIT 10; -- Show top 10 products

-- 5. Total Sales by Customer
-- Identify your most valuable customers.
SELECT
    cust.companyName AS CustomerName,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    OrderDetail od
INNER JOIN
    SalesOrder so ON od.orderId = so.orderId
INNER JOIN
    Customer cust ON so.custId = cust.custId
GROUP BY
    cust.companyName
ORDER BY
    TotalSales DESC
LIMIT 10; -- Show top 10 customers

-- 6. Total Sales by Employee
-- Evaluate individual employee performance.
SELECT
    e.firstName,
    e.lastName,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    OrderDetail od
INNER JOIN
    SalesOrder so ON od.orderId = so.orderId
INNER JOIN
    Employee e ON so.employeeId = e.employeeId
GROUP BY
    e.firstName, e.lastName
ORDER BY
    TotalSales DESC;
