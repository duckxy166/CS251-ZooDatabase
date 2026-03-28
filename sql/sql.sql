-- =============================================
-- FUNCTION: สมัครสมาชิกและจัดการบัญชีผู้ใช้งาน (User Account Management)
-- =============================================
-- CREATE: สมัครสมาชิกใหม่
INSERT INTO Visitor (VisitorID, FirstName, LastName, VisitorEmail, VisitorTel, DateOfBirth)
VALUES (?, ?, ?, ?, ?, ?);

INSERT INTO UserAccount (UserID, Username, Password, Role, AccountStatus, CreatedAt)
VALUES (?, ?, ?, 'Visitor', 'Active', NOW());

INSERT INTO has_visitor_account (UserID, VisitorID)
VALUES (?, ?);

-- READ: ตรวจสอบความซ้ำของ Email และ Username ก่อนสมัคร
SELECT COUNT(*) FROM Visitor 
WHERE VisitorEmail = ?;

SELECT COUNT(*) FROM UserAccount 
WHERE Username = ?;

-- READ: ดูข้อมูลส่วนตัวและประวัติการใช้งาน
SELECT 
    v.VisitorID, v.FirstName, v.LastName, 
    v.VisitorEmail, v.VisitorTel, v.DateOfBirth,
    ua.Username, ua.AccountStatus, ua.CreatedAt
FROM Visitor v
JOIN has_visitor_account hva ON v.VisitorID = hva.VisitorID
JOIN UserAccount ua ON hva.UserID = ua.UserID
WHERE ua.UserID = ?;

-- READ: ดูประวัติการซื้อตั๋ว
SELECT 
    t.TicketID, t.TicketType, t.Price, 
    t.VisitDate, p.PromoCode
FROM Ticket t
JOIN Visitor v ON t.VisitorID = v.VisitorID
LEFT JOIN Promotion p ON t.PromoCode = p.PromoCode
WHERE v.VisitorID = ?
ORDER BY t.VisitDate DESC;

-- UPDATE: แก้ไขข้อมูลส่วนตัว
UPDATE Visitor
SET VisitorEmail = ?, FirstName = ?, LastName = ?, VisitorTel = ?
WHERE VisitorID = ?;

-- UPDATE: เปลี่ยนรหัสผ่าน
UPDATE UserAccount
SET Password = ?
WHERE UserID = ?;

-- DELETE: ยกเลิกบัญชี (เปลี่ยนสถานะเป็น Inactive)
UPDATE UserAccount
SET AccountStatus = 'Inactive'
WHERE UserID = ?;

-- =============================================
-- FUNCTION: เข้าสู่ระบบและยืนยันตัวตน (Authentication)
-- =============================================
-- READ: ตรวจสอบ Username และ Password และสถานะบัญชี
SELECT 
    ua.UserID, ua.Username, ua.Role, ua.AccountStatus
FROM UserAccount ua
WHERE ua.Username = ?
  AND ua.Password = ?
  AND ua.AccountStatus = 'Active';

-- READ: ดึงข้อมูล Visitor ที่เชื่อมกับบัญชีนี้ (กรณี Role = Visitor)
SELECT 
    v.VisitorID, v.FirstName, v.LastName, 
    v.VisitorEmail, v.VisitorTel
FROM Visitor v
JOIN has_visitor_account hva ON v.VisitorID = hva.VisitorID
WHERE hva.UserID = ?;

-- READ: ดึงข้อมูล Admin ที่เชื่อมกับบัญชีนี้ (กรณี Role = Admin/Staff)
SELECT 
    a.AdminID, a.FirstName, a.Surname, 
    a.Email, a.JobTitle
FROM Admin a
JOIN Manage m ON a.AdminID = m.AdminID
WHERE m.UserID = ?;

-- READ: ตรวจสอบสิทธิ์การเข้าถึงตาม Role
SELECT 
    ua.UserID, ua.Username, ua.Role
FROM UserAccount ua
WHERE ua.UserID = ?
  AND ua.Role = 'Visitor';

-- =============================================
-- FUNCTION: จัดการสิทธิ์ผู้ใช้งาน (Role-based Access Management)
-- =============================================
-- CREATE: ตรวจสอบ Username ซ้ำก่อนสร้างบัญชี
SELECT COUNT(*) FROM UserAccount
WHERE Username = ?;

-- CREATE: สร้างบัญชีผู้ใช้งานใหม่
INSERT INTO UserAccount (UserID, Username, Password, Role, AccountStatus, CreatedAt)
VALUES (?, ?, ?, ?, 'Active', NOW());

-- READ: ตรวจสอบสิทธิ์การใช้งานและสถานะบัญชี
SELECT 
    ua.UserID, ua.Username, ua.Role, 
    ua.AccountStatus, ua.CreatedAt
FROM UserAccount ua
WHERE ua.Username = ?
  AND ua.Password = ?;

-- READ: ตรวจสอบสถานะบัญชีว่า Active หรือไม่
SELECT 
    ua.UserID, ua.Username, ua.Role, ua.AccountStatus
FROM UserAccount ua
WHERE ua.UserID = ?
  AND ua.AccountStatus = 'Active';

-- READ: ดึงรายการผู้ใช้งานทั้งหมดแยกตาม Role (เฉพาะ Admin)
SELECT 
    ua.UserID, ua.Username, ua.Role, 
    ua.AccountStatus, ua.CreatedAt
