USE Northwind;

-- 1. Customers who bought Product A AND Product B
-- (e.g., Customers who bought 'Chai' and 'Chang')
-- This requires finding customers who appear in order details for both products.
SELECT
    c.companyName AS CustomerName
FROM
    Customer c
INNER JOIN
    SalesOrder so ON c.custId = so.custId
INNER JOIN
    OrderDetail od ON so.orderId = od.orderId
INNER JOIN
    Product p ON od.productId = p.productId
WHERE
    p.productName = 'Chai'
INTERSECT -- Use INTERSECT to find common customers
SELECT
    c.companyName AS CustomerName
FROM
    Customer c
INNER JOIN
    SalesOrder so ON c.custId = so.custId
INNER JOIN
    OrderDetail od ON so.orderId = od.orderId
INNER JOIN
    Product p ON od.productId = p.productId
WHERE
    p.productName = 'Chang';

-- Note: MySQL does not natively support INTERSECT.
-- For MySQL, you would typically rewrite this using INNER JOIN with subqueries or GROUP BY/HAVING:
/*
SELECT
    c.companyName AS CustomerName
FROM
    Customer c
INNER JOIN
    SalesOrder so ON c.custId = so.custId
INNER JOIN
    OrderDetail od ON so.orderId = od.orderId
INNER JOIN
    Product p ON od.productId = p.productId
WHERE
    p.productName IN ('Chai', 'Chang')
GROUP BY
    c.companyName
HAVING
    COUNT(DISTINCT p.productName) = 2; -- Ensures both products were bought
*/

-- 2. Products with Sales Growth Year-over-Year (YOY)
-- Identify products that are increasing in popularity.
WITH ProductYearlySales AS (
    SELECT
        p.productName,
        YEAR(so.orderDate) AS SalesYear,
        SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS YearlySales
    FROM
        Product p
    INNER JOIN
        OrderDetail od ON p.productId = od.productId
    INNER JOIN
        SalesOrder so ON od.orderId = so.orderId
    GROUP BY
        p.productName, SalesYear
),
RankedProductSales AS (
    SELECT
        productName,
        SalesYear,
        YearlySales,
        LAG(YearlySales, 1, 0) OVER (PARTITION BY productName ORDER BY SalesYear) AS PreviousYearSales
    FROM
        ProductYearlySales
)
SELECT
    productName,
    SalesYear,
    YearlySales,
    PreviousYearSales,
    CASE
        WHEN PreviousYearSales = 0 THEN NULL -- Avoid division by zero for the first year
        ELSE ((YearlySales - PreviousYearSales) / PreviousYearSales) * 100
    END AS GrowthPercentage
FROM
    RankedProductSales
WHERE
    SalesYear > (SELECT MIN(SalesYear) FROM ProductYearlySales) -- Exclude the first year as it has no prior year to compare
ORDER BY
    productName, SalesYear;


-- 3. Employees who sold products from all categories
-- This query identifies employees with diverse sales portfolios.
SELECT
    e.firstName,
    e.lastName
FROM
    Employee e
INNER JOIN
    SalesOrder so ON e.employeeId = so.employeeId
INNER JOIN
    OrderDetail od ON so.orderId = od.orderId
INNER JOIN
    Product p ON od.productId = p.productId
INNER JOIN
    Category c ON p.categoryId = c.categoryId
GROUP BY
    e.employeeId, e.firstName, e.lastName
HAVING
    COUNT(DISTINCT c.categoryId) = (SELECT COUNT(DISTINCT categoryId) FROM Category);


-- 4. Customers with Orders in Consecutive Months (Advanced - requires date manipulation and window functions)
-- Identify highly consistent customers.
WITH CustomerMonthlyOrders AS (
    SELECT
        c.custId,
        c.companyName,
        DATE_FORMAT(so.orderDate, '%Y-%m-01') AS OrderMonth, -- Normalize to the first day of the month
        ROW_NUMBER() OVER (PARTITION BY c.custId ORDER BY DATE_FORMAT(so.orderDate, '%Y-%m-01')) AS rn
    FROM
        Customer c
    INNER JOIN
        SalesOrder so ON c.custId = so.custId
    GROUP BY
        c.custId, c.companyName, OrderMonth
),
ConsecutiveMonths AS (
    SELECT
        custId,
        companyName,
        OrderMonth,
        DATE_ADD(OrderMonth, INTERVAL - (rn - 1) MONTH) AS GroupingDate -- This helps identify consecutive sequences
    FROM
        CustomerMonthlyOrders
)
SELECT
    cmo.companyName AS CustomerName,
    MIN(cmo.OrderMonth) AS StartOfConsecutivePeriod,
    MAX(cmo.OrderMonth) AS EndOfConsecutivePeriod,
    COUNT(cmo.OrderMonth) AS ConsecutiveMonthsCount
FROM
    ConsecutiveMonths cmo
GROUP BY
    cmo.custId, cmo.companyName, cmo.GroupingDate
HAVING
    COUNT(cmo.OrderMonth) >= 2 -- Adjust to find sequences of 2 or more consecutive months
ORDER BY
    ConsecutiveMonthsCount DESC, CustomerName, StartOfConsecutivePeriod;

-- 5. Calculate the running total of sales for each employee (Advanced - uses Window Function)
SELECT
    e.firstName,
    e.lastName,
    so.orderDate,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS OrderTotal,
    SUM(SUM(od.unitPrice * od.quantity * (1 - od.discount))) OVER (PARTITION BY e.employeeId ORDER BY so.orderDate) AS RunningTotalSales
FROM
    Employee e
INNER JOIN
    SalesOrder so ON e.employeeId = so.employeeId
INNER JOIN
    OrderDetail od ON so.orderId = od.orderId
GROUP BY
    e.firstName, e.lastName, so.orderDate, e.employeeId -- Include employeeId in GROUP BY for distinct grouping for window function
ORDER BY
    e.firstName, e.lastName, so.orderDate;

