------------------- Stock -----------------------
DELETE FROM Stocks

INSERT INTO 
	CompAccInc_DWTeamBryan..Stocks(Product_ID, Stocks)
SELECT 
    Product_ID, 
    SUM(Quantity) AS Stocks
FROM 
    CompAccInc_OLTPTeamBryan..[Inventories]
GROUP BY Product_ID;
--------------------------------------------------

------------- Employees_DIM -------------
DELETE FROM Employees_DIM

INSERT INTO 
    CompAccInc_DWTeamBryan..Employees_DIM(Employee_ID, First_Name, Last_Name, Email, Phone, Hire_Date, Manager_ID, Job_Title)
SELECT
    Employee_ID, First_Name, Last_Name, Email, Phone, Hire_Date, Manager_ID, Job_Title
FROM
    CompAccInc_OLTPTeamBryan..Employees

-----------------------------------------

------------- Categories_DIM -------------
DELETE FROM Categories_DIM

INSERT INTO
    CompAccInc_DWTeamBryan..Categories_DIM(Category_ID, Category_Name)
SELECT
    Category_ID, Category_Name
FROM
    CompAccInc_OLTPTeamBryan..Product_Categories

-----------------------------------------

------------- Products_DIM -------------
DELETE FROM Products_DIM

INSERT INTO
    CompAccInc_DWTeamBryan..Products_DIM(Product_ID, Product_Name, Stocks, Description, Category_ID)
SELECT
    p.Product_ID, p.Product_Name, ISNULL(s.Stocks, 0), p.Description, p.Category_ID
FROM
    CompAccInc_OLTPTeamBryan..Products p
LEFT JOIN 
    CompAccInc_DWTeamBryan..Stocks s
ON p.Product_ID = s.Product_ID;

-----------------------------------------

------------- Customers_DIM -------------
DELETE FROM Customers_DIM

INSERT INTO
    CompAccInc_DWTeamBryan..Customers_DIM(Customer_ID, CustName, Address, Website, Credit_Limit, Contact_first_name, Contact_last_name, email, phone)
SELECT
    cu.Customer_ID, cu.Name, cu.Address, cu.Website, cu.Credit_Limit, co.First_Name, co.Last_Name, co.Email, co.Phone
FROM
    CompAccInc_OLTPTeamBryan..Customers cu
    JOIN CompAccInc_OLTPTeamBryan..Contacts co 
    ON cu.Customer_ID = co.Customer_ID
-----------------------------------------

------------- Orders_DIM ----------------
DELETE FROM Orders_DIM

INSERT INTO 
    CompAccInc_DWTeamBryan..Orders_DIM(Order_ID, Status, Order_Date)
SELECT 
    Order_ID, Status, Order_Date 
FROM 
    CompAccInc_OLTPTeamBryan..Orders
--------------------------------------------

------------- Time_DIM -------------------
DECLARE @StartDate DATETIME = '20130101' --Starting value of Date Range
DECLARE @EndDate DATETIME = '20301231' --End Value of Date Range

DECLARE @curDate DATE
DECLARE @FirstDayMonth DATE
DECLARE @QtrMonthNo INT
DECLARE @FirstDayQtr DATE

SET @curdate = @StartDate

WHILE @curDate < @EndDate 
BEGIN		   
    SET @FirstDayMonth = DATEFROMPARTS(YEAR(@curDate), MONTH(@curDate), '01')
    SET @QtrMonthNo = ((DATEPART(QUARTER, @CurDate) - 1) * 3) + 1 
    SET @FirstDayQtr = DATEFROMPARTS(YEAR(@curDate), @QtrMonthNo, '01')

    INSERT INTO Time_DIM (Time_ID, Year, Quarter, Month, Date, Day, DayOfWeek)
    SELECT 
        CONVERT(CHAR(8), @curDate, 112) AS Time_ID,
        DATEPART(YEAR, @curDate) AS Year,
        DATEPART(QUARTER, @curDate) AS Quarter,
        DATEPART(MONTH, @curDate) AS Month,
        @CurDate AS Date,
        DATEPART(DAY, @curDate) AS Day,
        DATENAME(WEEKDAY, @curDate) AS DayOfWeek

    -- Increase @curDate by 1 day
    SET @curDate = DATEADD(DAY, 1, @curDate)
END
--------------------------------------------

------------- Sales_Fact ------------------
DELETE FROM Sales_Fact

INSERT INTO CompAccInc_DWTeamBryan..Sales_Fact
(
	Customer_ID, 
	Employee_ID, 
	Item_ID, 
	Order_ID, 
	Product_ID, 
	Time_ID,
	Quantity,
	Unit_Price,
	List_Price,
	Standard_Cost)
SELECT 
	c.Customer_ID,
	e.Employee_ID,
	oi.Item_ID,
	o.Order_ID,
	p.Product_ID,
	REPLACE(CONVERT(DATE, o.Order_Date, 111), '-', ''),
	oi.Quantity,
	oi.Unit_Price,
	p.List_Price,
	p.Standard_Cost
FROM CompAccInc_OLTPTeamBryan..[Order_Items] oi 
INNER JOIN CompAccInc_OLTPTeamBryan..[Orders] o ON oi.Order_ID = o.Order_ID
INNER JOIN CompAccInc_OLTPTeamBryan..[Products] p ON p.Product_ID = oi.Product_ID
INNER JOIN CompAccInc_DWTeamBryan..[Customers_DIM] c ON o.Customer_ID = c.Customer_ID
INNER JOIN CompAccInc_DWTeamBryan..[Employees_DIM] e ON o.Salesman_ID = e.Employee_ID
INNER JOIN CompAccInc_DWTeamBryan..[Orders_DIM] odim ON odim.Order_ID = o.Order_ID
INNER JOIN CompAccInc_DWTeamBryan..[Products_DIM] pdim ON pdim.Product_ID = oi.Product_ID
INNER JOIN CompAccInc_DWTeamBryan..[Time_DIM] t ON CONVERT(DATE, o.Order_Date, 111) = t.Date;
--------------------------------------------