-- =============================================
-- FUNCTION: ดูข้อมูลสัตว์และรายละเอียด (Animal Information Viewing)
-- =============================================

-- READ: ค้นหาสัตว์จากชื่อ — ฟังก์ชันแรก ขอดูว่าเขียนมาดีแค่ไหน
SELECT AnimalID, CommonName, ScientificName, Gender, BirthDate, ConservationStatus  -- เลือก 6 columns เฉพาะที่ต้องการ ไม่ SELECT * ถือว่าผ่าน
FROM Animal  -- ตารางหลักของสัตว์ทุกตัว
WHERE CommonName LIKE CONCAT('%', ?, '%'); -- [PERF] wildcard นำหน้า '%x%' = index ใช้ไม่ได้เลย full table scan ทุกครั้ง โอเคสำหรับสวนสัตว์เล็กๆ แต่ถ้า scale ควรพิจารณา FULLTEXT INDEX

-- READ: ค้นหาสัตว์จากประเภท/สายพันธุ์ — query นี้ง่ายและสะอาด
SELECT AnimalID, CommonName, Species  -- column น้อย เบา เร็ว ดี
FROM Animal  -- ตารางเดิม
WHERE Species = ?; -- exact match ใช้ index ได้ดีกว่า query แรกมาก ขอชม

-- READ: ค้นหาสัตว์จากโซน — ต้อง JOIN 2 ชั้นเพราะ schema ออกแบบผ่าน Enclosure
SELECT a.AnimalID, a.CommonName, a.Species, z.ZoneName -- เอา ZoneName มาด้วยดี ไม่ต้องให้ client query อีกรอบ
FROM Animal a -- alias 'a' สั้นกระชับ
JOIN Enclosure e ON a.EnclosureID = e.EnclosureID -- ขึ้นไปหา Enclosure ก่อนเพราะ Animal ไม่ได้ link Zone โดยตรง
JOIN Zone z ON e.ZoneID = z.ZoneID -- ขึ้นไปถึง Zone แล้ว chain JOIN ปกติ
WHERE z.ZoneID = ?; -- filter ด้วย ID ดีกว่า filter ชื่อ เพราะ ID unique และใช้ index ได้

-- READ: ดูรายละเอียดสัตว์แบบเต็ม รวมข้อมูลพ่อแม่ — self-join สามชั้น อ่านแล้วรู้สึก respect
SELECT  -- indent หลายบรรทัด อ่านง่ายกว่า one-liner มาก ถูกต้อง
    a1.AnimalID, a1.CommonName, a1.ScientificName, a1.Gender, a1.BirthDate, -- ข้อมูลพื้นฐานของสัตว์ตัวนั้น
    sire.CommonName AS FatherName,  -- self-join หาพ่อ alias 'sire' เป็นคำศัพท์ม้าพันธุ์ ฟังดูดี consistent กับ schema
    dam.CommonName AS MotherName -- self-join หาแม่ 'dam' ก็ศัพท์เดียวกัน คู่กันพอดี
FROM Animal a1 -- alias a1 เพราะต้องอ้างตัวเองหลายครั้งใน query นี้
LEFT JOIN Animal sire ON a1.FatherID = sire.AnimalID -- LEFT JOIN เพราะสัตว์บางตัวไม่มีข้อมูลพ่อ ถ้าใช้ INNER JOIN จะหายไปเลย ถูกต้อง
LEFT JOIN Animal dam ON a1.MotherID = dam.AnimalID -- LEFT JOIN เพราะสัตว์บางตัวไม่มีข้อมูลแม่ logic เดียวกัน consistent ดี
WHERE a1.AnimalID = ?; -- lookup ด้วย primary key เร็วที่สุดเท่าที่จะเร็วได้

-- READ: ค้นหาสัตว์จากหมวดหมู่ Conservation Status — query สั้นตรงไปตรงมา
SELECT AnimalID, CommonName, Species, ConservationStatus  -- ดึง ConservationStatus มาด้วยเพื่อยืนยัน filter ที่ส่งมา
FROM Animal  -- ตารางสัตว์
WHERE ConservationStatus = ?; -- [NOTE] case-sensitive ใน MySQL default collation ต้องส่ง 'Endangered' ไม่ใช่ 'endangered' ไม่งั้นหาไม่เจอแบบงงๆ

