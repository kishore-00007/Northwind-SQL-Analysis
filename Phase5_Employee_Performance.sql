USE Northwind;

-- 1. Total Sales by Each Employee (from Phase 2, but good to re-emphasize)
SELECT
    e.employeeId,
    e.firstName,
    e.lastName,
    e.title,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    Employee e
INNER JOIN
    SalesOrder so ON e.employeeId = so.employeeId
INNER JOIN
    OrderDetail od ON so.orderId = od.orderId
GROUP BY
    e.employeeId, e.firstName, e.lastName, e.title
ORDER BY
    TotalSales DESC;

-- 2. Number of Orders Handled by Each Employee
SELECT
    e.employeeId,
    e.firstName,
    e.lastName,
    COUNT(DISTINCT so.orderId) AS NumberOfOrders
FROM
    Employee e
INNER JOIN
    SalesOrder so ON e.employeeId = so.employeeId
GROUP BY
    e.employeeId, e.firstName, e.lastName
ORDER BY
    NumberOfOrders DESC;

-- 3. Average Order Value per Employee
-- This helps understand if employees are selling higher-value orders.
SELECT
    e.employeeId,
    e.firstName,
    e.lastName,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) / COUNT(DISTINCT so.orderId) AS AverageOrderValue
FROM
    Employee e
INNER JOIN
    SalesOrder so ON e.employeeId = so.employeeId
INNER JOIN
    OrderDetail od ON so.orderId = od.orderId
GROUP BY
    e.employeeId, e.firstName, e.lastName
ORDER BY
    AverageOrderValue DESC;

-- 4. Employee Sales Performance by Region/Territory (more advanced)
-- This requires joining Employee with EmployeeTerritory and Territory tables.
-- Note: Not all employees might have territories assigned in the Northwind dataset.
SELECT
    e.employeeId,
    e.firstName,
    e.lastName,
    t.territoryDescription,
    r.regionDescription,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    Employee e
INNER JOIN
    SalesOrder so ON e.employeeId = so.employeeId
INNER JOIN
    OrderDetail od ON so.orderId = od.orderId
LEFT JOIN -- Use LEFT JOIN to include employees even if they don't have a territory in the data
    EmployeeTerritory et ON e.employeeId = et.employeeId
LEFT JOIN
    Territory t ON et.territoryId = t.territoryId
LEFT JOIN
    Region r ON t.regionId = r.regionId
GROUP BY
    e.employeeId, e.firstName, e.lastName, t.territoryDescription, r.regionDescription
ORDER BY
    TotalSales DESC;

-- 5. Top 3 Employees by Sales in Each Year (Advanced - uses Window Functions)
WITH EmployeeYearlySales AS (
    SELECT
        e.employeeId,
        e.firstName,
        e.lastName,
        YEAR(so.orderDate) AS SalesYear,
        SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS YearlySales
    FROM
        Employee e
    INNER JOIN
        SalesOrder so ON e.employeeId = so.employeeId
    INNER JOIN
        OrderDetail od ON so.orderId = od.orderId
    GROUP BY
        e.employeeId, e.firstName, e.lastName, SalesYear
),
RankedEmployeeSales AS (
    SELECT
        employeeId,
        firstName,
        lastName,
        SalesYear,
        YearlySales,
        RANK() OVER (PARTITION BY SalesYear ORDER BY YearlySales DESC) AS RankInYear
    FROM
        EmployeeYearlySales
)
SELECT
    employeeId,
    firstName,
    lastName,
    SalesYear,
    YearlySales,
    RankInYear
FROM
    RankedEmployeeSales
WHERE
    RankInYear <= 3
ORDER BY
    SalesYear, RankInYear;