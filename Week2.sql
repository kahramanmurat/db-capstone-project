

CREATE VIEW OrdersView AS
SELECT OrderID, Quantity, TotalCost AS Cost
FROM Orders
WHERE Quantity > 2;


SELECT * FROM OrdersView;


SELECT 
Customers.CustomerID, 
Customers.FullName,
Orders.OrderID,
Orders.TotalCost,
Menus.MenuName,
MenuItems.CourseName
FROM Customers 
INNER JOIN Orders ON
Customers.CustomerID=Orders.CustomerID
INNER JOIN Menus ON
Orders.MenuID=Menus.MenuID
INNER JOIN MenuItems ON
Menus.MenuItemsID=MenuItems.MenuItemsID;

SELECT MenuName
FROM Menus
WHERE MenuID = ANY (
    SELECT MenuID
    FROM Orders
    GROUP BY MenuID
    HAVING COUNT(OrderID) > 2
);

DELIMITER //

CREATE PROCEDURE GetMaxQuantity()
BEGIN
    DECLARE maxQuantity INT;

    -- Find the maximum quantity in the Orders table
    SELECT MAX(Quantity) INTO maxQuantity
    FROM Orders;

    -- Display the result
    SELECT 'Maximum Ordered Quantity:' AS Result, maxQuantity AS MaxQuantity;
END //

DELIMITER ;

CALL GetMaxQuantity();

-- Create the prepared statement
SET @sql = 'SELECT OrderID, Quantity, TotalCost FROM Orders WHERE CustomerID = ?';
PREPARE GetOrderDetail FROM @sql;

-- Create a variable id and assign it a value of 1
SET @id = 1;

-- Execute the prepared statement
EXECUTE GetOrderDetail USING @id;

-- Deallocate the prepared statement
DEALLOCATE PREPARE GetOrderDetail;

-- Create the stored procedure
DELIMITER //
CREATE PROCEDURE CancelOrder(IN p_OrderID INT)
BEGIN
    -- Declare a variable to check if the order exists
    DECLARE orderExists INT;

    -- Check if the order exists
    SELECT COUNT(*) INTO orderExists FROM Orders WHERE OrderID = p_OrderID;

    -- If the order exists, delete it
    IF orderExists > 0 THEN
        DELETE FROM Orders WHERE OrderID = p_OrderID;
        SELECT 'Order canceled successfully.' AS Result;
    ELSE
        SELECT 'Order not found.' AS Result;
    END IF;
END //
DELIMITER ;
CALL CancelOrder(4);
SELECT * FROM Orders;












