-- =============================================
-- FUNCTION: ดูข้อมูลโซนและแผนที่สวนสัตว์ (Zone & Map Viewing)
-- =============================================

-- READ: ดึงข้อมูลโซนทั้งหมด — ดึงทุก row เลย ต้องมั่นใจว่า Zone มีไม่กี่สิบแถว
SELECT ZoneID, ZoneName, Description, OpenTime, CloseTime  -- ครบสำหรับ listing page
FROM Zone; -- ไม่มี WHERE ดึงหมดเลย ถ้า Zone น้อยก็โอเค ถ้าเยอะควรเพิ่ม pagination ไว้ก่อน

-- READ: ค้นหาโซนจากชื่อ — search suggestion แบบง่าย
SELECT ZoneID, ZoneName  -- แค่ 2 columns สำหรับ dropdown/autocomplete เหมาะสม
FROM Zone  -- ตารางโซน
WHERE ZoneName LIKE CONCAT('%', ?, '%'); -- [PERF] ปัญหาเดิม wildcard นำหน้า ใช้ index ไม่ได้ แต่ Zone ไม่น่ามีพัน rows ก็ยังพอรับได้

-- READ: ดูรายละเอียดโซนพร้อมจำนวน Enclosure — aggregate query ที่เขียนถูก
SELECT z.ZoneID, z.ZoneName, z.Description, COUNT(e.EnclosureID) AS TotalEnclosures -- COUNT นับ Enclosure ใน zone นั้น alias ชื่อชัดเจน
FROM Zone z  -- ตาราง Zone เป็น base
LEFT JOIN Enclosure e ON z.ZoneID = e.ZoneID -- LEFT JOIN สำคัญมาก ถ้าใช้ INNER JOIN zone ที่ยังไม่มี enclosure จะหายไปเงียบๆ
WHERE z.ZoneID = ?  -- filter zone เดียวที่ต้องการ
GROUP BY z.ZoneID, z.ZoneName, z.Description; -- GROUP BY ครบทุก non-aggregate column นี่คือ textbook correct ขอชม

-- READ: ดูรายชื่อสัตว์ทั้งหมดในโซน — ผ่าน Enclosure เหมือนเดิม
SELECT a.AnimalID, a.CommonName, e.EnclosureName -- เอา EnclosureName มาด้วยดี รู้ว่าสัตว์อยู่กรงไหน
FROM Animal a  -- ตารางสัตว์
JOIN Enclosure e ON a.EnclosureID = e.EnclosureID -- INNER JOIN หา Enclosure
WHERE e.ZoneID = ?; -- [NOTE] INNER JOIN นี้ทำให้สัตว์ที่ยังไม่มี Enclosure (EnclosureID = NULL) หายไปเงียบๆ ถ้า business logic ต้องการแสดงทุกตัว ให้เปลี่ยนเป็น LEFT JOIN

-- READ: ดูกิจกรรมที่จัดในโซน — query เรียบง่ายไม่มีอะไรซับซ้อน
SELECT ActivityID, ActivityName, StartTime, EndTime  -- ข้อมูลกิจกรรมพื้นฐาน
FROM Activity  -- ตารางกิจกรรม
WHERE ZoneID = ?; -- filter ตาม zone ตรงไปตรงมา index บน ZoneID จะช่วยได้มาก

-- READ: สรุปภาพรวมทุกโซน (สำหรับแสดงบน Map UI) — query เฉพาะ UI ไม่เอาขยะมาด้วย
SELECT ZoneID, ZoneName, MapCoordinateX, MapCoordinateY, IconPath  -- เลือกเฉพาะ columns ที่ map ต้องการ ไม่ดึง Description มาเพื่อความเบา
FROM Zone; -- ดึงทุก zone สำหรับ initial map render ซึ่งสมเหตุสมผล

-- =============================================
-- FUNCTION: ดูตารางการแสดงสัตว์ (Show Schedule Viewing)
-- =============================================

