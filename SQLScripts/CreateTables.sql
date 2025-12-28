If not exists(select * from sys.tables where name = 'ProductCategory')
CREATE TABLE ProductCategory (
    CategoryID INT PRIMARY KEY Identity(1,1),
    CategoryName VARCHAR(100) NOT NULL
);
If not exists(select * from sys.tables where name = 'Product')
CREATE TABLE Product (
    ProductID INT PRIMARY KEY Identity(1,1),
    ProductName VARCHAR(200) NOT NULL,
    CategoryID INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (CategoryID) REFERENCES ProductCategory(CategoryID)
);
If not exists(select * from sys.tables where name = 'Customer')

CREATE TABLE Customer (
    CustomerID int PRIMARY KEY Identity(1,1),
    CustomerName VARCHAR(250) NOT NULL,
    CustomerEmail VARCHAR(250) UNIQUE NOT NULL
);

If not exists(select * from sys.tables where name = 'CustomerAddress')
CREATE TABLE CustomerAddress (
    AddressID INT PRIMARY KEY Identity(1,1),
    CustomerID INT,
    FullAddress TEXT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
If not exists(select * from sys.tables where name = 'Stock')
CREATE TABLE Stock (
    StockID INT PRIMARY KEY Identity(1,1),
    ProductID int,
    QuantityInStock INT DEFAULT 0,
    LastUpdated TIMESTAMP ,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
If not exists(select * from sys.tables where name = 'PaymentMaster')
CREATE TABLE PaymentMaster (
    PaymentMethodID INT PRIMARY KEY Identity(1,1),
    PaymentMethodName VARCHAR(50) -- e.g., 'Credit Card', 'PayPal'
);
If not exists(select * from sys.tables where name = 'Orders')
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE,
    Region VARCHAR(100),
    ShippingCost DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

If not exists(select * from sys.tables where name = 'OrderDetails')
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ProductID INT,
    QuantitySold INT,
    Discount INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);


If not exists(select * from sys.tables where name = 'PaymentDetails')
CREATE TABLE PaymentDetails (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    PaymentMethodID INT,
    PaymentDate TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMaster(PaymentMethodID)
);
If not exists(select * from sys.COLUMNS c join sys.tables t on t.object_id = c.object_id  where c.name = 'ProductCode' and t.name = 'PRODUCT')
ALTER TABLE PRODUCT ADD ProductCode VARCHAR(20)


If not exists(select * from sys.COLUMNS c join sys.tables t on t.object_id = c.object_id  where c.name = 'CustomerCode' and t.name = 'Customer')
ALTER TABLE Customer ADD CustomerCode VARCHAR(20)

alter table OrderDetails alter column discount DECIMAL(10, 2)