-- user hotel_db
USE  hotel_db;

-- Data for the Guests table (10 rows)
INSERT INTO Guests (GuestID, FirstName, LastName, Phone)
VALUES
    (1, 'John', 'William', 'Doe', '123-456-7890'),
    (2, 'Jane', 'Marie', 'Smith', '987-654-3210'),
    (3, 'Alice', 'Grace', 'Johnson', '555-555-5555'),
    (4, 'David', 'Lee', 'Wilson', '111-222-3333'),
    (5, 'Emma', 'Louise', 'Brown', '444-555-6666'),
    (6, 'James', 'Michael', 'Lee', '777-888-9999'),
    (7, 'Sarah', 'Elizabeth', 'Clark', '888-888-8888'),
    (8, 'Michael', 'Thomas', 'Taylor', '999-999-9999'),
    (9, 'Olivia', 'Rose', 'Roberts', '777-777-7777'),
    (10, 'William', 'Joseph', 'Anderson', '555-444-3333');

-- Data for the Rooms table (10 rows)
INSERT INTO Rooms (RoomID, RoomNumber, RoomType, PricePerNight)
VALUES
    (1, '101', 'Single', 100.00),
    (2, '102', 'Double', 150.00),
    (3, '103', 'Suite', 200.00),
    (4, '201', 'Single', 100.00),
    (5, '202', 'Double', 150.00),
    (6, '203', 'Suite', 200.00),
    (7, '301', 'Single', 100.00),
    (8, '302', 'Double', 150.00),
    (9, '303', 'Suite', 200.00),
    (10, '401', 'Single', 100.00),
    (11, '402', 'Deluxe', 250.00),
    (12, '403', 'Single', 100.00),
    (13, '404', 'Double', 150.00),
    (14, '501', 'Deluxe', 250.00),
    (15, '502', 'Deluxe', 250.00);

-- Data for the Reservations table (10 rows)
INSERT INTO Reservations (ReservationID, GuestID, RoomID, CheckInDate, CheckOutDate)
VALUES
    (1, 1, 1, '2023-01-10', '2023-01-15'),
    (2, 2, 2, '2023-02-05', '2023-02-10'),
    (3, 3, 3, '2023-03-20', '2023-03-25'),
    (4, 4, 4, '2023-04-15', '2023-04-20'),
    (5, 5, 5, '2023-05-10', '2023-05-15'),
    (6, 6, 6, '2023-06-05', '2023-06-10'),
    (7, 7, 7, '2023-07-20', '2023-07-25'),
    (8, 8, 8, '2023-08-15', '2023-08-20'),
    (9, 9, 9, '2023-09-10', '2023-09-15'),
    (10, 10, 10, '2023-10-05', '2023-10-10'),
	(11, 6, 6, '2023-10-10', '2023-10-15');
    

-- Data for the Services table (10 rows)
INSERT INTO Services (ServiceID, ServiceName, ServiceCost)
VALUES
    (1, 'Room Service', 25.00),
    (2, 'Laundry', 15.00),
    (3, 'Airport Shuttle', 30.00),
    (4, 'Spa', 50.00),
    (5, 'Concierge', 10.00),
    (6, 'Parking', 20.00),
    (7, 'Restaurant', 40.00),
    (8, 'Gym', 20.00),
    (9, 'Housekeeping', 15.00),
    (10, 'Wi-Fi', 5.00);

-- Data for the GuestServices table (10 rows)
INSERT INTO GuestServices (GuestServiceID, GuestID, ServiceID, ServiceDate)
VALUES
    (1, 1, 1, '2023-01-12'),
    (2, 2, 2, '2023-02-07'),
    (3, 3, 3, '2023-03-23'),
    (4, 4, 4, '2023-04-18'),
    (5, 5, 5, '2023-05-12'),
    (6, 6, 6, '2023-06-07'),
    (7, 7, 7, '2023-07-24'),
    (8, 8, 8, '2023-08-17'),
    (9, 9, 9, '2023-09-13'),
    (10, 10, 10, '2023-10-08');