-- READ: ดึงตารางการแสดงทั้งหมดที่ยังไม่ผ่านมา — ดูดีแต่ logic ซ่อน bug ไว้
SELECT ShowID, ShowName, ShowDate, StartTime, EndTime, ZoneID  -- ข้อมูลครบสำหรับ schedule listing
FROM ShowSchedule  -- ตาราง schedule การแสดง
-- [BUG] logic ผิด! AND ทำให้ filter ทั้งสองเงื่อนไขพร้อมกัน ถ้า ShowDate = พรุ่งนี้ แต่ StartTime = 09:00 น. และ CURTIME() = 10:00 น. show นั้นจะ filter ทิ้งทั้งที่ยังไม่ผ่านมา
-- แก้ไขเป็น: WHERE (ShowDate > CURDATE()) OR (ShowDate = CURDATE() AND StartTime >= CURTIME())
WHERE ShowDate >= CURDATE() AND StartTime >= CURTIME() -- [BUG] ดู comment บรรทัดบน
ORDER BY ShowDate ASC, StartTime ASC; -- sort วันและเวลาจากน้อยไปมาก ถูกต้อง

-- READ: กรองตารางการแสดงตามวันที่ — query ตรงไปตรงมา
SELECT ShowID, ShowName, StartTime, EndTime, ZoneID  -- ข้อมูลพอสำหรับ filter by date view
FROM ShowSchedule  -- ตาราง schedule
WHERE ShowDate = ?; -- exact date match เร็วถ้ามี index บน ShowDate

-- READ: กรองตารางการแสดงตามประเภท — เหมือน query บน
SELECT ShowID, ShowName, ShowType, StartTime, EndTime  -- เอา ShowType มาในผลลัพธ์ด้วย ดี ยืนยัน filter ที่ส่งมาให้ user เห็น
FROM ShowSchedule  -- ตาราง schedule
WHERE ShowType = ?; -- exact match กับ type ต้องส่งค่ามาให้ตรง case ด้วย

-- READ: ดูรายละเอียดการแสดง พร้อมรายชื่อสัตว์ที่ร่วมแสดงและโซนที่จัด
SELECT  -- indent หลายบรรทัด query ซับซ้อนควรทำแบบนี้ อ่านง่ายกว่า
    ss.ShowName, ss.ShowDate, ss.StartTime, ss.EndTime,  -- ข้อมูลหลักของ show
    z.ZoneName,  -- โซนที่จัด show ดึงมาแสดงเลย ไม่ต้อง query ซ้ำ
    GROUP_CONCAT(a.CommonName SEPARATOR ', ') AS ParticipatingAnimals -- รวมชื่อสัตว์ทุกตัวเป็น string เดียว MySQL-specific syntax ใช้กับ DB อื่นไม่ได้
FROM ShowSchedule ss -- ตาราง schedule alias ss
JOIN Zone z ON ss.ZoneID = z.ZoneID -- JOIN หา ZoneName
LEFT JOIN Show_Animal sa ON ss.ShowID = sa.ShowID -- LEFT JOIN เพราะ show อาจยังไม่มีสัตว์ assign ถ้าใช้ INNER JOIN show นั้นหายไปเลย
LEFT JOIN Animal a ON sa.AnimalID = a.AnimalID -- LEFT JOIN ตามมา consistent กับบรรทัดบน
WHERE ss.ShowID = ?  -- filter show เดียว
-- [BUG] GROUP BY แค่ ShowID ใน MySQL ONLY_FULL_GROUP_BY mode (default ตั้งแต่ 5.7.5) จะ error เพราะ ShowName, ShowDate, StartTime, EndTime, ZoneName ไม่อยู่ใน GROUP BY
-- แก้ไขเป็น: GROUP BY ss.ShowID, ss.ShowName, ss.ShowDate, ss.StartTime, ss.EndTime, z.ZoneName
GROUP BY ss.ShowID; -- [BUG] ดู comment บรรทัดบน

-- =============================================
-- FUNCTION: ค้นหาและแนะนำข้อมูล (Search & Recommendation)
-- =============================================

