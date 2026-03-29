-- =============================================
-- FUNCTION: ดูข้อมูลสัตว์และรายละเอียด (Animal Information Viewing)
-- =============================================
-- READ: ค้นหาสัตว์จากชื่อ
SELECT AnimalID, CommonName, ScientificName, Gender, BirthDate, ConservationStatus 
FROM Animal 
WHERE CommonName LIKE CONCAT('%', ?, '%');

-- READ: ค้นหาสัตว์จากประเภท/สายพันธุ์
SELECT AnimalID, CommonName, Species 
FROM Animal 
WHERE Species = ?;

-- READ: ค้นหาสัตว์จากโซน
SELECT a.AnimalID, a.CommonName, a.Species, z.ZoneName
FROM Animal a
JOIN Enclosure e ON a.EnclosureID = e.EnclosureID
JOIN Zone z ON e.ZoneID = z.ZoneID
WHERE z.ZoneID = ?;

-- READ: ดูรายละเอียดสัตว์แบบเต็ม รวมข้อมูลพ่อแม่
SELECT 
    a1.AnimalID, a1.CommonName, a1.ScientificName, a1.Gender, a1.BirthDate,
    sire.CommonName AS FatherName, 
    dam.CommonName AS MotherName
FROM Animal a1
LEFT JOIN Animal sire ON a1.FatherID = sire.AnimalID
LEFT JOIN Animal dam ON a1.MotherID = dam.AnimalID
WHERE a1.AnimalID = ?;

-- READ: ค้นหาสัตว์จากหมวดหมู่ Conservation Status
SELECT AnimalID, CommonName, Species, ConservationStatus 
FROM Animal 
WHERE ConservationStatus = ?;

-- =============================================
-- FUNCTION: ดูข้อมูลโซนและแผนที่สวนสัตว์ (Zone & Map Viewing)
-- =============================================
-- READ: ดึงข้อมูลโซนทั้งหมด
SELECT ZoneID, ZoneName, Description, OpenTime, CloseTime 
FROM Zone;

-- READ: ค้นหาโซนจากชื่อ
SELECT ZoneID, ZoneName 
FROM Zone 
WHERE ZoneName LIKE CONCAT('%', ?, '%');

-- READ: ดูรายละเอียดโซนพร้อมจำนวน Enclosure
SELECT z.ZoneID, z.ZoneName, z.Description, COUNT(e.EnclosureID) AS TotalEnclosures
FROM Zone z
LEFT JOIN Enclosure e ON z.ZoneID = e.ZoneID
WHERE z.ZoneID = ?
GROUP BY z.ZoneID, z.ZoneName, z.Description;

-- READ: ดูรายชื่อสัตว์ทั้งหมดในโซน
SELECT a.AnimalID, a.CommonName, e.EnclosureName
FROM Animal a
JOIN Enclosure e ON a.EnclosureID = e.EnclosureID
WHERE e.ZoneID = ?;

-- READ: ดูกิจกรรมที่จัดในโซน
SELECT ActivityID, ActivityName, StartTime, EndTime 
FROM Activity 
WHERE ZoneID = ?;

-- READ: สรุปภาพรวมทุกโซน (สำหรับแสดงบน Map UI)
SELECT ZoneID, ZoneName, MapCoordinateX, MapCoordinateY, IconPath 
FROM Zone;

-- =============================================
-- FUNCTION: ดูตารางการแสดงสัตว์ (Show Schedule Viewing)
-- =============================================
-- READ: ดึงตารางการแสดงทั้งหมดที่ยังไม่ผ่านมา
SELECT ShowID, ShowName, ShowDate, StartTime, EndTime, ZoneID 
FROM ShowSchedule 
WHERE ShowDate >= CURDATE() AND StartTime >= CURTIME()
ORDER BY ShowDate ASC, StartTime ASC;

-- READ: กรองตารางการแสดงตามวันที่
SELECT ShowID, ShowName, StartTime, EndTime, ZoneID 
FROM ShowSchedule 
WHERE ShowDate = ?;

