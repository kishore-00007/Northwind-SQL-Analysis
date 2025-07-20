USE Northwind;

-- 1. Total Sales by Year
-- Extract the year from the orderDate to see yearly trends.
SELECT
    YEAR(so.orderDate) AS SalesYear,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    OrderDetail od
INNER JOIN
    SalesOrder so ON od.orderId = so.orderId
GROUP BY
    SalesYear
ORDER BY
    SalesYear;

-- 2. Total Sales by Month (across all years)
-- This helps identify seasonal patterns regardless of the year.
SELECT
    MONTH(so.orderDate) AS SalesMonth,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    OrderDetail od
INNER JOIN
    SalesOrder so ON od.orderId = so.orderId
GROUP BY
    SalesMonth
ORDER BY
    SalesMonth;

-- 3. Total Sales by Year and Month
-- A more granular view to see specific monthly performance within each year.
SELECT
    YEAR(so.orderDate) AS SalesYear,
    MONTH(so.orderDate) AS SalesMonth,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    OrderDetail od
INNER JOIN
    SalesOrder so ON od.orderId = so.orderId
GROUP BY
    SalesYear, SalesMonth
ORDER BY
    SalesYear, SalesMonth;

-- 4. Monthly Sales Growth Percentage (Advanced - requires a subquery or CTE)
-- This query calculates the month-over-month growth.
-- We'll use a CTE to get monthly sales and then a self-join to compare.
WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(so.orderDate, '%Y-%m') AS SalesMonthYear,
        SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS MonthlyRevenue
    FROM
        OrderDetail od
    INNER JOIN
        SalesOrder so ON od.orderId = so.orderId
    GROUP BY
        SalesMonthYear
),
RankedMonthlySales AS (
    SELECT
        SalesMonthYear,
        MonthlyRevenue,
        LAG(MonthlyRevenue, 1, 0) OVER (ORDER BY SalesMonthYear) AS PreviousMonthRevenue
    FROM
        MonthlySales
)
SELECT
    SalesMonthYear,
    MonthlyRevenue,
    PreviousMonthRevenue,
    CASE
        WHEN PreviousMonthRevenue = 0 THEN NULL -- Avoid division by zero for the first month
        ELSE ((MonthlyRevenue - PreviousMonthRevenue) / PreviousMonthRevenue) * 100
    END AS GrowthPercentage
FROM
    RankedMonthlySales
ORDER BY
    SalesMonthYear;
