/* =========================================================
   PROJECT 3: OPERATIONAL EFFICIENCY ANALYSIS
   CORRECTED FOR SQL SERVER BATCH RULES
   ========================================================= */

------------------------------------------------------------
-- STEP 1: CREATE DATABASE (SAFE)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BusinessOperationsDB')
BEGIN
    CREATE DATABASE BusinessOperationsDB;
END
GO

USE BusinessOperationsDB;
GO

------------------------------------------------------------
-- STEP 2: CREATE TABLE (ONLY IF NOT EXISTS)
------------------------------------------------------------
IF OBJECT_ID('BusinessOperations', 'U') IS NULL
BEGIN
    CREATE TABLE BusinessOperations (
        company_id INT,
        department VARCHAR(50),
        product_name VARCHAR(100),
        category VARCHAR(50),
        supplier VARCHAR(100),
        employee_name VARCHAR(100),
        employee_role VARCHAR(50),
        salary DECIMAL(10,2),
        performance_score INT,
        training_completed VARCHAR(10),
        revenue DECIMAL(12,2),
        profit_margin DECIMAL(5,2),
        inventory_level INT,
        units_sold INT,
        customer_feedback_score DECIMAL(4,2)
    );
END
GO

------------------------------------------------------------
-- STEP 3: IMPORT CSV (RUN ONLY ONCE)
------------------------------------------------------------
-- EDIT FILE PATH IF NEEDED
BULK INSERT BusinessOperations
FROM 'C:/Users/ASUS/Downloads/Business_Operations_Dataset/Business_Operations_Dataset.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

------------------------------------------------------------
-- STEP 4: VERIFY DATA
------------------------------------------------------------
SELECT COUNT(*) AS total_rows FROM BusinessOperations;
SELECT TOP 5 * FROM BusinessOperations;
GO

------------------------------------------------------------
-- ANALYSIS QUERIES (SAFE TO RUN MULTIPLE TIMES)
------------------------------------------------------------

SELECT department, AVG(profit_margin) AS avg_profit_margin
FROM BusinessOperations
GROUP BY department
ORDER BY avg_profit_margin DESC;
GO

SELECT TOP 1 employee_name, employee_role, performance_score
FROM BusinessOperations
WHERE department = 'IT'
ORDER BY performance_score DESC;
GO

SELECT TOP 1 product_name, revenue
FROM BusinessOperations
WHERE department = 'HR'
ORDER BY revenue DESC;
GO

------------------------------------------------------------
-- VIEW (MUST BE FIRST IN BATCH)
------------------------------------------------------------
IF OBJECT_ID('vw_Accessories_Performance', 'V') IS NOT NULL
    DROP VIEW vw_Accessories_Performance;
GO

CREATE VIEW vw_Accessories_Performance
AS
SELECT product_name, revenue, profit_margin
FROM BusinessOperations
WHERE category = 'Accessories';
GO

------------------------------------------------------------
-- INDEX
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'idx_employee_name'
)
BEGIN
    CREATE NONCLUSTERED INDEX idx_employee_name
    ON BusinessOperations(employee_name);
END
GO

------------------------------------------------------------
-- STORED PROCEDURE
------------------------------------------------------------
IF OBJECT_ID('sp_DepartmentRevenue', 'P') IS NOT NULL
    DROP PROCEDURE sp_DepartmentRevenue;
GO

CREATE PROCEDURE sp_DepartmentRevenue
    @DepartmentName VARCHAR(50)
AS
BEGIN
    SELECT department, SUM(revenue) AS total_revenue
    FROM BusinessOperations
    WHERE department = @DepartmentName
    GROUP BY department;
END;
GO

------------------------------------------------------------
-- TRIGGER
------------------------------------------------------------
IF OBJECT_ID('Revenue_Audit', 'U') IS NULL
BEGIN
    CREATE TABLE Revenue_Audit (
        audit_id INT IDENTITY PRIMARY KEY,
        product_name VARCHAR(100),
        old_revenue DECIMAL(12,2),
        new_revenue DECIMAL(12,2),
        change_date DATETIME DEFAULT GETDATE()
    );
END
GO

IF OBJECT_ID('trg_Revenue_Update', 'TR') IS NOT NULL
    DROP TRIGGER trg_Revenue_Update;
GO

CREATE TRIGGER trg_Revenue_Update
ON BusinessOperations
AFTER UPDATE
AS
BEGIN
    INSERT INTO Revenue_Audit (product_name, old_revenue, new_revenue)
    SELECT i.product_name, d.revenue, i.revenue
    FROM inserted i
    JOIN deleted d
        ON i.product_name = d.product_name
    WHERE i.revenue <> d.revenue;
END;
GO

------------------------------------------------------------
-- SCALAR FUNCTION
------------------------------------------------------------
IF OBJECT_ID('dbo.fn_CalculateProfit', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalculateProfit;
GO

CREATE FUNCTION dbo.fn_CalculateProfit
(
    @revenue DECIMAL(12,2),
    @profit_margin DECIMAL(5,2)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN (@revenue * @profit_margin) / 100;
END;
GO

------------------------------------------------------------
-- TEST FUNCTION
------------------------------------------------------------
SELECT 
    product_name,
    dbo.fn_CalculateProfit(revenue, profit_margin) AS calculated_profit
FROM BusinessOperations;
GO

------------------------------------------------------------
-- CLUSTERED INDEX
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'idx_company_id'
)
BEGIN
    CREATE CLUSTERED INDEX idx_company_id
    ON BusinessOperations(company_id);
END
GO