-- READ: ค้นหาแบบ Global Search (สัตว์ + โซน + กิจกรรม) — UNION 3 ตาราง ระวัง overhead
SELECT 'Animal' AS Type, AnimalID AS ID, CommonName AS Name FROM Animal WHERE CommonName LIKE CONCAT('%', ?, '%') -- ค้นหา Animal ด้วย wildcard ใช้ index ไม่ได้ full scan อีกแล้ว
UNION -- UNION ตัดผลซ้ำออกโดยเปรียบทุก column หาก Type+ID+Name ซ้ำกันข้ามตารางจะ merge ซึ่งแทบเป็นไปไม่ได้ แต่เพิ่ม overhead ถ้าต้องการเร็วกว่านี้ใช้ UNION ALL
SELECT 'Zone' AS Type, ZoneID AS ID, ZoneName AS Name FROM Zone WHERE ZoneName LIKE CONCAT('%', ?, '%') -- ค้นหา Zone เช่นกัน
UNION -- UNION อีกรอบ
SELECT 'Activity' AS Type, ActivityID AS ID, ActivityName AS Name FROM Activity WHERE ActivityName LIKE CONCAT('%', ?, '%'); -- [NOTE] ? parameter ส่ง 3 ครั้ง (1 ต่อ UNION) ต้องไม่ลืมส่งครบ

-- READ: แนะนำสัตว์ที่อยู่ในสถานะใกล้สูญพันธุ์ — สั้นดี แต่มีจุดสังเกต
SELECT AnimalID, CommonName, Species  -- ข้อมูลพอสำหรับ recommendation card
FROM Animal  -- ตารางสัตว์
WHERE ConservationStatus IN ('Endangered', 'Critically Endangered') -- IN clause อ่านง่ายกว่า OR ถูกต้อง
LIMIT 5; -- [NOTE] LIMIT 5 โดยไม่มี ORDER BY = ได้ 5 ตัวสุ่มจาก engine ทุกครั้ง ถ้าต้องการ consistent ควรเพิ่ม ORDER BY เช่น ORDER BY CommonName ASC

-- READ: แนะนำกิจกรรมที่กำลังจะมาถึง — ระวัง type ของ StartTime
SELECT ActivityID, ActivityName, StartTime, ZoneID  -- ข้อมูลพื้นฐานของกิจกรรม
FROM Activity  -- ตารางกิจกรรม
-- [NOTE] ถ้า StartTime เป็น TIME type (ไม่ใช่ DATETIME) การเปรียบกับ NOW() ที่เป็น DATETIME จะให้ผลแปลกหรือ error ขึ้นอยู่กับ DB engine ตรวจ schema ก่อนไปใช้งานจริง
WHERE StartTime BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 2 HOUR) -- [NOTE] ดู comment บรรทัดบน
ORDER BY StartTime ASC; -- sort จากใกล้สุดก่อน ถูกต้อง

-- READ: แนะนำสัตว์ยอดนิยม — logic ดีแต่ GROUP BY พัง
SELECT a.AnimalID, a.CommonName, COUNT(v.ViewID) AS ViewCount -- นับจำนวนครั้งที่ถูกดู
FROM Animal a  -- ตารางสัตว์
JOIN Animal_Views v ON a.AnimalID = v.AnimalID -- INNER JOIN ดีกว่า LEFT JOIN ตรงนี้ เพราะสัตว์ที่ไม่เคยถูกดูก็ไม่ควรอยู่ใน top list
-- [BUG] GROUP BY แค่ AnimalID ใน MySQL ONLY_FULL_GROUP_BY mode จะ error เพราะ a.CommonName ไม่อยู่ใน GROUP BY
-- แก้ไขเป็น: GROUP BY a.AnimalID, a.CommonName
GROUP BY a.AnimalID -- [BUG] ดู comment บรรทัดบน
ORDER BY ViewCount DESC -- เรียงจากยอดนิยมสูงสุด ถูกต้อง
LIMIT 5; -- top 5 พอสำหรับ recommendation section

