USE Northwind;

-- 1. Get a quick look at the Customers table
SELECT *
FROM Customer
LIMIT 10;

-- 2. See the structure of the Products table
DESCRIBE Product;

-- 3. List all categories and their descriptions
SELECT
    categoryId,
    categoryName,
    description
FROM Category;

-- 4. Find out which employees are in the 'Sales Representative' role
SELECT
    employeeId,
    firstName,
    lastName,
    title
FROM Employee
WHERE title = 'Sales Representative';

-- 5. Show the first 5 sales orders, including customer and employee IDs
SELECT
    orderId,
    custId,
    employeeId,
    orderDate,
    shippedDate,
    shipCountry
FROM SalesOrder
LIMIT 5;

-- 6. Check the details of order line items (OrderDetail table)
-- This table contains the actual products sold within each order
SELECT
    orderDetailId,
    orderId,
    productId,
    unitPrice,
    quantity,
    discount
FROM OrderDetail
LIMIT 10;

-- 7. List all suppliers and their contact information
SELECT
    supplierId,
    companyName,
    contactName,
    phone,
    country
FROM Supplier
LIMIT 10;

-- 8. See all products that are currently discontinued
SELECT
    productId,
    productName,
    unitPrice,
    discontinued
FROM Product
WHERE discontinued = 1;

