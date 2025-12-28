--exec ProcessStagingToNormalized

use Lumel
go
CREATE PROCEDURE ProcessStagingToNormalized
AS
BEGIN
    SET NOCOUNT ON;
    --Create staging table
    If not exists(select * from sys.tables where name = 'Staging_Import')
    BEGIN
        CREATE TABLE Staging_Import (
        OrderID INT,
        ProductID VARCHAR(20),
        CustomerID VARCHAR(20),
        ProductName VARCHAR(200),
        Category VARCHAR(100),
        Region VARCHAR(100),
        DateOfSale VARCHAR(20), -- Imported as string to handle format conversion
        QuantitySold INT,
        UnitPrice DECIMAL(10, 2),
        Discount Float,
        ShippingCost Float,
        PaymentMethod VARCHAR(50),
        CustomerName VARCHAR(200),
        CustomerEmail VARCHAR(200),
        CustomerAddress TEXT
        );
    END
    --Clear Table data before import
    delete from Staging_Import;
    --Read CSV file and import into staging table
    BULK INSERT Staging_Import
    FROM 'C:\Users\Gayathri\OneDrive\Documents\Lumel\SalesData.csv' 
    WITH (
        FIRSTROW = 2,           -- Skips header
        FIELDTERMINATOR = ',',  -- CSV delimiter
        ROWTERMINATOR = '\n',   -- New line
        TABLOCK
    );
    -----------------Insert data from the staging table sequestially into respective tables without duplicates------------
    -- 1. Categories
    INSERT INTO ProductCategory (CategoryName)
    SELECT DISTINCT Category FROM Staging_Import
    WHERE Category NOT IN (SELECT CategoryName FROM ProductCategory);

    -- 2. Products
    INSERT INTO Product (ProductCode, ProductName, CategoryID, UnitPrice)
    SELECT DISTINCT s.ProductID, s.ProductName, c.CategoryID, s.UnitPrice
    FROM Staging_Import s
    JOIN ProductCategory c ON s.Category = c.CategoryName
    WHERE s.ProductID NOT IN (SELECT ProductCode FROM Product);

    -- 3. Customers
    INSERT INTO Customer (CustomerCode, CustomerName, CustomerEmail)
    SELECT DISTINCT CustomerID, CustomerName, CustomerEmail FROM Staging_Import
    WHERE CustomerID NOT IN (SELECT CustomerCode FROM Customer);

    SET IDENTITY_INSERT Orders ON
    -- 4. Orders (Assuming Date format in CSV is DD-MM-YYYY)
    INSERT INTO Orders (OrderID, CustomerID, OrderDate, Region, ShippingCost)
    SELECT DISTINCT s.OrderID, c.CustomerId, CONVERT(DATE, s.DateOfSale, 105), s.Region, s.ShippingCost 
    FROM Staging_Import s
    JOIN Customer c ON s.CustomerId = c.CustomerCode
    WHERE s.OrderID NOT IN (SELECT OrderID FROM Orders);
    set  IDENTITY_INSERT Orders off

    -- 5. Order Details
    INSERT INTO OrderDetails (OrderID, ProductID, QuantitySold, Discount)
    SELECT s.OrderID, p.ProductID, s.QuantitySold, s.Discount
    FROM Staging_Import s
    JOIN Product p ON s.ProductID = p.ProductCode;

    -- 6. Payment
    INSERT INTO PaymentMaster (PaymentMethodName)
    SELECT DISTINCT PaymentMethod FROM Staging_Import
    WHERE PaymentMethod NOT IN (SELECT PaymentMethodName FROM PaymentMaster);

    INSERT INTO PaymentDetails (OrderID, PaymentMethodID)
    SELECT s.OrderID, pm.PaymentMethodID
    FROM Staging_Import s
    JOIN PaymentMaster pm ON s.PaymentMethod = pm.PaymentMethodName;
END;