-- READ: แนะนำสัตว์ตามสายพันธุ์ที่ผู้ใช้เคยดู — collaborative filtering แบบ manual
SELECT DISTINCT a2.AnimalID, a2.CommonName -- DISTINCT จำเป็นเพราะ user อาจดูสัตว์สายพันธุ์เดียวกันหลายตัว ทำให้ a2 ซ้ำ
FROM Animal_Views v -- เริ่มจาก view log ของ user
JOIN Animal a1 ON v.AnimalID = a1.AnimalID -- หาสัตว์ที่ user เคยดู
JOIN Animal a2 ON a1.Species = a2.Species AND a1.AnimalID != a2.AnimalID -- หาสัตว์สายพันธุ์เดียวกันที่ไม่ใช่ตัวเดิม != ใช้ได้ใน MySQL แต่ <> เป็น standard SQL มากกว่า
WHERE v.VisitorID = ?  -- filter เฉพาะ user ที่ต้องการ
LIMIT 5; -- top 5 recommendation ไม่มี ORDER BY เช่นกัน ได้ random 5 ตัว

-- =============================================
-- FUNCTION: ซื้อตั๋วเข้าชมออนไลน์ (Online Ticket Purchase)
-- =============================================

-- READ: ดึงประเภทตั๋วและราคา — query สะอาด
SELECT TicketTypeID, TypeName, Price, Conditions  -- ครบถ้วนสำหรับ listing page ให้ user เลือกตั๋ว
FROM TicketType  -- ตารางประเภทตั๋ว
WHERE IsActive = TRUE; -- filter เฉพาะตั๋วที่ active ดีมาก soft-delete pattern ถูกนำมาใช้ถูกที่

-- READ: ตรวจสอบโปรโมชั่น/ส่วนลดที่ใช้ได้ — validation ครบ 3 เงื่อนไข
SELECT PromoCode, DiscountPercent, DiscountAmount, ValidUntil  -- ดึงทั้ง % และ fixed amount เพราะ promotion อาจเป็น 2 แบบ ดี
FROM Promotion  -- ตาราง promotion
WHERE PromoCode = ? AND ValidUntil >= CURDATE() AND IsActive = TRUE; -- ครบ 3 เงื่อนไข: code ตรง + ยังไม่หมดอายุ + active ถ้าขาดข้อใดข้อหนึ่งจะมีช่องโหว่

-- CREATE: บันทึกข้อมูลตั๋วแต่ละใบ — จุดสำคัญมากแต่มี bug ซ่อนอยู่
-- [NOTE] ถ้า TicketID เป็น AUTO_INCREMENT ไม่ควรระบุใน INSERT ปล่อย DB จัดการเอง ถ้าเป็น UUID ก็ต้องส่งมาจาก application layer ตรวจ schema ก่อน
INSERT INTO Ticket (TicketID, TicketTypeID, Price, VisitDate, PromoCode, PurchaseDate, Status) -- column list ครบดี explicit ดีกว่า INSERT แบบไม่ระบุ column
-- [BUG] Status = 'Unused' แต่ Payment section (query ด้านล่าง) ตรวจสอบด้วย Status = 'PendingPayment' ทำให้หากันไม่เจอตลอดชีวิต ต้องเลือก value เดียวและใช้ให้ consistent
VALUES (?, ?, ?, ?, ?, NOW(), 'Unused'); -- [BUG] ดู comment บรรทัดบน

-- CREATE: เชื่อมตั๋วกับ Visitor (Bought_by) — ต้องทำหลัง INSERT Ticket สำเร็จเสมอ
INSERT INTO Bought_by (VisitorID, TicketID) -- relation table เชื่อม Visitor กับ Ticket many-to-one
VALUES (?, ?); -- [NOTE] ต้องส่ง TicketID จาก INSERT ก่อนหน้า ถ้าทำใน application layer ต้องใช้ LAST_INSERT_ID() หรือ returning ID ให้ถูกต้อง

-- =============================================
-- FUNCTION: ชำระเงิน (Payment Processing)
-- =============================================

-- READ: ดึงข้อมูลตั๋วที่ต้องชำระ — query ดีแต่หาตั๋วไม่เจอเพราะ status ไม่ตรง
SELECT t.TicketID, tt.TypeName, t.Price, t.PromoCode -- ข้อมูลที่ต้องแสดงใน payment confirmation page
FROM Ticket t  -- ตาราง ticket
JOIN TicketType tt ON t.TicketTypeID = tt.TicketTypeID -- JOIN เพื่อเอา TypeName มาแสดงให้ user เห็น
-- [BUG] Ticket ถูก INSERT ด้วย Status = 'Unused' ไม่ใช่ 'PendingPayment' query นี้จะไม่เจอตั๋วใหม่เลย ต้องแก้ทั้งคู่ให้ใช้ค่าเดียวกัน
WHERE t.TicketID = ? AND t.Status = 'PendingPayment'; -- [BUG] ดู comment บรรทัดบน

