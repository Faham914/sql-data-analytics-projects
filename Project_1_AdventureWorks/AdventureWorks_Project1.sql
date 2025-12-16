USE AdventureWorks2012
/* =========================================================
   PROJECT 1: QUERYING A LARGE RELATIONAL DATABASE
   DATABASE: AdventureWorks2012
   ========================================================= */

/* ---------------------------------------------------------
   TASK 1
   Get all details from the Person table including
   Email ID, Phone Number, and Phone Number Type
   --------------------------------------------------------- */

SELECT 
    p.BusinessEntityID,
    p.FirstName,
    p.LastName,
    e.EmailAddress,
    ph.PhoneNumber,
    pt.Name AS PhoneNumberType
FROM Person.Person p
LEFT JOIN Person.EmailAddress e
    ON p.BusinessEntityID = e.BusinessEntityID
LEFT JOIN Person.PersonPhone ph
    ON p.BusinessEntityID = ph.BusinessEntityID
LEFT JOIN Person.PhoneNumberType pt
    ON ph.PhoneNumberTypeID = pt.PhoneNumberTypeID
ORDER BY p.BusinessEntityID;


/* ---------------------------------------------------------
   TASK 2
   Get details of Sales Order Header made in May 2011
   --------------------------------------------------------- */

SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2011-05-01'
  AND OrderDate < '2011-06-01';


/* ---------------------------------------------------------
   TASK 3
   Get details of Sales Order Details made in May 2011
   --------------------------------------------------------- */

SELECT 
    h.SalesOrderID,
    h.OrderDate,
    d.ProductID,
    d.OrderQty,
    d.UnitPrice,
    d.LineTotal
FROM Sales.SalesOrderHeader h
INNER JOIN Sales.SalesOrderDetail d
    ON h.SalesOrderID = d.SalesOrderID
WHERE h.OrderDate >= '2011-05-01'
  AND h.OrderDate < '2011-06-01'
ORDER BY h.SalesOrderID;


/* ---------------------------------------------------------
   TASK 4
   Get total sales made in May 2011
   --------------------------------------------------------- */

SELECT 
    SUM(TotalDue) AS TotalSales_May_2011
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2011-05-01'
  AND OrderDate < '2011-06-01';


/* ---------------------------------------------------------
   TASK 5
   Get total sales made in the year 2011 by month
   Ordered by increasing sales
   --------------------------------------------------------- */

SELECT 
    DATENAME(MONTH, OrderDate) AS MonthName,
    MONTH(OrderDate) AS MonthNumber,
    SUM(TotalDue) AS MonthlySales
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2011
GROUP BY DATENAME(MONTH, OrderDate), MONTH(OrderDate)
ORDER BY MonthlySales ASC;


/* ---------------------------------------------------------
   TASK 6
   Get total sales made to the customer
   FirstName = 'Gustavo' AND LastName = 'Achong'
   --------------------------------------------------------- */

SELECT 
    p.FirstName,
    p.LastName,
    SUM(h.TotalDue) AS TotalSales
FROM Person.Person p
INNER JOIN Sales.Customer c
    ON p.BusinessEntityID = c.PersonID
INNER JOIN Sales.SalesOrderHeader h
    ON c.CustomerID = h.CustomerID
WHERE p.FirstName = 'Gustavo'
  AND p.LastName = 'Achong'
GROUP BY p.FirstName, p.LastName;

