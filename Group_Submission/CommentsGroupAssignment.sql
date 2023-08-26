--Query 1
-- Identify the top 3 earners and lowest 3 earners based on the total sales amount, retrieve percentage of sales for each employee as 2 separate subqueries. Results of 2 subqueries are joined with UNION ALL
-- First subquery(q1): Find the top earners by calculating the total sales amount and percentage of total sales
-- for each employee and orders the results in descending order based on total sales amount
SELECT
    'Top Earner' AS Earner_Type,
    q1.Staff_Name,
    q1.Total_Sales_Amount,
    q1.Percentage_of_Total_Sales
FROM
    (SELECT
        e.First_Name + ' ' + e.Last_Name AS Staff_Name,
        SUM(sf.Unit_Price * sf.Quantity) AS Total_Sales_Amount,
        CAST((SUM(sf.Unit_Price * sf.Quantity) * 100.0 / t.Total_Sales) AS decimal(7, 2)) AS Percentage_of_Total_Sales
    FROM
        Sales_Fact sf
        --Normal inner join sales fact table and employee table
        INNER JOIN Employees_DIM e ON sf.Employee_ID = e.Employee_ID
        --Cartesian product to calculate the total sales for each employee, store in alias t
        CROSS JOIN (
            SELECT SUM(sf2.Unit_Price * sf2.Quantity) AS Total_Sales
            FROM Sales_Fact sf2
        ) t
    --Group results based on employee first name, last name and total sales
    GROUP BY
        e.First_Name,
        e.Last_Name,
        t.Total_Sales
    ORDER BY
        Total_Sales_Amount DESC

    --Limit the results to top 3 earners in q1 and lowest 3 earners in q2
    --No rows are skipped
    OFFSET 0 ROWS
    --Query should return the next 3 rows in the result set
    FETCH NEXT 3 ROWS ONLY) AS q1

-- Combine the results of the two subqueries into a single result
UNION ALL

-- Second subquery(q2): Find the top earners by calculating the total sales amount and percentage of total sales
-- for each employee and orders the results in ascending order based on total sales amount
SELECT
    'Lowest Earner' AS Earner_Type,
    q2.Staff_Name,
    q2.Total_Sales_Amount,
    q2.Percentage_of_Total_Sales
FROM
    (SELECT
        e.First_Name + ' ' + e.Last_Name AS Staff_Name,
        SUM(sf.Unit_Price * sf.Quantity) AS Total_Sales_Amount,
        CAST((SUM(sf.Unit_Price * sf.Quantity) * 100.0 / t.Total_Sales) AS decimal(7, 2)) AS Percentage_of_Total_Sales
    FROM
        Sales_Fact sf
        --Normal inner join sales fact table and employee table
        INNER JOIN Employees_DIM e ON sf.Employee_ID = e.Employee_ID
        --Cartesian product to calculate the total sales for each employee, store in alias t
        CROSS JOIN (
            SELECT SUM(sf2.Unit_Price * sf2.Quantity) AS Total_Sales
            FROM Sales_Fact sf2
        ) t
    --Group results based on employee first name, last name and total sales
    GROUP BY
        e.First_Name,
        e.Last_Name,
        t.Total_Sales
    ORDER BY
        Total_Sales_Amount ASC
    OFFSET 0 ROWS
    FETCH NEXT 3 ROWS ONLY) AS q2;

--Query 2
-- Retrieves the total yearly earnings, identifies the best and worst sales month with the respective sales amount for each year and sorted by the year
-- Outer Query
-- Uses DATENAME and DATEADD to convert the numeric months into the respective month names
SELECT
    Sales_Year,
    Total_Yearly_Earnings,
    DATENAME(MONTH, DATEADD(MONTH, Best_Sales_Month - 1, '2000-01-01')) AS Best_Sales_Month,
    Best_Month_Sales_Amount,
    DATENAME(MONTH, DATEADD(MONTH, Worst_Sales_Month - 1, '2000-01-01')) AS Worst_Sales_Month,
    Worst_Month_Sales_Amount
FROM (
    --2nd inner subquery
    --Groups data from Monthly Sales subquery by Sales_Year
    --Calculates Total Yearly Earnings by summing up the Monthly Sales Amount for each year
    --Retrieves the best and worst sales month with CASE...WHEN...THEN...
    SELECT
        Sales_Year,
        SUM(Monthly_Sales_Amount) AS Total_Yearly_Earnings,
        MAX(CASE WHEN Monthly_Sales_Amount = MaxSalesAmount THEN Sales_Month END) AS Best_Sales_Month,
        MAX(Monthly_Sales_Amount) AS Best_Month_Sales_Amount,
        MAX(CASE WHEN Monthly_Sales_Amount = MinSalesAmount THEN Sales_Month END) AS Worst_Sales_Month,
        MIN(Monthly_Sales_Amount) AS Worst_Month_Sales_Amount
    FROM (
        --1st inner subquery
        --Aggregates monthly sales data by year and month to find max and min sales amount for each year
        SELECT
            YEAR(t.Date) AS Sales_Year,
            MONTH(t.Date) AS Sales_Month,
            SUM(sf.Unit_Price * sf.Quantity) AS Monthly_Sales_Amount,
            MAX(SUM(sf.Unit_Price * sf.Quantity)) OVER (PARTITION BY YEAR(t.Date)) AS MaxSalesAmount,
            MIN(SUM(sf.Unit_Price * sf.Quantity)) OVER (PARTITION BY YEAR(t.Date)) AS MinSalesAmount
        FROM
            Sales_Fact sf
            INNER JOIN Time_DIM t ON sf.Time_ID = t.Time_ID
        GROUP BY
            YEAR(t.Date), MONTH(t.Date)
    ) AS MonthlySales
    GROUP BY Sales_Year
) AS YearlySales
ORDER BY Sales_Year;

