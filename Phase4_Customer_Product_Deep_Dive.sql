USE Northwind;

-- 1. Top 5 Customers by Total Sales (again, but now we're building on it)
-- This is a repeat from Phase 2, but good to have in context for this phase.
SELECT
    c.companyName AS CustomerName,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS TotalSales
FROM
    Customer c
INNER JOIN
    SalesOrder so ON c.custId = so.custId
INNER JOIN
    OrderDetail od ON so.orderId = od.orderId
GROUP BY
    c.companyName
ORDER BY
    TotalSales DESC
LIMIT 5;

-- 2. Top 5 Products by Quantity Sold
-- Focus on volume rather than just revenue.
SELECT
    p.productName,
    SUM(od.quantity) AS TotalQuantitySold
FROM
    Product p
INNER JOIN
    OrderDetail od ON p.productId = od.productId
GROUP BY
    p.productName
ORDER BY
    TotalQuantitySold DESC
LIMIT 5;

-- 3. Customers who have placed more than a certain number of orders (e.g., 5 orders)
SELECT
    c.companyName AS CustomerName,
    COUNT(so.orderId) AS NumberOfOrders
FROM
    Customer c
INNER JOIN
    SalesOrder so ON c.custId = so.custId
GROUP BY
    c.companyName
HAVING
    COUNT(so.orderId) > 5
ORDER BY
    NumberOfOrders DESC;

-- 4. Products that have never been ordered
-- Identify potentially obsolete or poorly marketed products.
SELECT
    p.productName
FROM
    Product p
LEFT JOIN
    OrderDetail od ON p.productId = od.productId
WHERE
    od.orderId IS NULL; -- If there's no matching order detail, it means it hasn't been ordered

-- 5. Customers who have not placed an order in the last 2 years (assuming data up to 1998-05-06)
-- This query helps identify inactive customers for re-engagement campaigns.
-- Note: Adjust the date '1998-05-06' if your dataset's latest order date is different.
SELECT
    c.companyName AS CustomerName,
    MAX(so.orderDate) AS LastOrderDate
FROM
    Customer c
LEFT JOIN
    SalesOrder so ON c.custId = so.custId
GROUP BY
    c.companyName
HAVING
    MAX(so.orderDate) < DATE_SUB('1998-05-06', INTERVAL 2 YEAR) OR MAX(so.orderDate) IS NULL
ORDER BY
    LastOrderDate ASC;

-- 6. Products with sales below average (by category)
-- This is a more advanced query using a CTE to find average sales per category first.
WITH CategoryProductSales AS (
    SELECT
        c.categoryId,
        c.categoryName,
        p.productId,
        p.productName,
        SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS ProductTotalSales
    FROM
        Category c
    INNER JOIN
        Product p ON c.categoryId = p.categoryId
    INNER JOIN
        OrderDetail od ON p.productId = od.productId
    GROUP BY
        c.categoryId, c.categoryName, p.productId, p.productName
),
CategoryAverage AS (
    SELECT
        categoryId,
        categoryName,
        AVG(ProductTotalSales) AS AvgCategorySales
    FROM
        CategoryProductSales
    GROUP BY
        categoryId, categoryName
)
SELECT
    cps.productName,
    cps.categoryName,
    cps.ProductTotalSales,
    ca.AvgCategorySales
FROM
    CategoryProductSales cps
INNER JOIN
    CategoryAverage ca ON cps.categoryId = ca.categoryId
WHERE
    cps.ProductTotalSales < ca.AvgCategorySales
ORDER BY
    cps.categoryName, cps.ProductTotalSales;
