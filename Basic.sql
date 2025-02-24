CREATE DATABASE SalesAnalysis;
USE SalesAnalysis;

-- Step 1: Create the countries Table
CREATE TABLE countries (
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(45),
    CountryCode VARCHAR(2)
);

-- Step 2: Create the cities Table
CREATE TABLE cities (
    CityID INT PRIMARY KEY,
    CityName VARCHAR(45),
    Zipcode DECIMAL(5,0),
    CountryID INT,
    FOREIGN KEY (CountryID) REFERENCES countries(CountryID)
);

-- Step 3: Create the categories Table
CREATE TABLE categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(45)
);

-- Step 4: Create the customers Table
CREATE TABLE customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(45),
    MiddleInitial VARCHAR(1),
    LastName VARCHAR(45),
    CityID INT,
    Address VARCHAR(90),
    FOREIGN KEY (CityID) REFERENCES cities(CityID)
);

-- Step 5: Create the employees Table
CREATE TABLE employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(45),
    MiddleInitial VARCHAR(1),
    LastName VARCHAR(45),
    BirthDate DATE,
    Gender VARCHAR(10),
    CityID INT,
    HireDate DATE,
    FOREIGN KEY (CityID) REFERENCES cities(CityID)
);

-- Step 6: Create the products Table
CREATE TABLE products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(45),
    Price DECIMAL(4,0),
    CategoryID INT,
    Class VARCHAR(15),
    ModifyDate DATE,
    Resistant VARCHAR(15),
    IsAllergic VARCHAR(10),
    VitalityDays DECIMAL(3,0),
    FOREIGN KEY (CategoryID) REFERENCES categories(CategoryID)
);

-- Step 7: Create the sales Table
CREATE TABLE sales (
    SalesID INT PRIMARY KEY,
    SalesPersonID INT,
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    Discount DECIMAL(10,2),
    TotalPrice DECIMAL(10,2),
    SalesDate DATETIME,
    TransactionNumber VARCHAR(25),
    FOREIGN KEY (SalesPersonID) REFERENCES employees(EmployeeID),
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);

-- Step 8: Import Data from CSV Files into SQL Tables

-- Step 9: Verify Data Integrity: Check total records in each table
SELECT 'categories' AS TableName, COUNT(*) AS TotalRecords FROM categories
UNION ALL
SELECT 'cities', COUNT(*) FROM cities
UNION ALL
SELECT 'countries', COUNT(*) FROM countries
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sales', COUNT(*) FROM sales;

-- Step 9: Check for null values
SELECT 'categories' AS TableName, COUNT(*) AS NullValues FROM categories WHERE CategoryName IS NULL
UNION ALL
SELECT 'cities', COUNT(*) FROM cities WHERE CityName IS NULL
UNION ALL
SELECT 'countries', COUNT(*) FROM countries WHERE CountryName IS NULL
UNION ALL
SELECT 'customers', COUNT(*) FROM customers WHERE FirstName IS NULL OR LastName IS NULL
UNION ALL
SELECT 'employees', COUNT(*) FROM employees WHERE FirstName IS NULL OR LastName IS NULL
UNION ALL
SELECT 'products', COUNT(*) FROM products WHERE ProductName IS NULL OR Price IS NULL
UNION ALL
SELECT 'sales', COUNT(*) FROM sales WHERE Quantity IS NULL OR TotalPrice IS NULL;

-- Step 10: Check for duplicate records from customers table and products also sales
SELECT CustomerID, COUNT(*) AS Count 
FROM customers 
GROUP BY CustomerID 
HAVING COUNT(*) > 1;

SELECT ProductID, COUNT(*) AS Count 
FROM products 
GROUP BY ProductID 
HAVING COUNT(*) > 1;

SELECT SalesID, COUNT(*) AS Count 
FROM sales 
GROUP BY SalesID 
HAVING COUNT(*) > 1;

-- Step 11: Insights
-- Total Sales per Month
SELECT 
    DATE_FORMAT(SalesDate, '%Y-%m') AS Month, 
    SUM(TotalPrice) AS TotalSales
FROM Sales
GROUP BY Month
ORDER BY Month;

-- Sales Trends by Product Category
SELECT 
    DATE_FORMAT(S.SalesDate, '%Y-%m') AS Month, 
    P.CategoryID, 
    C.CategoryName, 
    SUM(S.TotalPrice) AS TotalSales
FROM Sales S
JOIN Products P ON S.ProductID = P.ProductID
JOIN Categories C ON P.CategoryID = C.CategoryID
GROUP BY Month, P.CategoryID, C.CategoryName
ORDER BY Month, TotalSales DESC;

-- Top-Selling Products
SELECT 
    P.ProductID, 
    P.ProductName, 
    SUM(S.Quantity) AS TotalUnitsSold, 
    SUM(S.TotalPrice) AS TotalRevenue
FROM Sales S
JOIN Products P ON S.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName
ORDER BY TotalRevenue DESC, TotalUnitsSold DESC
LIMIT 10;

-- Customer Purchase Behavior
SELECT 
    C.CustomerID, 
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName, 
    COUNT(S.SalesID) AS TotalPurchases, 
    SUM(S.TotalPrice) AS TotalSpent, 
    AVG(S.TotalPrice) AS AvgOrderValue
FROM Sales S
JOIN Customers C ON S.CustomerID = C.CustomerID
GROUP BY C.CustomerID, CustomerName
ORDER BY TotalSpent DESC;

-- Salesperson Effectiveness
SELECT 
    E.EmployeeID, 
    CONCAT(E.FirstName, ' ', E.LastName) AS SalesPersonName, 
    COUNT(S.SalesID) AS TotalSalesCount, 
    SUM(S.TotalPrice) AS TotalRevenue
FROM Sales S
JOIN Employees E ON S.SalesPersonID = E.EmployeeID
GROUP BY E.EmployeeID, SalesPersonName
ORDER BY TotalRevenue DESC;

-- Sales by Region
SELECT 
    Cn.CountryName, 
    Ct.CityName, 
    SUM(S.TotalPrice) AS TotalSales
FROM Sales S
JOIN Customers Cu ON S.CustomerID = Cu.CustomerID
JOIN Cities Ct ON Cu.CityID = Ct.CityID
JOIN Countries Cn ON Ct.CountryID = Cn.CountryID
GROUP BY Cn.CountryName, Ct.CityName
ORDER BY TotalSales DESC;

-- Query optimization
-- Indexing for Faster Lookups
CREATE INDEX idx_sales_salesdate ON sales(SalesDate);
CREATE INDEX idx_sales_productid ON sales(ProductID);
CREATE INDEX idx_sales_customerid ON sales(CustomerID);

-- Used EXISTS Instead of IN
SELECT * FROM customers C WHERE EXISTS 
  (SELECT 1 FROM cities Ct WHERE Ct.CityID = C.CityID AND Ct.CountryID = 1);