-- READ: ตรวจสอบสถานะการชำระเงิน — query ตรงไปตรงมา
SELECT PaymentID, TicketID, PaymentStatus, PaymentDate  -- ข้อมูล payment ของตั๋วนั้น
FROM Payment  -- ตาราง payment
WHERE TicketID = ?; -- lookup ด้วย TicketID index บน TicketID จะช่วยได้มาก

-- UPDATE: อัปเดต PurchaseChannel และ PurchaseDate ใน Ticket — logic ดีแต่ไม่ป้องกัน double payment
UPDATE Ticket  -- อัปเดตตาราง ticket
SET PurchaseChannel = ?, PurchaseDate = NOW(), Status = 'Paid' -- อัปเดต 3 field พร้อมกัน PurchaseDate ใช้ NOW() ดี ไม่รับจาก user ป้องกัน time manipulation
-- [WARNING] ไม่มีการตรวจสอบ Status เดิมก่อน UPDATE ถ้า payment ถูกเรียกซ้ำ (network retry / double click) status จะถูกเขียนทับ ควรเพิ่ม AND Status != 'Paid' ป้องกัน
WHERE TicketID = ?; -- [WARNING] ดู comment บรรทัดบน

-- UPDATE: เชื่อม Promotion กับ Ticket (กรณีใช้โค้ดส่วนลด) — logic นี้มีรู 3 รู
UPDATE Ticket  -- อัปเดตตาราง ticket เพื่อใส่ promo และคำนวณราคาใหม่
-- [BUG 1] ถ้า DiscountAmount เป็น NULL (เช่น promo เป็นแบบ % เท่านั้น) Price จะกลายเป็น NULL ทันที ข้อมูลเสียหาย ควรใช้ IFNULL(DiscountAmount, 0)
-- [BUG 2] ไม่รองรับ DiscountPercent เลย ทั้งที่ดึงมาใน query ตรวจสอบ promo ด้านบน logic ไม่ครบ
-- [BUG 3] ราคาอาจติดลบได้ถ้า DiscountAmount > Price ควรใช้ GREATEST(0, Price - ...) คุมล่าง
SET PromoCode = ?, Price = Price - (SELECT DiscountAmount FROM Promotion WHERE PromoCode = ?) -- *ปรับ Logic ตามเป้าหมายจริง -- [BUG 1,2,3] ดู comment บรรทัดบน
WHERE TicketID = ?; -- filter ticket เดียว ถูกต้อง

-- =============================================
-- FUNCTION: จัดการตั๋วและประวัติการซื้อ (Ticket Management)
-- =============================================

-- READ: ดึงตั๋วทั้งหมดของ Visitor — query สะอาด
SELECT t.TicketID, tt.TypeName, t.VisitDate, t.Status  -- ข้อมูลพอสำหรับ ticket list view
FROM Ticket t  -- ตาราง ticket
JOIN Bought_by bb ON t.TicketID = bb.TicketID -- JOIN ผ่าน relation table หา VisitorID
WHERE bb.VisitorID = ?; -- filter ด้วย visitor ID

-- READ: แสดงรายละเอียดตั๋วพร้อมสถานะ (ใช้แล้ว/ยังไม่ใช้) — ดึง UsedDate ด้วย
SELECT t.TicketID, tt.TypeName, t.VisitDate, t.Price, t.Status, t.UsedDate  -- ดึง UsedDate ด้วยดี ทำให้รู้ว่าตั๋วนี้ถูกใช้เมื่อไหร่
FROM Ticket t  -- ตาราง ticket
JOIN TicketType tt ON t.TicketTypeID = tt.TicketTypeID -- JOIN เพื่อ TypeName
WHERE t.TicketID = ?; -- lookup ตั๋วใบเดียว primary key เร็วสุด

