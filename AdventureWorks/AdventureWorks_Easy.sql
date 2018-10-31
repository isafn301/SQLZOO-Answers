/* AdventureWorks Easy Questions, from:
http://sqlzoo.net/wiki/AdventureWorks_easy_questions */

/* QUESTION 1
Show the first name and the email address of customer with CompanyName 'Bike World'. */

SELECT 
	FirstName, 
   	EmailAddress, 
    	CompanyName
FROM 
	Customer
WHERE 
	CompanyName = 'Bike World';
    
/* QUESTION 2
Show the CompanyName for all customers with an address in City 'Dallas'. */

SELECT DISTINCT 
	c.CompanyName, 
    	a.City
FROM 
	Customer c
	INNER JOIN 
		CustomerAddress ca
		ON c.CustomerID = ca.CustomerID
	INNER JOIN
		Address a
		ON ca.AddressID = a.AddressID
WHERE 
	a.City = 'Dallas';
    
/* QUESTION 3
How many items with ListPrice more than $1000 have been sold? */

SELECT 
	SUM(sod.OrderQty) #Sum the number of products ordered
FROM	
	SalesOrderDetail sod
	INNER JOIN
		Product p
		ON sod.ProductID = p.ProductID
WHERE 
	p.ListPrice > 1000;
    
/* QUESTION 4
Give the CompanyName of those customers with orders over $100000. 
Include the subtotal plus tax plus freight. */

SELECT 
	c.CompanyName,
    	(soh.SubTotal +  soh.TaxAmt +  soh.Freight) AS Total, 
    	soh.SubTotal, 
    	soh.TaxAmt, 
    	soh.Freight
FROM 
	SalesOrderHeader soh
	INNER JOIN
		Customer c
		ON soh.CustomerID = c.CustomerID
WHERE 
	soh.SubTotal +  soh.TaxAmt +  soh.Freight > 100000
ORDER BY Total DESC;

/* QUESTION 5
Find the number of left racing socks ('Racing Socks, L') ordered by 
CompanyName 'Riding Cycles'. */

SELECT 
	SUM(sod.OrderQty) AS TotalQty
FROM 
	SalesOrderDetail sod
	INNER JOIN 
		SalesOrderHeader soh
		ON sod.SalesOrderID = soh.SalesOrderID
WHERE 
	sod.ProductID IN (
		SELECT
			ProductID
		FROM
			Product
		WHERE
			Name = 'Racing Socks, L' )
	AND soh.CustomerID IN (
		SELECT 
			CustomerID
		FROM 
			Customer
		WHERE
			CompanyName = 'Riding Cycles' );
