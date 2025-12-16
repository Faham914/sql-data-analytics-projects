/* =========================================================
   PROJECT 4: UBER OPERATIONAL DATA ANALYSIS

   ========================================================= */

------------------------------------------------------------
-- DATABASE
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'UberDB')
BEGIN
    CREATE DATABASE UberDB;
END;
GO

USE UberDB;
GO

------------------------------------------------------------
-- TABLE
------------------------------------------------------------
IF OBJECT_ID('UberData', 'U') IS NULL
BEGIN
    CREATE TABLE UberData (
        ride_id INT,
        city_name VARCHAR(50),
        ride_date DATE,
        ride_time TIME,
        ride_category VARCHAR(50),
        ride_status VARCHAR(20),
        fare_amount DECIMAL(10,2),
        ride_duration INT,
        driver_id INT,
        driver_name VARCHAR(100),
        driver_rating DECIMAL(3,2),
        payment_method VARCHAR(50),
        payment_amount DECIMAL(10,2)
    );
END;
GO

------------------------------------------------------------
-- CSV IMPORT (RUN ONLY ONCE)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM UberData)
BEGIN
    BULK INSERT UberData
    FROM 'C:/Users/ASUS/Downloads/Uber_Operational_Data.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
END;
GO

------------------------------------------------------------
-- VERIFY
------------------------------------------------------------
SELECT COUNT(*) AS total_rows FROM UberData;
GO

------------------------------------------------------------
-- CITY LEVEL PERFORMANCE
------------------------------------------------------------
SELECT TOP 3
    city_name,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN ride_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_rides,
    AVG(driver_rating) AS avg_driver_rating
FROM UberData
GROUP BY city_name
ORDER BY cancelled_rides DESC, avg_driver_rating ASC;
GO

------------------------------------------------------------
-- REVENUE LEAKAGE
------------------------------------------------------------
SELECT
    ride_id,
    fare_amount,
    payment_amount,
    ride_status
FROM UberData
WHERE ride_status = 'Completed'
  AND (payment_amount IS NULL OR payment_amount <> fare_amount);
GO

------------------------------------------------------------
-- CANCELLATION ANALYSIS
------------------------------------------------------------
SELECT
    city_name,
    ride_category,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN ride_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations
FROM UberData
GROUP BY city_name, ride_category
ORDER BY cancellations DESC;
GO

------------------------------------------------------------
-- CANCELLATION BY TIME
------------------------------------------------------------
SELECT
    DATEPART(HOUR, ride_time) AS ride_hour,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN ride_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_rides,
    SUM(CASE WHEN ride_status = 'Completed' THEN fare_amount ELSE 0 END) AS revenue
FROM UberData
GROUP BY DATEPART(HOUR, ride_time)
ORDER BY cancelled_rides DESC;
GO

------------------------------------------------------------
-- SEASONAL FARE ANALYSIS
------------------------------------------------------------
SELECT
    DATENAME(MONTH, ride_date) AS month_name,
    AVG(fare_amount) AS avg_fare
FROM UberData
GROUP BY DATENAME(MONTH, ride_date), MONTH(ride_date)
ORDER BY MONTH(ride_date);
GO

------------------------------------------------------------
-- AVERAGE RIDE DURATION BY CITY
------------------------------------------------------------
SELECT
    city_name,
    AVG(ride_duration) AS avg_ride_duration
FROM UberData
GROUP BY city_name;
GO

------------------------------------------------------------
-- INDEX: RIDE DATE
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'idx_ride_date'
      AND object_id = OBJECT_ID('UberData')
)
BEGIN
    CREATE NONCLUSTERED INDEX idx_ride_date
    ON UberData(ride_date);
END;
GO

------------------------------------------------------------
-- VIEW: AVG FARE BY CITY
------------------------------------------------------------
IF OBJECT_ID('vw_AvgFareByCity', 'V') IS NOT NULL
    DROP VIEW vw_AvgFareByCity;
GO

CREATE VIEW vw_AvgFareByCity AS
SELECT
    city_name,
    AVG(fare_amount) AS avg_fare
FROM UberData
GROUP BY city_name;
GO

------------------------------------------------------------
-- AUDIT TABLE
------------------------------------------------------------
IF OBJECT_ID('RideStatusAudit', 'U') IS NULL
BEGIN
    CREATE TABLE RideStatusAudit (
        audit_id INT IDENTITY PRIMARY KEY,
        ride_id INT,
        old_status VARCHAR(20),
        new_status VARCHAR(20),
        change_date DATETIME DEFAULT GETDATE()
    );
END;
GO

------------------------------------------------------------
-- TRIGGER
------------------------------------------------------------
IF OBJECT_ID('trg_RideStatusChange', 'TR') IS NOT NULL
    DROP TRIGGER trg_RideStatusChange;
GO

CREATE TRIGGER trg_RideStatusChange
ON UberData
AFTER UPDATE
AS
BEGIN
    INSERT INTO RideStatusAudit (ride_id, old_status, new_status)
    SELECT
        i.ride_id,
        d.ride_status,
        i.ride_status
    FROM inserted i
    JOIN deleted d
        ON i.ride_id = d.ride_id
    WHERE i.ride_status <> d.ride_status;
END;
GO

------------------------------------------------------------
-- VIEW: DRIVER PERFORMANCE
------------------------------------------------------------
IF OBJECT_ID('vw_DriverPerformance', 'V') IS NOT NULL
    DROP VIEW vw_DriverPerformance;
GO

CREATE VIEW vw_DriverPerformance AS
SELECT
    driver_id,
    driver_name,
    COUNT(*) AS total_rides,
    AVG(driver_rating) AS avg_rating,
    SUM(fare_amount) AS total_earnings
FROM UberData
GROUP BY driver_id, driver_name;
GO

------------------------------------------------------------
-- INDEX: PAYMENT METHOD
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'idx_payment_method'
      AND object_id = OBJECT_ID('UberData')
)
BEGIN
    CREATE NONCLUSTERED INDEX idx_payment_method
    ON UberData(payment_method);
END;
GO