--Query 3
--Retrieves the details of the pending orders with the earliest order date and provide info about the products in the orders
--Including the total sales amount for each product and the quantity sold
--Sorted by earliest order date and sales revenue in descending order
SELECT o.Order_ID, p.Product_Name, p.Description, SUM(sf.Unit_Price * sf.Quantity) AS Product_Sales_Amount, 
	SUM(sf.Quantity) AS Amount_Sold, o.Status
FROM
    Orders_DIM o
    INNER JOIN Sales_Fact sf ON sf.Order_ID = o.Order_ID
    INNER JOIN Products_DIM p ON sf.Product_ID = p.Product_ID
WHERE
    o.Status = 'Pending' and 
	o.Order_Date = (
		SELECT MIN(Order_Date)
		FROM Orders_DIM
		WHERE Status = 'PENDING')
GROUP BY
    o.Order_ID, p.Product_Name,	p.Description, o.Order_Date, o.Status
ORDER BY
	o.Order_Date, SUM(sf.Unit_Price * sf.Quantity) DESC;

--Query 4

WITH RankedProducts AS (
	SELECT 
		ca.Category_Name, p.Product_Name, cu.CustName AS Customer_Name, cu.Address ,SUM(sf.Quantity * sf.Unit_Price) AS Sales_Revenue, 
		ROW_NUMBER() OVER (PARTITION BY ca.Category_Name ORDER BY SUM(sf.Quantity * sf.Unit_Price) DESC) AS Rank
	FROM Sales_Fact sf
	INNER JOIN Customers_DIM cu ON cu.Customer_ID = sf.Customer_ID
    INNER JOIN Products_DIM p ON sf.Product_ID = p.Product_ID
	INNER JOIN Categories_DIM ca ON ca.Category_ID = p.Category_ID
GROUP BY 
	ca.Category_Name,
	p.Product_Name,
	cu.CustName,
	cu.Address
)

SELECT Category_Name, Product_Name, Customer_Name, Address, Sales_Revenue
FROM RankedProducts
WHERE Rank <=3
ORDER BY Category_Name, Rank;

--Query 5--
-- Retrieves sales and profitability trends for the top 3 products based on the profit
-- Provide info about each product name, number of inventory, total sales, selling price, cost price and profit and sales trend
--Common table expression
WITH ProfitInfo AS (
    SELECT
        t.Year,
        DateName(month , DateAdd(month , t.Month , 0) - 1 ) AS 'Month',
		t.day,
        p.Product_Name,
        s.Stocks,
        sf.Quantity AS TotalSales,
        sf.Unit_Price AS Selling_Price,
        sf.Standard_Cost AS Cost_Price,
        (sf.Unit_Price * sf.Quantity) - (sf.Standard_Cost * s.Stocks) AS Profit,
        t.Date,
		--Row Number assigns row numbers within each product group based on the date
        ROW_NUMBER() OVER (PARTITION BY p.Product_ID ORDER BY t.Date) AS RowNum
    FROM
        Products_DIM p
    INNER JOIN
        Stocks s ON p.Product_ID = s.Product_ID
    INNER JOIN
        Sales_Fact sf ON p.Product_ID = sf.Product_ID
    INNER JOIN
        Time_DIM t ON sf.Time_ID = t.Time_ID
)

--Main Query
--Extract the top 3 products based on profit
SELECT
	Product_Name,
    Year,
    Month,
	Day,
    Stocks AS 'Stock of Components',
    TotalSales AS 'Sales',
    Selling_Price AS 'Selling Price',
    Cost_Price AS 'Cost Price',
    Profit,
	--LAG Window Function: difference between total sales of current row and total sales of previous row
	TotalSales - LAG(TotalSales, 1, 0) OVER (PARTITION BY Product_Name ORDER BY Date) AS 'Sales Trend'
FROM
    ProfitInfo
WHERE
    Product_Name IN (
        SELECT TOP 3 Product_Name
        FROM ProfitInfo
        WHERE RowNum > 1 -- Excluding the first row to calculate the sales trend correctly
        GROUP BY Product_Name
        ORDER BY SUM(Profit) DESC
    )
ORDER BY
    Product_Name, Year, MONTH(Month+'1,1');