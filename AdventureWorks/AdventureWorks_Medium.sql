/* AdventureWorks Medium Questions, from:
http://sqlzoo.net/wiki/AdventureWorks_medium_questions */

/* QUESTION 6
A "Single Item Order" is a customer order where only one item is ordered. 
Show the SalesOrderID and the UnitPrice for every Single Item Order. */

SELECT 
	SalesOrderID, 
    	UnitPrice
FROM 
	SalesOrderDetail
WHERE 
	OrderQty = 1;
    
/* QUESTION 7
Where did the racing socks go? List the product name and the CompanyName for 
all Customers who ordered ProductModel 'Racing Socks'. */

SELECT 
	c.CompanyName, 
    	p.Name
    
FROM 
	Customer c
	INNER JOIN 
		SalesOrderHeader soh
		ON soh.CustomerID = c.CustomerID
	INNER JOIN
		SalesOrderDetail sod
		ON sod.SalesOrderID = soh.SalesOrderID
	INNER JOIN 
		Product p
		ON sod.ProductID = p.ProductID
	INNER JOIN 
		ProductModel pm
		ON p.ProductModelID = pm.ProductModelID
        
WHERE 
	pm.Name = 'Racing Socks'   
    
ORDER BY c.CompanyName;

/* QUESTION 8
Show the product description for culture 'fr' for product with ProductID 736. */

SELECT 
	p.ProductID, 
	p.Name, 
    	pd.Description, 
    	pmpd.Culture
    
FROM 
	Product p
	INNER JOIN 
		ProductModel pm
		ON pm.ProductModelID = p.ProductModelID
	INNER JOIN 
		ProductModelProductDescription pmpd
		ON pmpd.ProductModelID = pm.ProductModelID
	INNER JOIN 
		ProductDescription pd
		ON pd.ProductDescriptionID = pmpd.ProductDescriptionID

WHERE 
	p.ProductID = 736 
    	AND pmpd.Culture = 'fr';
    
/* QUESTION 9
Use the SubTotal value in SaleOrderHeader to list orders from the 
largest to the smallest. For each order show the CompanyName and the 
SubTotal and the total weight of the order. */

SELECT 
	c.CompanyName, 
    	soh.SubTotal, 
    	SUM(sod.OrderQty*p.Weight) AS Weight
    
FROM 
	Customer c
	INNER JOIN 
		SalesOrderHeader soh
		ON soh.CustomerID = c.CustomerID
	INNER JOIN 
		SalesOrderDetail sod
		ON sod.SalesOrderID = soh.SalesOrderID
	INNER JOIN 
		Product p
		ON p.ProductID = sod.ProductID

GROUP BY 
	c.CompanyName, soh.SubTotal

ORDER BY SubTotal DESC;

/* QUESTION 10
How many products in ProductCategory 'Cranksets' have been sold 
to an address in 'London'? */

SELECT 
	SUM(sod.OrderQty) AS Total
FROM 
	ProductCategory pc
	INNER JOIN 
		Product p
		ON p.ProductCategoryID = pc.ProductCategoryID
	INNER JOIN
		SalesOrderDetail sod
		ON p.ProductID = sod.ProductID
	INNER JOIN 
		SalesOrderHeader soh
		ON sod.SalesOrderID = soh.SalesOrderID
	INNER JOIN 
		Address a
		ON a.AddressID = soh.ShipToAddressID

WHERE 
	a.City LIKE '%London%' 
	AND pc.Name = 'Cranksets';
