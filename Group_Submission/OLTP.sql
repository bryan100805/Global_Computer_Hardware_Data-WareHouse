USE CompAccInc_OLTPTeamBryan;

-- Drop Tables if currently exist
DROP TABLE IF EXISTS Inventories;
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Product_Categories;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Contacts;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Warehouses;
DROP TABLE IF EXISTS Locations;
DROP TABLE IF EXISTS Countries;
DROP TABLE IF EXISTS Regions;

-- Creation of Tables
CREATE TABLE Regions (
    Region_ID INT NOT NULL,
    Region_Name VARCHAR(50) NOT NULL,
    PRIMARY KEY (Region_ID)
)

CREATE TABLE Countries (
    Country_ID VARCHAR(2) NOT NULL,
    Country_Name VARCHAR(50) NOT NULL,
    Region_ID INT NOT NULL,
    PRIMARY KEY (Country_ID),
    FOREIGN KEY (Region_ID) REFERENCES Regions(Region_ID)
)

CREATE TABLE Locations (
    Location_ID INT NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Postal_Code VARCHAR(255) NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NULL,
    Country_ID VARCHAR(2) NOT NULL,
    PRIMARY KEY (Location_ID),
    FOREIGN KEY (Country_ID) REFERENCES Countries(Country_ID)
)

CREATE TABLE Warehouses (
    Warehouse_ID INT NOT NULL,
    Warehouse_Name VARCHAR(50) NOT NULL,
    Location_ID INT NOT NULL,
    PRIMARY KEY (Warehouse_ID),
    FOREIGN KEY (Location_ID) REFERENCES Locations(Location_ID)
)

CREATE TABLE Customers (
    Customer_ID INT NOT NULL,
    Name VARCHAR(50) NOT NULL,
    Address VARCHAR(255) NOT NULL,
	Website VARCHAR(255) NOT NULL,
    Credit_Limit INT NOT NULL,
    PRIMARY KEY (Customer_ID)
)

CREATE TABLE Contacts (
    Contact_ID INT NOT NULL,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Customer_ID INT NOT NULL,
    PRIMARY KEY (Contact_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
)

CREATE TABLE Employees (
    Employee_ID INT NOT NULL,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Hire_Date DATE NOT NULL,
    Manager_ID INT,
    Job_Title VARCHAR(50) NOT NULL,
    PRIMARY KEY (Employee_ID),
    FOREIGN KEY (Manager_ID) REFERENCES Employees(Employee_ID)
)

CREATE TABLE Orders (
    Order_ID INT NOT NULL,
    Customer_ID INT NOT NULL,
    Status VARCHAR(30) NOT NULL,
    Salesman_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    PRIMARY KEY (Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Salesman_ID) REFERENCES Employees(Employee_ID)
)

CREATE TABLE Product_Categories (
    Category_ID INT NOT NULL,
    Category_Name VARCHAR(50) NOT NULL,
    PRIMARY KEY (Category_ID)
)

CREATE TABLE Products (
    Product_ID INT NOT NULL,
    Product_Name VARCHAR(50) NOT NULL,
    Description VARCHAR(255) NOT NULL,
    Standard_Cost INT NOT NULL,
    List_Price INT NOT NULL,
    Category_ID INT NOT NULL,
    PRIMARY KEY (Product_ID),
    FOREIGN KEY (Category_ID) REFERENCES Product_Categories(Category_ID)
)

CREATE TABLE Order_Items (
    Order_ID INT NOT NULL,
    Item_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Unit_Price INT NOT NULL,
    PRIMARY KEY (Order_ID, Item_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
)

CREATE TABLE Inventories (
    Product_ID INT NOT NULL,
    Warehouse_ID INT NOT NULL,
    Quantity INT NOT NULL,
    PRIMARY KEY (Product_ID, Warehouse_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Warehouse_ID) REFERENCES Warehouses(Warehouse_ID),
)