-- READ: กรองตารางการแสดงตามประเภท
SELECT ShowID, ShowName, ShowType, StartTime, EndTime 
FROM ShowSchedule 
WHERE ShowType = ?;

-- READ: ดูรายละเอียดการแสดง พร้อมรายชื่อสัตว์ที่ร่วมแสดงและโซนที่จัด
SELECT 
    ss.ShowName, ss.ShowDate, ss.StartTime, ss.EndTime, 
    z.ZoneName, 
    GROUP_CONCAT(a.CommonName SEPARATOR ', ') AS ParticipatingAnimals
FROM ShowSchedule ss
JOIN Zone z ON ss.ZoneID = z.ZoneID
LEFT JOIN Show_Animal sa ON ss.ShowID = sa.ShowID
LEFT JOIN Animal a ON sa.AnimalID = a.AnimalID
WHERE ss.ShowID = ?
GROUP BY ss.ShowID;

-- =============================================
-- FUNCTION: ค้นหาและแนะนำข้อมูล (Search & Recommendation)
-- =============================================
-- READ: ค้นหาแบบ Global Search (สัตว์ + โซน + กิจกรรม)
SELECT 'Animal' AS Type, AnimalID AS ID, CommonName AS Name FROM Animal WHERE CommonName LIKE CONCAT('%', ?, '%')
UNION
SELECT 'Zone' AS Type, ZoneID AS ID, ZoneName AS Name FROM Zone WHERE ZoneName LIKE CONCAT('%', ?, '%')
UNION
SELECT 'Activity' AS Type, ActivityID AS ID, ActivityName AS Name FROM Activity WHERE ActivityName LIKE CONCAT('%', ?, '%');

-- READ: แนะนำสัตว์ที่อยู่ในสถานะใกล้สูญพันธุ์
SELECT AnimalID, CommonName, Species 
FROM Animal 
WHERE ConservationStatus IN ('Endangered', 'Critically Endangered')
LIMIT 5;

-- READ: แนะนำกิจกรรมที่กำลังจะมาถึง
SELECT ActivityID, ActivityName, StartTime, ZoneID 
FROM Activity 
WHERE StartTime BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 2 HOUR)
ORDER BY StartTime ASC;

-- READ: แนะนำสัตว์ยอดนิยม
SELECT a.AnimalID, a.CommonName, COUNT(v.ViewID) AS ViewCount
FROM Animal a
JOIN Animal_Views v ON a.AnimalID = v.AnimalID
GROUP BY a.AnimalID
ORDER BY ViewCount DESC
LIMIT 5;

-- READ: แนะนำสัตว์ตามสายพันธุ์ที่ผู้ใช้เคยดู
SELECT DISTINCT a2.AnimalID, a2.CommonName
FROM Animal_Views v
JOIN Animal a1 ON v.AnimalID = a1.AnimalID
JOIN Animal a2 ON a1.Species = a2.Species AND a1.AnimalID != a2.AnimalID
WHERE v.VisitorID = ?
LIMIT 5;

-- =============================================
-- FUNCTION: ซื้อตั๋วเข้าชมออนไลน์ (Online Ticket Purchase)
-- =============================================
-- READ: ดึงประเภทตั๋วและราคา
SELECT TicketTypeID, TypeName, Price, Conditions 
FROM TicketType 
WHERE IsActive = TRUE;

-- READ: ตรวจสอบโปรโมชั่น/ส่วนลดที่ใช้ได้
SELECT PromoCode, DiscountPercent, DiscountAmount, ValidUntil 
FROM Promotion 
WHERE PromoCode = ? AND ValidUntil >= CURDATE() AND IsActive = TRUE;

-- CREATE: บันทึกข้อมูลตั๋วแต่ละใบ
INSERT INTO Ticket (TicketID, TicketTypeID, Price, VisitDate, PromoCode, PurchaseDate, Status)
VALUES (?, ?, ?, ?, ?, NOW(), 'Unused');

-- CREATE: เชื่อมตั๋วกับ Visitor (Bought_by)
INSERT INTO Bought_by (VisitorID, TicketID)
VALUES (?, ?);

