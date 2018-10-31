/* AdventureWorks Resit Questions, from:
http://sqlzoo.net/wiki/AdventureWorks_resit_questions */

/* QUESTION 1
List the SalesOrderID for the customer 'Good Toys' or 'Bike World' */
SELECT 
	c.CompanyName, 
	soh.SalesOrderID

FROM 
	Customer c
	LEFT JOIN 
		SalesOrderHeader soh
		ON soh.CustomerID = c.CustomerID

WHERE 
	c.CompanyName = 'Good Toys' 
    	OR c.CompanyName = 'Bike World';

/* QUESTION 2
List the ProductName and the quantity of what was ordered by 'Futuristic Bikes' */

SELECT 
	c.CompanyName, 
    	p.Name, 
    	sod.OrderQty

FROM 
	Customer c
	INNER JOIN 
		SalesOrderHeader soh
		ON c.CustomerID = soh.CustomerID
	INNER JOIN 
		SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	INNER JOIN 
		Product p
		ON sod.ProductID = p.ProductID

WHERE 
	c.CompanyName = 'Futuristic Bikes';
    
/* QUESTION 3
List the name and addresses of companies containing the word 'Bike' 
(upper or lower case) and companies containing 'cycle' (upper or lower case). 
Ensure that the 'bike's are listed before the 'cycles's. */

SELECT 
	c.CompanyName, 
    	ca.AddressType, 
    	a.AddressLine1, 
    	a.AddressLine2, 
    	a.City, 
    	a.StateProvince, 
    	a.CountyRegion AS CountryRegion, 
    	a.PostalCode

FROM 
	Customer c
	INNER JOIN 
		CustomerAddress ca
		ON c.CustomerID = ca.CustomerID
	INNER JOIN 
		Address a
		ON ca.AddressID = a.AddressID

WHERE 
	LOWER(CompanyName) LIKE '%bike%'

UNION

SELECT 
	c2.CompanyName, 
    	ca2.AddressType, 
    	a2.AddressLine1, 
    	a2.AddressLine2, 
    	a2.City, 
    	a2.StateProvince, 
    	a2.CountyRegion AS CountryRegion, 
    	a2.PostalCode

FROM 
	Customer c2
	INNER JOIN 
		CustomerAddress ca2
		ON c2.CustomerID = ca2.CustomerID
	INNER JOIN 
		Address a2
		ON ca2.AddressID = a2.AddressID

WHERE 
	LOWER(CompanyName) LIKE '%cycle%';
    
/* QUESTION 4
Show the total order value for each CountryRegion. List by value with the highest first. */

SELECT 
	a.CountyRegion AS CountryRegion, 
    	SUM(soh.SubTotal) AS Total

FROM 
	Address a
	INNER JOIN 
		SalesOrderHeader soh
		ON soh.ShipToAddressID = a.AddressID

GROUP BY CountryRegion
ORDER BY Total DESC;

/* QUESTION 5
Find the best customer in each region. */

SELECT 
	t.CompanyName, 
    	t.CountryRegion, 
    	t.Total

FROM (
	SELECT 
		c.CompanyName, 
        	a.CountyRegion AS CountryRegion, 
        	SUM(soh.SubTotal) AS Total
        
	FROM 
		Address a
		INNER JOIN 
			SalesOrderHeader soh
			ON soh.ShipToAddressID = a.AddressID
		INNER JOIN 
			Customer c
			ON soh.CustomerID = c.CustomerID

	GROUP BY CompanyName, CountryRegion
	) AS t
    
	INNER JOIN (
		SELECT 
			r.CountryRegion, 
            		MAX(r.Total) AS MaxRegion
            
		FROM (
			SELECT 
				c.CompanyName, 
                		a.CountyRegion AS CountryRegion, 
                		SUM(soh.SubTotal) AS Total
			
            FROM 
				Address a
				INNER JOIN 
					SalesOrderHeader soh
					ON soh.ShipToAddressID = a.AddressID
				INNER JOIN 
					Customer c
					ON soh.CustomerID = c.CustomerID
			GROUP BY CompanyName, CountryRegion
			) AS r

		GROUP BY CountryRegion
        ) AS t2

		ON t.Total=t2.MaxRegion