-- READ: ดูประวัติการซื้อเรียงตามวันที่ — history view ที่ดี
SELECT t.TicketID, tt.TypeName, t.PurchaseDate, t.Price  -- ข้อมูล purchase history ครบ
FROM Ticket t  -- ตาราง ticket
JOIN Bought_by bb ON t.TicketID = bb.TicketID -- JOIN ผ่าน relation table
WHERE bb.VisitorID = ?  -- filter ด้วย visitor
ORDER BY t.PurchaseDate DESC; -- ล่าสุดก่อน เหมาะสำหรับ history view ถูกต้อง

-- =============================================
-- FUNCTION: แสดงตั๋วอิเล็กทรอนิกส์ (E-Ticket Viewing)
-- =============================================

-- READ: ดึงข้อมูลตั๋วจาก TicketID — query เบาสำหรับ quick lookup
SELECT TicketID, VisitDate, Status, QR_Code_Data  -- ข้อมูลสำหรับ render E-Ticket โดยเฉพาะ QR_Code_Data ที่ใช้สแกนเข้างาน
FROM Ticket  -- ตาราง ticket
WHERE TicketID = ?; -- lookup ด้วย primary key เร็วสุด

-- READ: ดึงข้อมูล Visitor เจ้าของตั๋ว — ดึงเฉพาะที่ต้องแสดง ไม่ leak ข้อมูล sensitive
SELECT v.FirstName, v.LastName, v.VisitorEmail  -- ไม่ดึง password หรือข้อมูล sensitive อื่นๆ ถูกต้อง
FROM Visitor v  -- ตาราง visitor
JOIN Bought_by bb ON v.VisitorID = bb.VisitorID -- JOIN ผ่าน relation table เพื่อ map ticket → visitor
WHERE bb.TicketID = ?; -- หา visitor จาก ticket ID

-- READ: ดึงข้อมูล Promotion ที่ใช้กับตั๋วนี้ — INNER JOIN ทำให้ตั๋วไม่มี promo หายไป
SELECT p.PromoCode, p.PromoName, p.DiscountPercent  -- ข้อมูล promo ที่ใช้กับตั๋วนี้
FROM Promotion p  -- ตาราง promotion
JOIN Ticket t ON p.PromoCode = t.PromoCode -- [NOTE] INNER JOIN ทำให้ query นี้ return 0 row สำหรับตั๋วที่ไม่มี promo ถ้า application ไม่รับมือ จะดูเหมือน error ทั้งที่ไม่ใช่ ควรเป็น LEFT JOIN ให้ตั๋วหลักแสดงเสมอ
WHERE t.TicketID = ?; -- [NOTE] ดู comment บรรทัดบน

-- READ: แสดงรายละเอียดครบถ้วนสำหรับ E-Ticket — master query ดึงรอบเดียวได้เลย
SELECT  -- ดีมากที่รวม query ไว้รอบเดียวแทนที่จะ query แยก 3-4 ครั้ง latency ต่ำกว่าเยอะ
    t.TicketID, tt.TypeName, t.VisitDate, t.Price, t.Status, t.QR_Code_Data, -- ข้อมูลตั๋วครบ
    v.FirstName, v.LastName, -- ชื่อ-นามสกุลเจ้าของตั๋ว
    p.PromoName -- ชื่อ promo (NULL ถ้าไม่มี promo เพราะ LEFT JOIN ด้านล่าง)
FROM Ticket t  -- ตาราง ticket เป็น base ทุกอย่าง JOIN เข้ามา
JOIN TicketType tt ON t.TicketTypeID = tt.TicketTypeID -- JOIN หา TypeName ถ้า TicketTypeID orphan ตั๋วจะหายไป ควรตรวจ FK constraint
JOIN Bought_by bb ON t.TicketID = bb.TicketID -- JOIN หา VisitorID
JOIN Visitor v ON bb.VisitorID = v.VisitorID -- JOIN หาข้อมูล visitor
LEFT JOIN Promotion p ON t.PromoCode = p.PromoCode -- LEFT JOIN ถูกต้อง ตั๋วที่ไม่มี promo ก็ยังแสดงได้ p.PromoName จะเป็น NULL
WHERE t.TicketID = ?; -- lookup ตั๋วใบเดียว query นี้ครบที่สุดในไฟล์
