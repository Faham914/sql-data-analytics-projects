/* =========================================================
   PROJECT 2: RELATIONAL DATABASE DESIGN
   DATABASE: UserManagementDB
   ========================================================= */

-- Step 1: Create Database
CREATE DATABASE UserManagementDB;
GO

USE UserManagementDB;
GO


/* ---------------------------------------------------------
   Step 2: Create Tables with Primary Keys
   --------------------------------------------------------- */

-- Roles table
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL
);

-- Users table
CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    RoleID INT,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

-- AccountStatus table
CREATE TABLE AccountStatus (
    StatusID INT PRIMARY KEY,
    StatusName VARCHAR(50) NOT NULL
);

-- UserAccounts table
CREATE TABLE UserAccounts (
    AccountID INT PRIMARY KEY,
    UserID INT,
    StatusID INT,
    CreatedDate DATE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (StatusID) REFERENCES AccountStatus(StatusID)
);


/* ---------------------------------------------------------
   Step 3: Insert Data into Tables
   At least two rows in each table
   --------------------------------------------------------- */

-- Insert into Roles
INSERT INTO Roles VALUES
(1, 'Admin'),
(2, 'User');

-- Insert into Users
INSERT INTO Users VALUES
(101, 'Rahul Sharma', 'rahul@gmail.com', 1),
(102, 'Neha Verma', 'neha@gmail.com', 2);

-- Insert into AccountStatus
INSERT INTO AccountStatus VALUES
(1, 'Active'),
(2, 'Inactive');

-- Insert into UserAccounts
INSERT INTO UserAccounts VALUES
(1001, 101, 1, '2024-01-10'),
(1002, 102, 2, '2024-02-15');


/* ---------------------------------------------------------
   Step 4: Verify Data (Optional but Recommended)
   --------------------------------------------------------- */

SELECT * FROM Roles;
SELECT * FROM Users;
SELECT * FROM AccountStatus;
SELECT * FROM UserAccounts;


/* ---------------------------------------------------------
   Step 5: Delete All Data from Each Table
   Order matters due to foreign key constraints
   --------------------------------------------------------- */

DELETE FROM UserAccounts;
DELETE FROM Users;
DELETE FROM AccountStatus;
DELETE FROM Roles;

