-- Week2 - Adding Sales Report
-- Task 1: Create View

CREATE VIEW OrdersView AS
SELECT OrderID, Quantity, TotalCost AS Cost
FROM Orders
WHERE Quantity > 2;


SELECT * FROM OrdersView;

-- Task 2:
-- For your second task, Little Lemon need information 
-- from four tables on all customers with orders that cost more than $150. 
-- Extract the required information from each of the following tables by using the relevant JOIN clause: 
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
Menus.MenuItemsID=MenuItems.MenuItemsID
WHERE Orders.TotalCost>150;


-- Task 3: Little Lemon need you to find all menu items for 
-- which more than 2 orders have been placed

SELECT MenuName
FROM Menus
WHERE MenuID = ANY (
    SELECT MenuID
    FROM Orders
    GROUP BY MenuID
    HAVING COUNT(OrderID) > 2
);

-- Exercise: Create optimized queries to manage and analyze data
-- Task 1:
-- GetMaxQuantity

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

-- Task 2:
-- Little Lemon need you to help them to create a prepared statement called GetOrderDetail

-- Create the prepared statement
SET @sql = 'SELECT OrderID, Quantity, TotalCost FROM Orders WHERE CustomerID = ?';
PREPARE GetOrderDetail FROM @sql;

-- Create a variable id and assign it a value of 1
SET @id = 1;

-- Execute the prepared statement
EXECUTE GetOrderDetail USING @id;

-- Deallocate the prepared statement
DEALLOCATE PREPARE GetOrderDetail;


-- Taks 3:
--  create a stored procedure called CancelOrder.

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


-- Create CheckBooking stored procedure
DELIMITER //

CREATE PROCEDURE CheckBooking (
    IN p_BookingDate DATE,
    IN p_TableNumber VARCHAR(255),
    OUT v_Status VARCHAR(50)
)
BEGIN
    DECLARE booking_count INT;

    -- Check if the table is already booked
    SELECT COUNT(*)
    INTO booking_count
    FROM Bookings
    WHERE BookingDate = p_BookingDate AND TableNumber = p_TableNumber;

    -- Set the status based on the booking count
    IF booking_count > 0 THEN
        SET v_Status = 'Table is already booked';
    ELSE
        SET v_Status = 'Table is available';
    END IF;
END //

DELIMITER ;


-- Call CheckBooking procedure
SET @status = '';

CALL CheckBooking('2022-10-10', '5', @status);
SELECT @status AS Status;

-- Create AddValidBooking stored procedure
DELIMITER //

CREATE PROCEDURE AddValidBooking (
    IN p_BookingDate DATE,
    IN p_TableNumber VARCHAR(255),
    IN p_StaffID INT,
    IN p_StaffName VARCHAR(255)
)
BEGIN
    DECLARE booking_count INT;

    -- Start a transaction
    START TRANSACTION;

    -- Add a new booking record
    INSERT INTO Staff (StaffID, StaffName)
    VALUES (p_StaffID, p_StaffName);
    INSERT INTO Bookings (BookingDate, TableNumber, StaffID)
    VALUES (p_BookingDate, p_TableNumber, p_StaffID);

    -- Check if the table is already booked on the given date
    SELECT COUNT(*)
    INTO booking_count
    FROM Bookings
    WHERE BookingDate = p_BookingDate AND TableNumber = p_TableNumber AND StaffID=p_StaffID;

    -- Rollback if the table is already booked, otherwise commit the transaction
    IF booking_count > 1 THEN
        -- Rollback the transaction
        ROLLBACK;
        SELECT 'Booking declined. Table already booked.' AS Status;
    ELSE
        -- Commit the transaction
        COMMIT;
        SELECT 'Booking successful.' AS Status;
    END IF;
END //

DELIMITER ;


CALL AddValidBooking('2022-10-10', '5',6,'Manager-3');

-- Create AddBooking stored procedure
DELIMITER //

CREATE PROCEDURE AddBooking (
    IN p_BookingID INT,
	IN p_BookingDate DATE,
    IN p_TableNumber VARCHAR(255),
    IN p_StaffID INT,
    IN p_StaffName VARCHAR(255)
)
BEGIN
    -- Add a new booking record
	INSERT INTO Staff (StaffID, StaffName)
    VALUES (p_StaffID, p_StaffName);
    INSERT INTO Bookings (BookingID, StaffID, BookingDate, TableNumber)
    VALUES (p_BookingID, p_StaffID, p_BookingDate, p_TableNumber);

    SELECT 'Booking added successfully.' AS Status;
END //

DELIMITER ;

CALL AddBooking(10,'2022-10-10','Table-5', 10,'Chef-3');

-- Create UpdateBooking stored procedure
DELIMITER //

CREATE PROCEDURE UpdateBooking (
    IN p_BookingID INT,
    IN p_BookingDate DATE
)
BEGIN
    -- Update the booking record based on booking id
    UPDATE Bookings
    SET BookingDate = p_BookingDate
    WHERE BookingID = p_BookingID;

    SELECT 'Booking updated successfully.' AS Status;
END //

DELIMITER ;
CALL UpdateBooking(1, '2022-11-15');

-- Create CancelBooking stored procedure
DELIMITER //

CREATE PROCEDURE CancelBooking (
    IN p_BookingID INT
)
BEGIN
    DECLARE booking_exists INT;

    -- Check if the booking exists
    SELECT COUNT(*) INTO booking_exists
    FROM Bookings
    WHERE BookingID = p_BookingID;

    -- If the booking exists, delete it; otherwise, show an error message
    IF booking_exists > 0 THEN
        -- Delete the booking record based on booking id
        DELETE FROM Bookings
        WHERE BookingID = p_BookingID;

        SELECT 'Booking canceled successfully.' AS Status;
    ELSE
        SELECT 'Booking not found.' AS Status;
    END IF;
END //

DELIMITER ;


CALL CancelBooking(1);









































