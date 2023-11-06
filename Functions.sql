USE hotel_db;

-- 1. Получить доступные номера
-- 	 	Функция должна принимать в качестве входных данных тип номера, дату заезда и дату выезда,
-- 		а возвращать список свободных номеров указанного типа для данного диапазона дат.
 DELIMITER //
DROP FUNCTION IF EXISTS GetAvailableRoomsByTypeAndDates //
CREATE FUNCTION GetAvailableRoomsByTypeAndDates(
	room_type VARCHAR(50), 
	checkInDate DATE,
    checkOutDate DATE
)
RETURNS TEXT
BEGIN 
	DECLARE availabeRooms TEXT;
	
    SELECT GROUP_CONCAT(RoomNumber SEPARATOR ', ') INTO availabeRooms
	FROM Rooms
	WHERE RoomType = room_type
	AND RoomID NOT IN (
		SELECT RoomID FROM Reservations 
			WHERE (
					(checkInDate BETWEEN CheckInDate AND DATE_SUB(CheckOutDate, INTERVAL 1 DAY))
					AND (checkOutDate BETWEEN DATE_ADD(CheckInDate, INTERVAL 1 DAY) AND CheckOutDate)
			)
	);
    RETURN availabeRooms;
END;
//
DELIMITER ;

SELECT  GetAvailableRoomsByTypeAndDates('Deluxe', '2023-10-01', '2023-10-30') AS 'THE ROOMS';
-- -------------------------------------------------------------------------------------------------------------------
-- 2. Расчет выручки по типам номеров за определенный месяц
-- По результатам работы процедуры необходимо вывести таблицу, содержащую типы номеров и 
-- общую сумму полученную по каждому типу номера за определенный месяц
DELIMITER //
DROP PROCEDURE IF EXISTS CalculateRevenueByRoomTypeForMonth //
CREATE PROCEDURE CalculateRevenueByRoomTypeForMonth(
    targetMonth varchar(10)
)
BEGIN
    DECLARE targetDate DATE;
    SET targetDate = CONCAT(YEAR(NOW()), '-', targetMonth, '-01');
    SELECT R.RoomType,
        SUM(
			CASE
				WHEN (RS.CheckInDate >= targetDate AND RS.CheckOutDate < DATE_ADD(targetDate, INTERVAL 1 MONTH) )
					THEN (DATEDIFF(RS.CheckOutDate, RS.CheckInDate) * R.PricePerNight )
				WHEN (RS.CheckInDate < targetDate AND RS.CheckOutDate > targetDate AND RS.CheckOutDate < DATE_ADD(targetDate, INTERVAL 1 MONTH))
					THEN (DATEDIFF(RS.CheckOutDate, targetDate) * R.PricePerNight )
				WHEN (RS.CheckInDate <= targetDate AND RS.CheckOutDate > DATE_ADD(targetDate, INTERVAL 1 MONTH) )
					THEN (DATEDIFF(DATE_SUB(DATE_ADD(targetDate, INTERVAL 1 MONTH ), INTERVAL 1 DAY), targetDate) * R.PricePerNight)
				ELSE 0
			END
        ) AS TotalRevenue
    FROM Reservations RS
	JOIN Rooms R ON R.RoomID = RS.RoomID 
    GROUP BY(R.RoomType); 
END;
//
DELIMITER ;
 CALL CalculateRevenueByRoomTypeForMonth('10');


-- 3. Обновление бронирования
-- 		По идентификатору существующего бронирования и новой дате выезда, необходимо соответствующим образом обновить бронирование.
-- 		Если номер уже забронирован другим гостем на эту же дату необходимо проверить есть ли другие свободные номера этого же типа:
-- 			если да, то перенести бронирование другого гостя в свободный номер, а текущему продлить бронирование, 
-- 			вывести информацию о соответствующих записях в бронировании; если нет, то вывести информацию о свободном номере другого типа (номер, тип, стоимость) 
-- 			наиболее близкого по стоимости к текущему
 DELIMITER //
DROP PROCEDURE IF EXISTS UpdateReservationByIdAndCheckOut //
CREATE PROCEDURE UpdateReservationByIdAndCheckOut(
	bookingID INT, 
    newCheckOutDate DATE
)
BEGIN 
    DECLARE currentRoomType VARCHAR(50);
    DECLARE currentRoomID INT;
    DECLARE newRoomID INT;
	DECLARE currenGuestID INT;
    DECLARE anotherGuestID INT;

    -- Получаем тип и номер текущего бронирования
    SELECT R.RoomType, RS.RoomID, RS.GuestID INTO currentRoomType, currentRoomID, currenGuestID
    FROM Rooms R
    JOIN Reservations RS on  RS.RoomID = R.RoomID
    WHERE ReservationID = bookingID;
    
    -- Проверяем, свободен ли текущий номер на новую дату выезда
    IF NOT EXISTS (
		SELECT 1 
        FROM Reservations 
        WHERE RoomID = currentRoomID
			AND ReservationID != bookingID
            AND CheckInDate <= newCheckOutDate
            AND CheckOutDate >= newCheckOutDate
    ) THEN 
		UPDATE Reservations  SET CheckOutDate = newCheckOutDate WHERE ReservationID = bookingID;
        
		SELECT 'Booking updated: Room is still available.' AS Result;
	ELSE 
		
        SELECT RoomID INTO newRoomID FROM Rooms
        WHERE RoomType = currentRoomType
				AND RoomID NOT IN (
					SELECT RoomID FROM Reservations
                    WHERE  CheckInDate <= newCheckOutDate
                    AND CheckOutDate >= newCheckOutDate
                )
                LIMIT 1;
                
			IF newRoomID IS NOT NULL 
			THEN 
				--  TO GET THE ANOTHER GUEST ID TO ENSURE THAT WE UPDATE THE CORRECT ROW
					SELECT GuestID INTO anotherGuestID 
						FROM Reservations 
						WHERE ReservationID != bookingID 
							AND RoomID = currentRoomID
							AND CheckInDate <= newCheckOutDate
							AND CheckOutDate >= newCheckOutDate;
					UPDATE Reservations SET RoomID = newRoomID
						WHERE ReservationID != bookingID
						AND GuestID = anotherGuestID
						AND CheckInDate <= newCheckOutDate
						AND CheckOutDate >= newCheckOutDate;
					
					UPDATE Reservations SET CheckOutDate = newCheckOutDate
						WHERE ReservationID = bookingID;
						
					SELECT 'Booking updated: Guest moved to a different room of the same type.' AS Result;
                    
				ELSE
				--  Нет свободного номера того же типа, ищем другой номер ближайший по стоимости
					 SELECT RoomNumber, RoomType, PricePerNight
					FROM Rooms
					WHERE RoomID NOT IN (
						SELECT RoomID
						FROM Reservations
						WHERE CheckInDate <= newCheckOutDate
							AND CheckOutDate >= newCheckOutDate
					)
					ORDER BY ABS(PricePerNight - (SELECT PricePerNight FROM Rooms WHERE RoomID = currentRoomID))
					LIMIT 3;

				END IF;
                    
		END IF;
    
END;
//
DELIMITER ;

CALL  UpdateReservationByIdAndCheckOut( 9, '2023-11-05');