-- =============================================
-- FUNCTION: ชำระเงิน (Payment Processing)
-- =============================================
-- READ: ดึงข้อมูลตั๋วที่ต้องชำระ
SELECT t.TicketID, tt.TypeName, t.Price, t.PromoCode
FROM Ticket t
JOIN TicketType tt ON t.TicketTypeID = tt.TicketTypeID
WHERE t.TicketID = ? AND t.Status = 'PendingPayment';

-- READ: ตรวจสอบสถานะการชำระเงิน
SELECT PaymentID, TicketID, PaymentStatus, PaymentDate 
FROM Payment 
WHERE TicketID = ?;

-- UPDATE: อัปเดต PurchaseChannel และ PurchaseDate ใน Ticket
UPDATE Ticket 
SET PurchaseChannel = ?, PurchaseDate = NOW(), Status = 'Paid'
WHERE TicketID = ?;

-- UPDATE: เชื่อม Promotion กับ Ticket (กรณีใช้โค้ดส่วนลด)
UPDATE Ticket 
SET PromoCode = ?, Price = Price - (SELECT DiscountAmount FROM Promotion WHERE PromoCode = ?) -- *ปรับ Logic ตามเป้าหมายจริง
WHERE TicketID = ?;

-- =============================================
-- FUNCTION: จัดการตั๋วและประวัติการซื้อ (Ticket Management)
-- =============================================
-- READ: ดึงตั๋วทั้งหมดของ Visitor
SELECT t.TicketID, tt.TypeName, t.VisitDate, t.Status 
FROM Ticket t
JOIN Bought_by bb ON t.TicketID = bb.TicketID
WHERE bb.VisitorID = ?;

-- READ: แสดงรายละเอียดตั๋วพร้อมสถานะ (ใช้แล้ว/ยังไม่ใช้)
SELECT t.TicketID, tt.TypeName, t.VisitDate, t.Price, t.Status, t.UsedDate 
FROM Ticket t
JOIN TicketType tt ON t.TicketTypeID = tt.TicketTypeID
WHERE t.TicketID = ?;

-- READ: ดูประวัติการซื้อเรียงตามวันที่
SELECT t.TicketID, tt.TypeName, t.PurchaseDate, t.Price 
FROM Ticket t
JOIN Bought_by bb ON t.TicketID = bb.TicketID
WHERE bb.VisitorID = ?
ORDER BY t.PurchaseDate DESC;

-- =============================================
-- FUNCTION: แสดงตั๋วอิเล็กทรอนิกส์ (E-Ticket Viewing)
-- =============================================
-- READ: ดึงข้อมูลตั๋วจาก TicketID
SELECT TicketID, VisitDate, Status, QR_Code_Data 
FROM Ticket 
WHERE TicketID = ?;

-- READ: ดึงข้อมูล Visitor เจ้าของตั๋ว
SELECT v.FirstName, v.LastName, v.VisitorEmail 
FROM Visitor v
JOIN Bought_by bb ON v.VisitorID = bb.VisitorID
WHERE bb.TicketID = ?;

-- READ: ดึงข้อมูล Promotion ที่ใช้กับตั๋วนี้
SELECT p.PromoCode, p.PromoName, p.DiscountPercent 
FROM Promotion p
JOIN Ticket t ON p.PromoCode = t.PromoCode
WHERE t.TicketID = ?;

-- READ: แสดงรายละเอียดครบถ้วนสำหรับ E-Ticket
SELECT 
    t.TicketID, tt.TypeName, t.VisitDate, t.Price, t.Status, t.QR_Code_Data,
    v.FirstName, v.LastName,
    p.PromoName
FROM Ticket t
JOIN TicketType tt ON t.TicketTypeID = tt.TicketTypeID
JOIN Bought_by bb ON t.TicketID = bb.TicketID
JOIN Visitor v ON bb.VisitorID = v.VisitorID
LEFT JOIN Promotion p ON t.PromoCode = p.PromoCode
WHERE t.TicketID = ?;
