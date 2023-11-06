use hotel_db
-- 1. Создать триггер на добавление нового бронирования. Триггер должен срабатывать при добавлении новой
--  записи в бронирования: если номер занят, то не создавать запись о брониров ании и выбрасывать соответствующее исключение.
DELIMITER //
CREATE TRIGGER CheckRoomAvailability
BEFORE INSERT ON Reservations
FOR EACH ROW 
BEGIN  
	DECLARE isRoomAvailable INT;
    
	-- Проверяем, свободен ли номер на указанные даты
	SELECT COUNT(*) INTO isRoomAvailable
	FROM Reservations
	WHERE RoomID = NEW.RoomID
		AND CheckInDate <= NEW.CheckOutDate
		AND CheckOutDate >= NEW.CheckInDate;
    
	-- Если номер занят, выбрасываем исключение
    IF isRoomAvailable > 0 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room is already booked for these dates.';
    END IF;
END;
 // 
 DELIMITER ;
 
 INSERT INTO Reservations (ReservationID, GuestID, RoomID, CheckInDate, CheckOutDate)
VALUES (13, 9, 8, '2023-08-21', '2023-08-25');

-- 2. Триггер должен обрабатывать процесс исключения какой-либо услуги из перечня предоставляемых услуг, 
-- 		проверяя нет ли её в запланированных для каких-либо гостей. Если такие услуги есть, выбрасывать соответствующее исключение.
DELIMITER //
DROP TRIGGER IF EXISTS PreventServiceRemoval;
CREATE TRIGGER PreventServiceRemoval 
BEFORE DELETE ON Services
FOR EACH ROW
BEGIN 
	DECLARE serviceExists INT;
    SELECT COUNT(*) INTO serviceExists 
    FROM GuestServices
    WHERE ServiceID = OLD.ServiceID;
    
    -- Если услуга запланирована для гостей, выбрасываем исключение
    IF serviceExists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Service cannot be removed as it is scheduled for guests.';
    END IF;
END;
//
DELIMITER ;

DELETE FROM Services WHERE ServiceID = 4;

-- Transaction Question
-- Реализуйте транзакцию, которая обрабатывает процесс бронирования гостем услуги:
--  проверку корректности даты оказания услуги (не выходит ли она за рамки проживания), 
--  добавление заказа в соответствующую таблицу. Если в какой-либо момент времени бронирование не удается, вся транзакция откатывается назад.
DELIMITER //
DROP PROCEDURE IF EXISTS BookServiceAndCheckDates;
CREATE PROCEDURE BookServiceAndCheckDates(
v_index INT,
v_GuestID INT,
v_ServiceID INT,
v_ServiceDate DATE
)
BEGIN
    DECLARE v_CheckInDate DATE;
    DECLARE v_CheckOutDate DATE;

    SELECT CheckInDate, CheckOutDate INTO v_CheckInDate, v_CheckOutDate
    FROM Reservations
    WHERE GuestID = v_GuestID
    LIMIT 1;

    START TRANSACTION;

    IF v_ServiceDate >= v_CheckInDate AND v_ServiceDate <= v_CheckOutDate THEN
        INSERT INTO GuestServices (GuestServiceID, GuestID, ServiceID, ServiceDate)
        VALUES (v_index, v_GuestID, v_ServiceID, v_ServiceDate);

        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END;
//
DELIMITER ;
 CALL BookServiceAndCheckDates(12, 2, 3, '2023-02-26');
