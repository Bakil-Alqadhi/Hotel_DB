-- user hotel_db
USE  hotel_db;

--  1. Получить данные обо всех гостях, которые выехали из отеля сегодня 
SELECT G.GuestID, G.FirstName, G.MiddleName, G.LastName, G.Phone
 FROM Guests G 
JOIN Reservations R ON G.GuestID = R.GuestID 
WHERE R.CheckOutDate = CURDATE();

-- 2. Вывести список всех доступных номеров определенного типа (например, 'Deluxe'). 
SELECT RoomNumber From Rooms
WHERE RoomType = 'Deluxe' 
AND RoomID NOT IN (
SELECT RoomID FROM Reservations
-- WHERE CheckInDate <= CURDATE()
--       AND CheckOutDate >= CURDATE()
);

-- 3. Получить подробный счет за последнее проживание гостя с ФИО: Виноградов Павел Евгеньевич.
SELECT 
	-- G.FirstName,
--     G.MiddleName,
--     G.LastName,
	CONCAT(G.FirstName, ' ', G.MiddleName, ' ', G.LastName) AS FullName,
    R.RoomNumber,
    R.RoomType,
    R.PricePerNight,
    DATEDIFF( RS.CheckOutDate, RS.CheckInDate) AS NightsStayed,
    (DATEDIFF(RS.CheckOutDate, RS.CheckInDate) * R.PricePerNight) AS RoomTotal,
    GROUP_CONCAT(S.ServiceName SEPARATOR ', ') AS ServicesReceived, 
    GROUP_CONCAT(GS.ServiceDate SEPARATOR ', ') AS ServicesDates, 
    IFNULL(SUM(S.ServiceCost), 0) AS TotalServiceCost, 
    ((DATEDIFF(RS.CheckOutDate, RS.CheckInDate) * R.PricePerNight) + IFNULL(SUM(S.ServiceCost), 0)) AS TotalCost
FROM Guests G  
INNER JOIN Reservations RS ON G.GuestID = RS.GuestID
LEFT JOIN Rooms R ON RS.RoomID = R.RoomID
LEFT JOIN GuestServices GS ON G.GuestID = GS.GuestID
LEFT JOIN Services S ON GS.ServiceID = S.ServiceID
WHERE CONCAT(G.FirstName, ' ', G.MiddleName, ' ', G.LastName) = 'Olivia Rose Roberts'
ORDER BY RS.CheckOutDate DESC
LIMIT 1;

-- 4. Найти топ-5 гостей, потративших больше всего средств на дополнительные услуги во время пребывания в отеле, и расположить их в порядке убывания расходов
 SELECT 
	CONCAT(G.FirstName, ' ', G.MiddleName, ' ', G.LastName) AS FullName,
    GROUP_CONCAT(S.ServiceName SEPARATOR ', ') AS ServicesReceived, 
    IFNULL(SUM(S.ServiceCost), 0) AS TotalServiceCost
FROM Guests G  
INNER JOIN Reservations RS ON G.GuestID = RS.GuestID
LEFT JOIN Rooms R ON RS.RoomID = R.RoomID
LEFT JOIN GuestServices GS ON G.GuestID = GS.GuestID
LEFT JOIN Services S ON GS.ServiceID = S.ServiceID
GROUP BY G.GuestID
ORDER BY TotalServiceCost DESC
LIMIT 5;

-- 5. Найти общую выручку, полученную гостиницей за последний месяц
SELECT 
	(DATEDIFF(RS.CheckOutDate, RS.CheckInDate) * R.PricePerNight) AS RoomTotalRevenue,
    IFNULL(SUM(S.ServiceCost), 0) AS ServiceTotalRevenue, 
    ((DATEDIFF(RS.CheckOutDate, RS.CheckInDate) * R.PricePerNight) + IFNULL(SUM(S.ServiceCost), 0)) AS TotalRevenue
FROM Reservations AS RS
INNER JOIN Rooms R ON RS.RoomID = R.RoomID
LEFT JOIN GuestServices GS ON GS.GuestID = RS.GuestID
LEFT JOIN Services S ON GS.ServiceID = S.ServiceID
WHERE RS.CheckInDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
	AND RS.CheckOutDate <= CURDATE();

-- 6. Вывести ФИО всех гостей, которые останавливались в отеле более одного раза, с указанием количества их посещений
SELECT G.FirstName,
    G.MiddleName,
    G.LastName,
    COUNT(R.GuestID) AS VisitCount
    FROM Guests G
INNER JOIN Reservations R ON G.GuestID = R.GuestID
GROUP BY G.GuestID
HAVING VisitCount > 1;

-- 7. Вывести список типов номеров с указанием количества забронированных номеров данного типа (за всё время), упорядоченный по убыванию
SELECT 
R.RoomNumber,
R.RoomType,
COUNT(RS.RoomID) AS BookingCount
FROM Rooms AS R
JOIN Reservations AS RS ON RS.RoomID = R.RoomID
GROUP BY(RS.RoomID)
ORDER BY BookingCount DESC;

--  8 . Вывести ФИО гостей, которые не воспользовались дополнительными услугами во время проживания
SELECT 
	FirstName,
    MiddleName,
    LastName
    FROM Guests
    WHERE GuestID NOT IN ( SELECT GuestID FROM Guestservices)





