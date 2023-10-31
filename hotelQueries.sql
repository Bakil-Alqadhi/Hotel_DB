-- create a new database 
CREATE DATABASE hotel_db;

-- use the newly created db
USE hotel_db;

-- create new Guests table  
CREATE TABLE Guests(
	GuestID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50) NOT NULL, 
	LastName VARCHAR(50) NOT NULL, 
    Phone VARCHAR(20) NOT NULL
);

-- create new rooms table  
CREATE TABLE Rooms(
	RoomID INT PRIMARY KEY,
	RoomNumber VARCHAR(10) UNIQUE NOT NULL,
    RoomType VARCHAR(50) NOT NULL,
    PricePerNight DECIMAL(10, 2) 
);

-- create new Reservations table  
CREATE TABLE Reservations(
	ReservationID INT PRIMARY KEY,
    GuestID INT NOT NULL,
    RoomID INT NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    FOREIGN KEY (GuestID) REFERENCES Guests(GuestID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID) 
);

-- create new Services table  
CREATE TABLE Services (
   ServiceID INT PRIMARY KEY,
   ServiceName VARCHAR(100) NOT NULL,
   ServiceCost DECIMAL(10, 2) NOT NULL
);

-- create GuestServices table 
CREATE TABLE GuestServices (
   GuestServiceID INT PRIMARY KEY,
   GuestID INT NOT NULL,
   ServiceID INT NOT NULL,
   ServiceDate DATE NOT NULL,
   FOREIGN KEY (GuestID) REFERENCES Guests(GuestID),
   FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);