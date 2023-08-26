USE CompAccInc_DWTeamBryan;

DROP TABLE IF EXISTS Stocks;
DROP TABLE IF EXISTS Sales_Fact;
DROP TABLE IF EXISTS Time_DIM;
DROP TABLE IF EXISTS Orders_DIM;
DROP TABLE IF EXISTS Customers_DIM;
DROP TABLE IF EXISTS Products_DIM;
DROP TABLE IF EXISTS Categories_DIM;
DROP TABLE IF EXISTS Employees_DIM;

CREATE TABLE Employees_DIM (
    Employee_ID INT PRIMARY KEY NOT NULL,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Hire_Date DATE NOT NULL,
    Manager_ID INT,
    Job_Title VARCHAR(50) NOT NULL,
); 

CREATE TABLE Categories_DIM(
    Category_ID INT PRIMARY KEY NOT NULL,
    Category_Name VARCHAR(50) NOT NULL
);

CREATE TABLE Products_DIM (
    Product_ID INT PRIMARY KEY NOT NULL,
    Product_Name VARCHAR(50) NOT NULL,
    Stocks INT NOT NULL,
    Description VARCHAR(255) NOT NULL,
    Category_ID INT NOT NULL,
    FOREIGN KEY (Category_ID) REFERENCES Categories_DIM(Category_ID),
);

CREATE TABLE Customers_DIM (
    Customer_ID INT PRIMARY KEY NOT NULL,
    CustName VARCHAR(50) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Website VARCHAR(255) NOT NULL, 
    Credit_Limit INT NOT NULL,
    Contact_first_name VARCHAR(50) NOT NULL,
    Contact_last_name VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NOT NULL
);

CREATE TABLE Orders_DIM (
    Order_ID INT PRIMARY KEY NOT NULL,
    Status VARCHAR(30) NOT NULL,
    Order_Date DATE NOT NULL
);

CREATE TABLE Time_DIM (
    Time_ID CHAR(8) PRIMARY KEY NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    Date DATETIME NOT NULL,
    Day INT NOT NULL,
    DayOfWeek VARCHAR(100) NOT NULL
);

CREATE TABLE Sales_Fact (
    Customer_ID INT NOT NULL,
    Employee_ID INT NOT NULL,
    Item_ID INT NOT NULL,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Time_ID CHAR(8) NOT NULL,
    Quantity INT NOT NULL,
    Unit_Price INT NOT NULL,
    List_Price INT NOT NULL,
    Standard_Cost INT NOT NULL,
    PRIMARY KEY (Customer_ID, Employee_ID, Item_ID, Order_ID, Product_ID, Time_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employees_DIM(Employee_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products_DIM(Product_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customers_DIM(Customer_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders_DIM(Order_ID),
    FOREIGN KEY (Time_ID) REFERENCES Time_DIM(Time_ID)
); 

-- Temporary staging area
CREATE TABLE Stocks (
    Product_ID INT NOT NULL,
    Stocks INT NOT NULL,
    PRIMARY KEY (Product_ID)
);