FROM UserAccount ua
ORDER BY ua.Role, ua.Username;

-- READ: บันทึก Log การเข้าใช้งาน
SELECT 
    ua.UserID, ua.Username, ua.Role,
    ua.AccountStatus, NOW() AS LoginTime
FROM UserAccount ua
WHERE ua.UserID = ?;

-- UPDATE: อัปเดต Role ของผู้ใช้งาน
UPDATE UserAccount
SET Role = ?
WHERE UserID = ?;

-- UPDATE: อัปเดตสถานะบัญชี (Active / Inactive)
UPDATE UserAccount
SET AccountStatus = ?
WHERE UserID = ?;

-- UPDATE: บันทึกการแก้ไขโดย Admin ผ่านตาราง Manage
UPDATE Manage
SET Edit_date = NOW(), Edit_detail = ?
WHERE AdminID = ? AND UserID = ?;

-- DELETE: ยกเลิกบัญชีผู้ใช้งาน (เปลี่ยนสถานะเป็น Inactive)
UPDATE UserAccount
SET AccountStatus = 'Inactive'
WHERE UserID = ?;

-- DELETE: บันทึก Log การยกเลิกบัญชีผ่านตาราง Manage
INSERT INTO Manage (AdminID, UserID, Edit_date, Edit_detail)
VALUES (?, ?, NOW(), 'Account deactivated');
-- =============================================
-- FUNCTION: ดูข้อมูลสัตว์และรายละเอียด (Animal Information Viewing)
-- =============================================
-- READ: ค้นหาสัตว์จากชื่อ
-- READ: ค้นหาสัตว์จากประเภท/สายพันธุ์
-- READ: ค้นหาสัตว์จากโซน
-- READ: ดูรายละเอียดสัตว์แบบเต็ม รวมข้อมูลพ่อแม่
-- READ: ค้นหาสัตว์จากหมวดหมู่ Conservation Status

-- =============================================
-- FUNCTION: ดูข้อมูลโซนและแผนที่สวนสัตว์ (Zone & Map Viewing)
-- =============================================
-- READ: ดึงข้อมูลโซนทั้งหมด
-- READ: ค้นหาโซนจากชื่อ
-- READ: ดูรายละเอียดโซนพร้อมจำนวน Enclosure
-- READ: ดูรายชื่อสัตว์ทั้งหมดในโซน
-- READ: ดูกิจกรรมที่จัดในโซน
-- READ: สรุปภาพรวมทุกโซน (สำหรับแสดงบน Map UI)

-- =============================================
-- FUNCTION: ดูตารางการแสดงสัตว์ (Show Schedule Viewing)
-- =============================================
-- READ: ดึงตารางการแสดงทั้งหมดที่ยังไม่ผ่านมา
-- READ: กรองตารางการแสดงตามวันที่
-- READ: กรองตารางการแสดงตามประเภท
-- READ: ดูรายละเอียดการแสดง พร้อมรายชื่อสัตว์ที่ร่วมแสดงและโซนที่จัด

-- =============================================
-- FUNCTION: ค้นหาและแนะนำข้อมูล (Search & Recommendation)
-- =============================================
-- READ: ค้นหาแบบ Global Search (สัตว์ + โซน + กิจกรรม)
-- READ: แนะนำสัตว์ที่อยู่ในสถานะใกล้สูญพันธุ์
-- READ: แนะนำกิจกรรมที่กำลังจะมาถึง
-- READ: แนะนำสัตว์ยอดนิยม
-- READ: แนะนำสัตว์ตามสายพันธุ์ที่ผู้ใช้เคยดู

-- =============================================
-- FUNCTION: ซื้อตั๋วเข้าชมออนไลน์ (Online Ticket Purchase)
-- =============================================
-- READ: ดึงประเภทตั๋วและราคา
-- READ: ตรวจสอบโปรโมชั่น/ส่วนลดที่ใช้ได้
-- CREATE: บันทึกข้อมูลตั๋วแต่ละใบ
-- CREATE: เชื่อมตั๋วกับ Visitor (Bought_by)

-- =============================================
-- FUNCTION: ชำระเงิน (Payment Processing)
-- =============================================
-- READ: ดึงข้อมูลตั๋วที่ต้องชำระ
-- READ: ตรวจสอบสถานะการชำระเงิน
-- UPDATE: อัปเดต PurchaseChannel และ PurchaseDate ใน Ticket
-- UPDATE: เชื่อม Promotion กับ Ticket (กรณีใช้โค้ดส่วนลด)

-- =============================================
-- FUNCTION: จัดการตั๋วและประวัติการซื้อ (Ticket Management)
-- =============================================
-- READ: ดึงตั๋วทั้งหมดของ Visitor
-- READ: แสดงรายละเอียดตั๋วพร้อมสถานะ (ใช้แล้ว/ยังไม่ใช้)
-- READ: ดูประวัติการซื้อเรียงตามวันที่

-- =============================================
-- FUNCTION: แสดงตั๋วอิเล็กทรอนิกส์ (E-Ticket Viewing)
-- =============================================
-- READ: ดึงข้อมูลตั๋วจาก TicketID
-- READ: ดึงข้อมูล Visitor เจ้าของตั๋ว
-- READ: ดึงข้อมูล Promotion ที่ใช้กับตั๋วนี้
-- READ: แสดงรายละเอียดครบถ้วนสำหรับ E-Ticket
