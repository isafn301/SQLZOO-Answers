/* AdventureWorks Hard Questions, from:
http://sqlzoo.net/wiki/AdventureWorks_hard_questions */

/* QUESTION 11
For every customer with a 'Main Office' in Dallas show AddressLine1 
of the 'Main Office' and AddressLine1 of the 'Shipping' address 
- if there is no shipping address leave it blank. Use one row per customer. */

SELECT 
	c.CompanyName, 
	c.CustomerID,  
    	AddressLine1 AS MainOffice,
	(SELECT 
		a2.AddressLine1 
	FROM
		Address a2 
        INNER JOIN 
		CustomerAddress ca2 
		ON a2.AddressID = ca2.AddressID
	WHERE 
		ca2.CustomerID = c.CustomerID
		AND ca2.AddressType = 'Shipping')  AS Shipping
        
FROM 
	Customer c
	INNER JOIN 
		CustomerAddress ca
		ON c.CustomerID = ca.CustomerID
	INNER JOIN 
		Address a
		ON a.AddressID = ca.AddressID;
        
/* QUESTION 12
For each order show the SalesOrderID and SubTotal calculated three ways: 
A) From the SalesOrderHeader 
B) Sum of OrderQty*UnitPrice 
C) Sum of OrderQty*ListPrice */

SELECT 
	soh.SalesOrderID, 
    	soh.SubTotal AS SubTotal_A, 
    	SUM(sod.OrderQty*sod.UnitPrice) AS SubTotal_B,
	SUM(sod.OrderQty*p.ListPrice)  AS SubTotal_C
    
FROM 
	SalesOrderHeader soh
	INNER JOIN 
		SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	INNER JOIN 
		Product p
		ON p.ProductID = sod.ProductID

GROUP BY SalesOrderID, SubTotal_A;

/* QUESTION 13 
Show the best selling item by value. */

SELECT 
	p.ProductID, 
    	p.Name, 
    	SUM(sod.OrderQty) AS TotalSales, 
    	SUM(sod.OrderQty*sod.UnitPrice) AS TotalSalesValue
    
FROM 
	Product p
	INNER JOIN 
		SalesOrderDetail sod
		ON sod.ProductID = p.ProductID

GROUP BY p.ProductID, p.Name
ORDER BY TotalSalesValue DESC;

/* QUESTION 14
Show how many orders are in the following ranges (in $):
	 RANGE      Num Orders      Total Value
    0-  99
  100- 999
 1000-9999
10000-
*/

SELECT 
	r.Range, 
    	COUNT(r.SubTotal) AS 'Num Orders', 
    	SUM(r.SubTotal) AS 'Total Value'

FROM (
	SELECT 
		SubTotal, 
		CASE
			WHEN SubTotal BETWEEN 0 AND 99 THEN '0-99'
			WHEN SubTotal BETWEEN 100 AND 999 THEN '100-999'
			WHEN SubTotal BETWEEN 1000 AND 9999 THEN '1000-9999'
			WHEN SubTotal >= 10000 THEN '10000-'
			ELSE 'Error'END 
		AS 'Range'
	FROM 
		SalesOrderHeader
	) AS r

GROUP BY r.Range;

/* QUESTION 15
Identify the three most important cities. Show the break down of 
top level product category against city. */

SELECT 
	a.City, 
    	pc.Name AS Category, 
    	SUM(sod.OrderQty*sod.UnitPrice) AS Total
    
FROM (
	SELECT 
		a.City, 
        	SUM(soh.SubTotal) AS CityTotal
	FROM 
		Address a
		INNER JOIN 
			SalesOrderHeader soh
			ON a.AddressID = soh.ShipToAddressID
	GROUP BY a.City
	ORDER BY CityTotal DESC LIMIT 3 
    ) AS ct
    
	INNER JOIN 
		Address a
		ON ct.City = a.City
	INNER JOIN 
		SalesOrderHeader soh
		ON a.AddressID = soh.ShipToAddressID
	INNER JOIN 
		SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	INNER JOIN 
		Product p
		ON sod.ProductID = p.ProductID
	INNER JOIN 
		ProductCategory pc
		ON p.ProductCategoryID = pc.ProductCategoryID

GROUP BY City, Category;
