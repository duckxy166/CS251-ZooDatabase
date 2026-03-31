-- =============================================
-- SCHEMA: สร้างโครงสร้างฐานข้อมูลสวนสัตว์
-- =============================================

 -- [DDL] สร้างจากตารางแม่ไปตารางลูกก่อน ไม่งั้น Foreign Key จะลุกขึ้นมาตบหน้าเอาตอนรัน
 -- [NOTE] เลขในวงเล็บหลัง INT เป็นแค่ display width แบบ MySQL รุ่นเก่า ไม่ได้ทำให้คอลัมน์เทพขึ้น อย่าเผลออินเกินจริง
 -- เอกสารบางจุดให้ขนาด FK ไม่เท่าตารางแม่ ผมจับให้ตรงฝั่งที่ถูกอ้างอิงไว้ก่อน จะได้ไม่ต้องมานั่งด่า constraint ตอนตีสอง

 -- ---------------------------------------------
 -- ตารางหลัก
 -- ---------------------------------------------

 -- DDL: สร้างตารางสายพันธุ์
 -- ตัวนี้ไม่พึ่งใคร เริ่มจากมันก่อนตามมารยาทของคนไม่อยากเจอ Error โง่ๆ
 CREATE TABLE Species ( -- แม่พันธุ์ของข้อมูลสัตว์ทั้งระบบ ถ้าตารางนี้พัง ข้างล่างก็เดินต่อไม่ได้
     SpeciesID INT(5) NOT NULL AUTO_INCREMENT, -- PK แจกเลขเอง จะได้ไม่ต้องนั่งเดา ID แบบคนว่างงาน
     SpeciesName VARCHAR(30) NOT NULL, -- ชื่อสายพันธุ์ไว้ให้มนุษย์อ่าน ไม่ใช่ให้มองภาษาละตินจนตาแหก
     TaxonomyCategory VARCHAR(50) NOT NULL, -- หมวดอนุกรมวิธาน เอาไว้จัดกลุ่มให้ข้อมูลดูมีการศึกษาหน่อย
     Origin VARCHAR(50) NOT NULL, -- ถิ่นกำเนิดของสายพันธุ์ จะได้เลิกเดาส่งๆ ว่ามาจากไหน
     AverageLifespan INT(3) NOT NULL, -- อายุเฉลี่ยเป็นปีตรงๆ บ้านๆ แต่ใช้งานจริง ไม่ต้องทำเป็นล้ำ
     ScientificName VARCHAR(50) NOT NULL, -- ชื่อวิทยาศาสตร์ของจริง เอาไว้กันชื่อเล่นมั่วจนวิชาการร้องไห้
     ConservationStatus ENUM('Least Concren', 'Near Threatened', 'Vulnerable', 'Endangered', 'Critically Endangered') NOT NULL, -- สะกดตามเอกสารเป๊ะ แม้คำแรกจะดูเหมือนคีย์บอร์ดลื่นก็เถอะ
     PRIMARY KEY (SpeciesID) -- เสาหลักของตารางนี้ ไม่มีมันทุก FK จะกลายเป็นมุกแป้ก
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- InnoDB รับ FK ได้จริง ส่วน utf8mb4 กันภาษาไทยพังยับ

 -- DDL: สร้างตารางโซน
 -- โซนคือบ้านใหญ่ของกรงและกิจกรรม ใครสร้างทีหลังแล้ว FK พัง ก็สมควรโดน DB สั่งสอน
 CREATE TABLE Zone ( -- ตารางโซนของสวนสัตว์ เอาไว้บอกว่าสัตว์ไม่ได้เดินมั่วทั่วแผนที่
     ZoneID INT(5) NOT NULL AUTO_INCREMENT, -- PK ของโซน แจกเลขเองให้จบ ไม่ต้องมานั่งนิ้ว
     ZoneName VARCHAR(30) NOT NULL, -- ชื่อโซนแบบที่คนอ่านแล้วพอรู้เรื่อง
     ZoneDescrip VARCHAR(50) NOT NULL, -- คำอธิบายสั้นๆ ของโซน เอาไว้กัน Front ต้องมโนเอาเอง
     ZoneType VARCHAR(30) NOT NULL, -- ประเภทโซน เผื่อวันหนึ่งอยาก filter แบบไม่ใช้ความรู้สึก
     PRIMARY KEY (ZoneID) -- หลักยึดของ Enclosure, EventSchedule และ Assigned_To ทั้งกอง
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- โครงสร้างแม่อีกตัวของระบบ อย่าทำหล่น

 -- DDL: สร้างตารางเจ้าหน้าที่
 -- ฝั่งคนทำงานก็ต้องมี master table ของมันเอง ไม่ใช่เอารายชื่อไปปะใน Excel แล้วเรียกว่าระบบ
 CREATE TABLE Admin ( -- ตารางเจ้าหน้าที่สวนสัตว์ เก็บตัวจริงของคนที่มาจัดการหลังบ้าน
     AdminID INT(5) NOT NULL AUTO_INCREMENT, -- PK ของเจ้าหน้าที่ เอาไว้ให้ตารางลูกมาเกาะอย่างมีระเบียบ
     FirstName VARCHAR(30) NOT NULL, -- ชื่อจริง ไม่ใช่นามแฝงในกลุ่มไลน์
     Surname VARCHAR(30) NOT NULL, -- นามสกุล เอาไว้แยกคนชื่อซ้ำไม่ให้ปั่นหัว HR
     Email VARCHAR(50) NOT NULL, -- อีเมลทำงาน ใช้ติดต่อและกันข้อมูลซ้ำแบบคนมีระบบ
     Salary INT(6) NOT NULL, -- เงินเดือน เก็บเป็นจำนวนเต็มไปก่อน ชีวิตยังไม่ต้องดราม่าเรื่องสตางค์
     address VARCHAR(100) NOT NULL, -- ที่อยู่ตามเอกสาร ใช้ตัวพิมพ์เล็กไปเลย จะได้รู้ว่าเอกสารต้นทางมีชีวิตจิตใจ
     HireDate DATE NOT NULL, -- วันที่เริ่มงาน เอาไว้ตามประวัติว่าอยู่มาก่อนใครบ้าง
     PRIMARY KEY (AdminID), -- ตัวชี้ขาดว่า Admin คนไหนเป็นใคร
     UNIQUE KEY uq_admin_email (Email) -- อีเมลห้ามซ้ำ ไม่งั้นเดี๋ยว HR ได้ปวดหัวฟรี
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางคนทำงาน จะใช้ FK ต่ออีกหลายจุด ห้ามพลาด

 -- DDL: สร้างตารางโปรโมชั่น
 -- โค้ดลดราคาถ้าไม่แยกเป็นตารางก็เตรียมดู logic เละเป็นโจ๊กใน application layer ได้เลย
 CREATE TABLE Promotion ( -- ตารางโปรโมชั่น เก็บส่วนลดให้เป็นเรื่องเป็นราว ไม่ใช่ hardcode ในโค้ดจนเหม็นไหม้
     PromotionID INT(4) NOT NULL AUTO_INCREMENT, -- PK ของโปรโมชั่น เล็กหน่อยแต่พอ ไม่ต้องทำใหญ่เกินฝัน
     PromotionCode VARCHAR(20) NOT NULL, -- โค้ดที่ผู้ใช้พิมพ์ใส่มา ถ้าซ้ำกันก็เตรียมงงกันทั้งบริษัท
     DiscountAmount DECIMAL(7,2) NOT NULL, -- จำนวนเงินที่ลด เก็บทศนิยมเผื่อวันหนึ่งอยากเล่น 99.99
     Conditions VARCHAR(255) NOT NULL, -- เงื่อนไขการใช้สิทธิ์ เขียนไว้ให้ครบ ไม่ใช่ให้ลูกค้าเดาเอาเอง
     PromotionExpireDate DATETIME NOT NULL, -- วันหมดอายุของโปร อย่าปล่อยโปรตายแล้วยังใช้งานได้ เดี๋ยวการเงินจะมองแรง
     PRIMARY KEY (PromotionID), -- ตัวตั้งต้นของ FK จาก Ticket
     UNIQUE KEY uq_promotion_code (PromotionCode) -- โค้ดโปรห้ามชนกัน ไม่งั้นตีกันแน่
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางนี้ดูเรียบๆ แต่พลาดทีเรื่องเงินล้วนๆ

 -- DDL: สร้างตารางผู้เข้าชม
 -- ฝั่งลูกค้าก็ต้องมี master table ของจริง ไม่ใช่ปล่อยข้อมูลลอยเป็นผีตาม transaction
 CREATE TABLE Visitor ( -- ตารางผู้เข้าชม เก็บตัวตนของคนที่เข้ามาใช้ระบบและซื้อตั๋ว
     VisitorID INT(10) NOT NULL AUTO_INCREMENT, -- PK ของผู้เข้าชม ใช้ INT ยาวหน่อยเพราะคนมาเที่ยวไม่ใช่มีสิบคน
     VisitorFName VARCHAR(30) NOT NULL, -- ชื่อจริงของผู้เข้าชม
     VisitorLName VARCHAR(30) NOT NULL, -- นามสกุลของผู้เข้าชม
     VisitorDateOfBirth DATE NOT NULL, -- วันเกิด เอาไว้ใช้กับเงื่อนไขอายุถ้าระบบโตขึ้น
     VisitorTel VARCHAR(10) NOT NULL, -- เบอร์โทรตามเอกสาร เก็บ 10 หลักแบบบ้านๆ ไปก่อน
     VisitorEmail VARCHAR(50) NOT NULL, -- อีเมลใช้สมัครและติดต่อ คนละคนห้ามชนกัน
     PRIMARY KEY (VisitorID), -- ตัวจริงของ visitor ทั้งระบบ
     UNIQUE KEY uq_visitor_email (VisitorEmail) -- อีเมลไม่ unique คือเปิดประตูให้ข้อมูลซ้ำเดินเข้ามาเอง
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางแม่ของ UserAccount และ Ticket อย่าทำล้ม

 -- ---------------------------------------------
 -- ตารางที่มีความสัมพันธ์ต่อจากตารางหลัก
 -- ---------------------------------------------

 -- DDL: สร้างตารางกรงหรือพื้นที่จัดแสดง
 -- กรงต้องเกิดหลังโซน ไม่งั้น FK จะถามหามารดาเอาได้
 CREATE TABLE Enclosure ( -- ตารางกรงหรือพื้นที่จัดแสดง เป็นลูกของ Zone แบบตรงไปตรงมา
     EnclosureID INT(5) NOT NULL AUTO_INCREMENT, -- PK ของกรง ใช้ผูกสัตว์ทีหลังแบบไม่ต้องใช้ชื่อโซนมานั่งเดา
     ZoneID INT(5) NOT NULL, -- FK ไปหา Zone ตรงๆ เพราะกรงต้องสังกัดโซน ไม่ใช่เร่ร่อน
     EnType ENUM('Indoor', 'Outdoor', 'Aquatic') NOT NULL, -- ประเภทกรง เอาไว้ให้ระบบรู้ว่าสัตว์ไม่ได้อยู่ผิดสภาพแวดล้อม
     Status ENUM('พร้อมใช้งาน', 'กำลังปรับปรุง', 'ปิดใช้งาน') NOT NULL, -- สถานะกรง จะได้รู้ว่ากรงไหนใช้ได้ กรงไหนแตะแล้วเจ็บ
     Capacity INT(2) NOT NULL, -- ความจุของกรง เก็บตรงๆ อย่ามโนว่ากรงเล็กจะอัดสัตว์ได้ไม่จำกัด
     PRIMARY KEY (EnclosureID), -- ตัวระบุตารางลูกของกรง
     CONSTRAINT fk_enclosure_zone FOREIGN KEY (ZoneID) REFERENCES Zone (ZoneID) -- กรงทุกกรงต้องมีโซนแม่ ไม่งั้นข้อมูลลอย
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางลูกตัวแรก เอาให้ถูกตั้งแต่ต้นจะได้ไม่เสียเวลาไล่ซ่อม

 -- DDL: สร้างตารางสัตว์
 -- ตารางนี้เกาะทั้ง Species และ Enclosure แถมยัง self-reference พ่อแม่อีก ถ้าพิมพ์ FK พลาดก็สมควรเจ็บ
 CREATE TABLE Animal ( -- ตารางสัตว์ ตัวเอกของระบบที่มีสายเลือด บ้าน และสายพันธุ์ครบถ้วน
     AnimalID INT(5) NOT NULL AUTO_INCREMENT, -- PK ของสัตว์ เอาไว้ให้ตารางอื่นอ้างแบบไม่ต้องเรียกชื่อเล่น
     AnimalName VARCHAR(30) NOT NULL, -- ชื่อของสัตว์ เอาไว้ให้คนจำได้โดยไม่ต้องท่องรหัส
     Gender ENUM('Male', 'Female') NOT NULL, -- เพศตามเอกสาร ตรงไปตรงมาแบบไม่ต้องพูดเยอะ
     BirthDate DATE NOT NULL, -- วันเกิดของสัตว์ มีไว้คำนวณอายุและทำประวัติให้เป็นเรื่องเป็นราว
     ArrivalDate TIMESTAMP NOT NULL, -- วันเวลาที่เข้าระบบหรือเข้าสวนสัตว์ จะได้ตาม timeline ถูก
     FatherID INT(5) NULL, -- FK พ่อ ปล่อย NULL ได้เพราะโลกจริงไม่ได้รู้ประวัติครอบครัวทุกตัว
     MotherID INT(5) NULL, -- FK แม่ ก็ NULL ได้เหมือนกัน ไม่ต้องฝืนทำเป็นรู้ทุกอย่าง
     SpeciesID INT(5) NOT NULL, -- FK ไป Species เพราะสัตว์ต้องมีสายพันธุ์ ไม่ใช่สิ่งมีชีวิตลึกลับ
     EnclosureID INT(5) NOT NULL, -- FK ไป Enclosure เพราะสุดท้ายมันต้องมีที่อยู่ ไม่ใช่ปล่อยเดินมั่ว
     PRIMARY KEY (AnimalID), -- ตัวหลักของตารางสัตว์
     CONSTRAINT fk_animal_father FOREIGN KEY (FatherID) REFERENCES Animal (AnimalID), -- self FK หาพ่อจากตารางเดียวกัน ฉลาดแต่ต้องพิมพ์ให้ถูก
     CONSTRAINT fk_animal_mother FOREIGN KEY (MotherID) REFERENCES Animal (AnimalID), -- self FK หาแม่ แบบเดียวกันผิดไม่ได้เพราะ DB ไม่ใจดี
     CONSTRAINT fk_animal_species FOREIGN KEY (SpeciesID) REFERENCES Species (SpeciesID), -- ผูกสายพันธุ์ให้แน่น ไม่ให้สัตว์หลุดจักรวาล
     CONSTRAINT fk_animal_enclosure FOREIGN KEY (EnclosureID) REFERENCES Enclosure (EnclosureID) -- ผูกบ้านของสัตว์ให้ชัด จะได้ย้ายกรงได้แบบมีหลักฐาน
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางตัวเอกของระบบ พลาดตรงนี้แล้วงานงอกทั้งสวนสัตว์

 -- DDL: สร้างตารางกิจกรรม
 -- กิจกรรมต้องมีโซนรองรับก่อน ไม่งั้นจะให้โชว์กลางสุญญากาศหรือไง
 CREATE TABLE EventSchedule ( -- ตารางกิจกรรมและการแสดงของสวนสัตว์ เก็บวันเวลาให้ไม่ต้องเดา
     EventID INT(5) NOT NULL AUTO_INCREMENT, -- PK ของกิจกรรม เอาไว้ให้ Show_Reference มาเกาะต่อ
     EventName VARCHAR(30) NOT NULL, -- ชื่อกิจกรรม ให้คนดูรู้ว่ากำลังจะดูอะไร
     EventDate DATE NOT NULL, -- วันที่จัดกิจกรรม
     EventTime TIME NOT NULL, -- เวลาจัดกิจกรรม แยกกับวันที่ตามเอกสาร ถึงจะทำ query เหนื่อยก็ต้องยอม
     EventDetail VARCHAR(50) NOT NULL, -- รายละเอียดสั้นๆ ของกิจกรรม ไม่ใช่ปล่อยว่างจนคนดูงง
     ZoneID INT(5) NOT NULL, -- FK ไป Zone เพราะโชว์ต้องมีสถานที่จริง ไม่ใช่จัดในมิติพิศวง
     PRIMARY KEY (EventID), -- ตัวตั้งต้นของกิจกรรม
     CONSTRAINT fk_eventschedule_zone FOREIGN KEY (ZoneID) REFERENCES Zone (ZoneID) -- ผูกโซนให้ชัด จะได้ไม่หลงเวที
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางกิจกรรมพร้อมให้ query ต่อยอดเรื่องตารางแสดง

 -- DDL: สร้างตารางบัญชีผู้ใช้
 -- [NOTE] เอกสารล่าสุดให้ UserAccount ผูกกับ Visitor แบบ 1:1 ก่อน ใครจะเพิ่มฝั่ง Admin ค่อยทำ migration แยก อย่าจับทุกอย่างยัดหม้อเดียว
 CREATE TABLE UserAccount ( -- ตารางบัญชีผู้ใช้ของผู้เข้าชม เก็บ credential แบบแยกจากข้อมูลส่วนตัวให้พอมีมารยาท
     UserID INT(5) NOT NULL AUTO_INCREMENT, -- PK ของบัญชี เอาไว้ให้ระบบ auth จับคนได้ถูกตัว
     Username VARCHAR(30) NOT NULL, -- ชื่อผู้ใช้ที่คนต้องจำให้ได้เอง อย่าซ้ำจนระบบหัวหมุน
     `Password` VARCHAR(30) NOT NULL, -- baseline ตามเอกสารก่อน เดี๋ยว migration ด้านล่างค่อยขยายให้พอรับ hash ของจริง
     AccountStatus ENUM('ใช้งานอยู่', 'ถูกปิดใช้งาน') NOT NULL, -- สถานะบัญชีเอาไว้ soft delete แบบผู้ดีปลอมๆ
     CreatedAt TIMESTAMP NOT NULL, -- เวลาสร้างบัญชี เก็บไว้ตามประวัติ จะได้รู้ว่าใครเกิดก่อนใคร
     VisitorID INT(10) NOT NULL, -- จับให้ตรงกับ VisitorID ฝั่งแม่ไว้ก่อน ไม่งั้น FK ชอบงอแงเพราะเอกสารบางหน้าชอบให้ขนาดไม่ตรง
     PRIMARY KEY (UserID), -- ตัวจริงของบัญชีผู้ใช้
     UNIQUE KEY uq_useraccount_username (Username), -- Username ห้ามชน ไม่งั้น login จะกลายเป็นตลกร้าย
     UNIQUE KEY uq_useraccount_visitor (VisitorID), -- บังคับ 1:1 กับ Visitor ตามที่เอกสารสั่งมาแบบไม่ต้องต่อรอง
     CONSTRAINT fk_useraccount_visitor FOREIGN KEY (VisitorID) REFERENCES Visitor (VisitorID) -- บัญชีต้องมีเจ้าของที่เป็น Visitor จริง ไม่ใช่ผีจากไหนก็ได้
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตาราง auth ตามเอกสารล่าสุด แม้ logic admin เดิมจะยังคิดถึง EmployeeID อยู่ก็ตาม

 -- DDL: สร้างตารางเบอร์โทรเจ้าหน้าที่
 -- ตารางแยกสำหรับ multivalued attribute ตามตำราเป๊ะๆ จะได้ไม่ต้องยัดเบอร์หลายอันลงคอลัมน์เดียวแบบคนหมดไฟ
 CREATE TABLE Phone ( -- ตารางเบอร์โทรเจ้าหน้าที่ เก็บหลายเบอร์ได้โดยไม่ทำ Admin บวมเป็นลูกโป่ง
     Phone VARCHAR(15) NOT NULL, -- หมายเลขโทรศัพท์หนึ่งรายการของเจ้าหน้าที่
     AdminID INT(5) NOT NULL, -- จับให้ตรงกับ Admin ฝั่งแม่ไว้ก่อน เอกสารบางหน้าเขียน 10 แต่ FK ไม่ชอบเรื่องหยุมหยิมแบบนั้น
     PRIMARY KEY (Phone, AdminID), -- Composite PK กันเบอร์ซ้ำซ้อนในเจ้าหน้าที่คนเดิมแบบง่ายและได้ผล
     CONSTRAINT fk_phone_admin FOREIGN KEY (AdminID) REFERENCES Admin (AdminID) -- ทุกเบอร์ต้องมีเจ้าของ ไม่งั้นจะเก็บไปทำไม
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางแยกเล็กๆ แต่ช่วยให้โครงสร้างไม่ดูบ้านๆ

 -- DDL: สร้างตารางตั๋วเข้าชม
 -- [NOTE] baseline นี้ยังไม่มี TicketToken เพราะบล็อก migration ด้านล่างจะค่อยอัปเกรดความปลอดภัยให้ทีหลัง
 CREATE TABLE Ticket ( -- ตารางตั๋วเข้าชมของผู้ใช้ เก็บสถานะการซื้อและราคาก่อนจะโดน query รุ่นหลังๆ ขยี้ต่อ
     TicketID INT(10) NOT NULL AUTO_INCREMENT, -- PK ของตั๋ว เอาไว้ให้ transaction จับเป้าหมายได้ตรงใบ
     TicketType VARCHAR(20) NOT NULL, -- ประเภทตั๋ว เช่น เด็ก ผู้ใหญ่ หรืออะไรก็ว่าไป
     VisitDate DATE NOT NULL, -- วันที่จะเข้าใช้งานจริง
     TicketExpireDate DATETIME NOT NULL, -- วันหมดอายุของตั๋ว เก็บไว้กันคนถือของเก่ามาเถียง
     PurchaseChannel VARCHAR(50) NULL, -- ช่องทางการซื้อ ปล่อย NULL ได้ก่อนเพราะตั๋วอาจยังค้างชำระ
     PurchaseDate DATETIME NULL, -- วันที่ซื้อจริง ปล่อย NULL ได้จนกว่าจะจ่ายเงินสำเร็จ
     Price DECIMAL(7,2) NOT NULL, -- ราคาตั้งต้นของตั๋ว เก็บแยกไว้ก่อนหักส่วนลดแบบคนมีหลักฐาน
     VisitorID INT(10) NOT NULL, -- FK ไป Visitor เพราะตั๋วทุกใบต้องมีเจ้าของ
     PromotionID INT(4) NULL, -- FK ไป Promotion ปล่อย NULL ได้เพราะไม่ใช่ทุกคนจะฉลาดพอใช้โค้ดลดราคา
     PRIMARY KEY (TicketID), -- ตัวจริงของตั๋วทุกใบ
     CONSTRAINT fk_ticket_visitor FOREIGN KEY (VisitorID) REFERENCES Visitor (VisitorID), -- เจ้าของตั๋วต้องมีตัวตนจริงในระบบ
     CONSTRAINT fk_ticket_promotion FOREIGN KEY (PromotionID) REFERENCES Promotion (PromotionID) -- โปรโมชั่นถ้ามีก็ต้องเป็นตัวที่มีจริง ไม่ใช่โค้ดลมๆ
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางการเงินและการเข้าใช้งานผสมกันอยู่ตรงนี้แหละ อย่ามือสั่น

 -- ---------------------------------------------
 -- ตารางเชื่อมความสัมพันธ์
 -- ---------------------------------------------

 -- DDL: สร้างตารางเชื่อมสัตว์กับกิจกรรม
 -- M:N ของแท้ ถ้าไม่ทำ junction table ก็เตรียม duplicate data จนอยากลบโปรเจกต์ทิ้ง
 CREATE TABLE Show_Reference ( -- ตารางเชื่อมว่า event ไหนมีสัตว์ตัวไหนร่วมแสดงบ้าง
     EventID INT(5) NOT NULL, -- FK ไป EventSchedule ฝั่งกิจกรรม
     AnimalID INT(5) NOT NULL, -- FK ไป Animal ฝั่งสัตว์
     AnimalDetail VARCHAR(100) NOT NULL, -- รายละเอียดบทบาทหรือข้อมูลเพิ่มของสัตว์ในโชว์นั้น
     PRIMARY KEY (EventID, AnimalID), -- Composite PK กันคู่ซ้ำแบบจบๆ ไม่ต้องมี ID หลอกโลกเพิ่ม
     CONSTRAINT fk_show_reference_event FOREIGN KEY (EventID) REFERENCES EventSchedule (EventID), -- event ต้องมีจริง ไม่ใช่ event ผี
     CONSTRAINT fk_show_reference_animal FOREIGN KEY (AnimalID) REFERENCES Animal (AnimalID) -- animal ก็ต้องมีจริง ไม่ใช่เรียกตัวละครรับเชิญจากนอกจักรวาล
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางเชื่อม M:N มาตรฐาน อย่าพยายามฉลาดเกินตำราโดยไม่จำเป็น

 -- DDL: สร้างตารางมอบหมายโซนให้เจ้าหน้าที่
 -- อีกหนึ่ง M:N ที่ตรงไปตรงมา โซนหนึ่งมีเจ้าหน้าที่หลายคน เจ้าหน้าที่หนึ่งดูหลายโซน ก็ทำตารางกลางไป อย่าดันทุรัง
 CREATE TABLE Assigned_To ( -- ตารางประวัติการมอบหมายโซนให้เจ้าหน้าที่แต่ละคน
     ZoneID INT(5) NOT NULL, -- FK ไป Zone ฝั่งโซน
     AdminID INT(5) NOT NULL, -- FK ไป Admin ฝั่งเจ้าหน้าที่
     AssignedDate DATE NOT NULL, -- วันที่เริ่มมอบหมาย จะได้ไม่เถียงว่าใครรับผิดชอบก่อน
     PRIMARY KEY (ZoneID, AdminID), -- Composite PK กันคู่ซ้ำแบบไม่ต้องเล่นของแถม
     CONSTRAINT fk_assigned_to_zone FOREIGN KEY (ZoneID) REFERENCES Zone (ZoneID), -- โซนต้องมีอยู่จริงถึงจะมอบหมายได้
     CONSTRAINT fk_assigned_to_admin FOREIGN KEY (AdminID) REFERENCES Admin (AdminID) -- เจ้าหน้าที่ก็ต้องมีตัวตนจริง ไม่ใช่ชื่อที่พิมพ์เล่นๆ
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตารางเชื่อมหน้าที่งาน ใครรับผิดชอบอะไรจะได้มีหลักฐาน

 -- DDL: สร้างตารางประวัติการจัดการบัญชีโดย Admin
 -- Audit trail แบบไม่โลกสวย ใครแก้อะไรไว้ก็ต้องทิ้งรอยตีนไว้ใน DB
 CREATE TABLE Manage_By ( -- ตารางบันทึกว่า Admin คนไหนไปยุ่งกับ UserAccount ไหนมาบ้าง
     UserID INT(5) NOT NULL, -- FK ไป UserAccount ฝั่งบัญชีผู้ใช้
     AdminID INT(5) NOT NULL, -- FK ไป Admin ฝั่งคนที่ลงมือแก้
     Edit_date DATE NOT NULL, -- วันที่แก้ไข เก็บให้ครบจะได้ย้อนดูได้
     Edit_detail VARCHAR(255) NOT NULL, -- รายละเอียดการแก้ไข เขียนให้พอรู้เรื่อง ไม่ใช่ใส่แค่คำว่าแก้แล้ว
     PRIMARY KEY (AdminID, UserID), -- Composite PK ตามเอกสาร จับคู่คนแก้กับบัญชีที่โดนแก้แบบตรงๆ
     CONSTRAINT fk_manage_by_user FOREIGN KEY (UserID) REFERENCES UserAccount (UserID), -- บัญชีที่โดนแก้ต้องมีจริง
     CONSTRAINT fk_manage_by_admin FOREIGN KEY (AdminID) REFERENCES Admin (AdminID) -- คนแก้ก็ต้องเป็น Admin จริง ไม่ใช่เทพจากไหนไม่รู้
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; -- ตาราง audit ที่ช่วยกันงานเผาในวันโดนถามหาคนรับผิดชอบ


 -- =============================================
 -- FUNCTION: สมัครสมาชิกและจัดการบัญชีผู้ใช้งาน
 -- =============================================

 -- [MIGRATION] บังคับ Password เก็บเป็น Hash เท่านั้น VARCHAR(255) กว้างพอรองรับ bcrypt/argon2
-- ถ้าใครยังเก็บ plain text อยู่ถือว่าควรออกจากวงการ
ALTER TABLE UserAccount
MODIFY COLUMN `Password` VARCHAR(255) NOT NULL;

-- CREATE: บันทึกข้อมูล Visitor ก่อนสร้างบัญชี
-- [CONCURRENCY] ถ้าจะแก้ race condition จริงๆ ต้องมี UNIQUE constraint บน VisitorEmail ด้วย
-- application layer ต้อง catch Duplicate Entry error เอง อย่าเขียน SELECT เช็กก่อน INSERT เด็ดขาด มันคือ anti-pattern
-- INSERT ตรงๆ ไปเลยพังก็ช่างมัน เดี๋ยวแอพจัดการเอง
INSERT INTO Visitor (VisitorFName, VisitorLName, VisitorDateOfBirth, VisitorTel, VisitorEmail)
VALUES (?, ?, ?, ?, ?);

-- CREATE: สร้างบัญชีผู้ใช้โดยผูกกับ Visitor
-- [NOTE] Password ตรงนี้ต้องรับ Hash มาจากฝั่ง Backend แล้วเท่านั้น ย้ำ!
-- แอบยัด 'ใช้งานอยู่' เป็น default ไปเลย ขี้เกียจไปทำ flow ยืนยันอีเมลตอนนี้
INSERT INTO UserAccount (VisitorID, CreatedAt, AccountStatus, `Password`, Username)
VALUES (?, NOW(), 'ใช้งานอยู่', ?, ?);

-- READ: ดูข้อมูลส่วนตัวของผู้ใช้
-- ดึงข้อมูลข้าม 2 ตารางเฉพาะ account ที่ active
-- JOIN ไปเถอะ 2 ตารางแค่นี้ DB ไม่ร้องหรอก
SELECT ua.UserID, ua.Username, ua.AccountStatus, ua.CreatedAt,
       v.VisitorID, v.VisitorFName, v.VisitorLName, v.VisitorDateOfBirth, v.VisitorTel, v.VisitorEmail
FROM UserAccount ua
JOIN Visitor v ON ua.VisitorID = v.VisitorID
WHERE ua.UserID = ? AND ua.AccountStatus = 'ใช้งานอยู่';

-- UPDATE: แก้ไขข้อมูลส่วนตัว
-- JOIN UPDATE โหดๆ ไปเลยเพื่อแก้เฉพาะ profile ของ account ที่ยัง active
-- เอาให้อยู่หมัดใน query เดียว ไม่ต้อง select ออกมาแก้แล้วยัดกลับไปให้เปลือง RTT
UPDATE Visitor v
JOIN UserAccount ua ON v.VisitorID = ua.VisitorID
SET v.VisitorTel = ?, v.VisitorEmail = ?
WHERE ua.UserID = ? AND ua.AccountStatus = 'ใช้งานอยู่';

-- UPDATE: เปลี่ยนรหัสผ่าน
-- [SECURITY] ไม่ตรวจ old password ใน query แล้ว! เป็นหน้าที่ของ Application (bcrypt.compare)
-- SQL มีหน้าที่แค่อัปเดต Hash ใหม่เข้า DB ให้ถูก User เท่านั้น
-- อย่าให้จับได้ว่าเอา password ไป where นะ ตีมือหัก
UPDATE UserAccount
SET `Password` = ?
WHERE UserID = ? AND AccountStatus = 'ใช้งานอยู่';

-- DELETE: ยกเลิกบัญชีแบบผู้ดี (Soft Delete)
-- [DESIGN] ไม่ลบ row จริงเพราะเดี๋ยว Foreign Key พัง แค่เปลี่ยน Status พอ
-- เก็บศพไว้ดูเล่นเผื่อมีปัญหาทางการเงินตามมาทีหลัง
UPDATE UserAccount
SET AccountStatus = 'ถูกปิดใช้งาน'
WHERE UserID = ?;

-- =============================================
-- FUNCTION: เข้าสู่ระบบและยืนยันตัวตน
-- =============================================

-- READ: ตรวจสอบข้อมูลเข้าสู่ระบบและ role ที่อนุมานจาก schema
-- [SECURITY] ดึง PasswordHash กลับไปให้ Backend ตรวจ อย่าใช้ `AND Password = ?` ใน WHERE เด็ดขาด!
-- [DESIGN] IsAdmin สร้างจาก logic ง่ายๆ: FALSE ไปเลย เพราะ UserAccount ผูกกับ Visitor เท่านั้น
-- LIMIT 1 ไว้กันเหนียว เผื่อเผลอแจก Username ซ้ำจะได้ไม่พังคาที่
SELECT ua.UserID, ua.Username, ua.AccountStatus, ua.VisitorID,
       ua.`Password` AS PasswordHash,
       FALSE AS IsAdmin -- schema นี้ไม่มี EmployeeID ใน UserAccount บัญชีคือ Visitor ล้วนๆ
FROM UserAccount ua
WHERE ua.Username = ? AND ua.AccountStatus = 'ใช้งานอยู่'
LIMIT 1;

-- =============================================
-- FUNCTION: จัดการสิทธิ์ผู้ใช้งาน
-- =============================================

-- READ: เช็กสิทธิ์การใช้งานจาก UserID (เอาไว้ Re-verify token)
-- เหมือนข้างบนเป๊ะ แค่เปลี่ยนเป็นเช็กจาก UserID เปลือง query ชะมัดแต่ก็ต้องทำ
SELECT ua.UserID, ua.Username, ua.AccountStatus, ua.VisitorID,
       FALSE AS IsAdmin -- เหมือนกัน ไม่มี Admin ในตารางนี้หรอก เลิกฝัน
FROM UserAccount ua
WHERE ua.UserID = ? AND ua.AccountStatus = 'ใช้งานอยู่'
LIMIT 1;

-- READ: ดึงข้อมูลบัญชีทั้งหมดสำหรับ Admin
-- ดึงพรืดเดียวจบ เอาข้อมูล Visitor กับ Admin มาต่อกัน
-- [NOTE] กรองเฉพาะคนที่ 'ใช้งานอยู่' ไม่เอาศพมาแสดง
-- JOIN ไปหา Visitor ตรงๆ เพราะตารางนี้มีแต่ Visitor เท่านั้นแหละตอนนี้
SELECT ua.UserID, ua.Username, ua.AccountStatus, ua.CreatedAt,
       ua.VisitorID,
       v.VisitorFName, v.VisitorLName, v.VisitorEmail
FROM UserAccount ua
JOIN Visitor v ON ua.VisitorID = v.VisitorID
WHERE ua.AccountStatus = 'ใช้งานอยู่'
ORDER BY ua.CreatedAt DESC;

-- READ: ค้นหาบัญชีผู้ใช้ตาม Username
-- [PERF] LIKE 'prefix%' ใช้ Index ได้ อย่าทะลึ่งใส่ '%x%' เด็ดขาดถ้าไม่อยากให้ DB ร้องไห้
-- Search แค่ Username พอละ ขี้เกียจไปไล่หาในอีเมลให้เปลือง CPU
SELECT ua.UserID, ua.Username, ua.AccountStatus, ua.CreatedAt,
       v.VisitorEmail
FROM UserAccount ua
JOIN Visitor v ON ua.VisitorID = v.VisitorID
WHERE ua.AccountStatus = 'ใช้งานอยู่' AND ua.Username LIKE CONCAT(?, '%');

-- UPDATE: อัปเดตสถานะบัญชี
-- ให้ Admin สั่งแบน (ถูกปิดใช้งาน) หรือปลดแบน (ใช้งานอยู่) ได้
-- ควบคุมชะตาชีวิต User ง่ายๆ ด้วยบรรทัดเดียว
UPDATE UserAccount
SET AccountStatus = ?
WHERE UserID = ?;

-- CREATE: บันทึกว่า Admin คนไหนแก้บัญชีใด
-- Audit Trail ขำๆ ใครทำอะไรเมื่อไหร่บันทึกไว้หมด
-- เก็บไว้เป็นหลักฐานเผื่อมีใครซวย จะได้หาแพะเจอ
INSERT INTO Manage_By (AdminID, UserID, Edit_date, Edit_detail)
VALUES (?, ?, CURDATE(), ?);

-- DELETE: ยกเลิกบัญชีผู้ใช้งาน (Soft Delete)
-- ซ้ำกับข้างบน แต่เอาไว้ให้ Admin ใช้
-- แบนทิ้งไปเลย ไม่ต้องถามความสมัครใจ
UPDATE UserAccount
SET AccountStatus = 'ถูกปิดใช้งาน'
WHERE UserID = ?;

-- =============================================
-- FUNCTION: จัดการข้อมูลสัตว์
-- =============================================

-- CREATE: เพิ่มข้อมูลสัตว์ใหม่
-- ท่ามาตรฐาน INSERT ปกติ
-- ช่องเพียบ พิมพ์ผิดชีวิตเปลี่ยน ยัดๆ ไปเถอะ
INSERT INTO Animal (EnclosureID, SpeciesID, AnimalName, Gender, BirthDate, ArrivalDate, FatherID, MotherID)
VALUES (?, ?, ?, ?, ?, ?, ?, ?);

-- READ: ดูข้อมูลสัตว์ทั้งหมดสำหรับ Admin
-- JOIN 3 ชั้นเพื่อเอาชื่อสายพันธุ์และชื่อโซนมาโชว์ในตารางเดียว
-- LEFT JOIN กรงกับโซนเผื่อมันยังเร่ร่อนไม่มีที่อยู่
SELECT a.AnimalID, a.AnimalName, s.SpeciesName, s.ScientificName, a.Gender, a.BirthDate, a.ArrivalDate,
       e.EnclosureID, z.ZoneName, s.ConservationStatus
FROM Animal a
JOIN Species s ON a.SpeciesID = s.SpeciesID
LEFT JOIN Enclosure e ON a.EnclosureID = e.EnclosureID
LEFT JOIN Zone z ON e.ZoneID = z.ZoneID
ORDER BY a.AnimalName ASC;

-- READ: ดูรายละเอียดสัตว์สำหรับ Admin
-- ข้อมูลมาเต็มแม็กซ์ JOIN แหลก เอาไว้ทำหน้ารายละเอียดสัตว์
-- ดึงมาก่อน ใช้ไม่ใช้เดี๋ยวค่อยไป filter ทิ้งฝั่ง Frontend เองละกัน
SELECT a.AnimalID, a.AnimalName, a.Gender, a.BirthDate, a.ArrivalDate,
       s.SpeciesID, s.SpeciesName, s.ScientificName, s.TaxonomyCategory, s.Origin, s.AverageLifespan, s.ConservationStatus,
       e.EnclosureID, e.EnType, e.Status AS EnclosureStatus, e.Capacity,
       z.ZoneID, z.ZoneName, z.ZoneDescrip, z.ZoneType
FROM Animal a
JOIN Species s ON a.SpeciesID = s.SpeciesID
LEFT JOIN Enclosure e ON a.EnclosureID = e.EnclosureID
LEFT JOIN Zone z ON e.ZoneID = z.ZoneID
WHERE a.AnimalID = ?;

-- UPDATE: แก้ไขข้อมูลสัตว์
-- แตะเฉพาะข้อมูลชีววิทยา ไม่ยุ่งกับสถานที่
-- อัปเดตยกแผง ไม่สนลูกอีช่างขอแก้แค่ฟิลด์เดียว
UPDATE Animal
SET SpeciesID = ?, AnimalName = ?, Gender = ?, BirthDate = ?, ArrivalDate = ?, FatherID = ?, MotherID = ?
WHERE AnimalID = ?;

-- UPDATE: ย้ายกรงของสัตว์
-- แยก function ชัดเจน นี่คือการย้ายบ้าน
-- ย้ายกรงรัวๆ อย่าลืมว่าต้องมีกรงให้ย้ายด้วยล่ะ
UPDATE Animal
SET EnclosureID = ?
WHERE AnimalID = ?;

-- DELETE: ลบข้อมูลสัตว์
-- [WARNING] Hard Delete! แน่ใจนะว่าไม่มี FK constraint ติดอยู่ในตารางอื่น? ถ้ามีลบไม่ลงนะ
-- ถ้าลบแล้วระบบพังก็ตัวใครตัวมันล่ะงานนี้
DELETE FROM Animal
WHERE AnimalID = ?;

-- =============================================
-- FUNCTION: ดูข้อมูลสัตว์และรายละเอียด
-- =============================================

-- READ: ค้นหาสัตว์จากชื่อ
-- [PERF] บังคับค้นหาแบบ Prefix (เริ่มด้วยคำที่พิมพ์) เพื่อให้ Index บน AnimalName ทำงานได้
-- ห้ามแอบเติม % ไว้ข้างหน้าเด็ดขาด ฉันดักไว้แล้ว!
SELECT a.AnimalID, a.AnimalName, s.SpeciesName, s.ScientificName, a.Gender, a.BirthDate, s.ConservationStatus
FROM Animal a
JOIN Species s ON a.SpeciesID = s.SpeciesID
WHERE a.AnimalName LIKE CONCAT(?, '%');

-- READ: ค้นหาสัตว์จากประเภท/สายพันธุ์
-- Exact match เร็วสุดๆ
-- ปังๆ โดนใจ index หาเจอในเสี้ยววิ
SELECT a.AnimalID, a.AnimalName, s.SpeciesID, s.SpeciesName
FROM Animal a
JOIN Species s ON a.SpeciesID = s.SpeciesID
WHERE a.SpeciesID = ?;

-- READ: ค้นหาสัตว์จากโซน
-- ขี่ JOIN ขึ้นไปจาก Animal -> Enclosure -> Zone ท่าเบสิกของ schema แบบนี้
-- ใครออกแบบให้สัตว์ไม่ได้อยู่โซนตรงๆ วะ ซับซ้อนชิบเป๋ง แต่ก็ทำได้
SELECT a.AnimalID, a.AnimalName, s.SpeciesName, z.ZoneName
FROM Animal a
JOIN Species s ON a.SpeciesID = s.SpeciesID
JOIN Enclosure e ON a.EnclosureID = e.EnclosureID
JOIN Zone z ON e.ZoneID = z.ZoneID
WHERE z.ZoneID = ?;

-- READ: ดูรายละเอียดสัตว์แบบเต็ม รวมข้อมูลพ่อแม่
-- [PRO LEVEL] Self-Join 2 ชั้น เพื่อดึงชื่อพ่อ(sire) และชื่อแม่(dam) ใน Query เดียว
-- LEFT JOIN โคตรสำคัญตรงนี้ ไม่งั้นตัวไหนกำพร้าจะหายไปจากผลลัพธ์เลย
-- เอาให้สุด ดึงมาหมดทั้งโคตรเหง้าศักราช
SELECT a1.AnimalID, a1.AnimalName, a1.Gender, a1.BirthDate, a1.ArrivalDate,
       s.SpeciesName, s.ScientificName, s.TaxonomyCategory, s.Origin, s.AverageLifespan, s.ConservationStatus,
       sire.AnimalName AS FatherName,
       dam.AnimalName AS MotherName,
       e.EnclosureID, e.EnType, e.Status AS EnclosureStatus, e.Capacity,
       z.ZoneName
FROM Animal a1
JOIN Species s ON a1.SpeciesID = s.SpeciesID
LEFT JOIN Animal sire ON a1.FatherID = sire.AnimalID
LEFT JOIN Animal dam ON a1.MotherID = dam.AnimalID
LEFT JOIN Enclosure e ON a1.EnclosureID = e.EnclosureID
LEFT JOIN Zone z ON e.ZoneID = z.ZoneID
WHERE a1.AnimalID = ?;

-- READ: ค้นหาสัตว์จากหมวดหมู่ Conservation Status
-- ตรงไปตรงมา ไม่มีอะไรซับซ้อน
-- สถานะใกล้สูญพันธุ์ก็ดึงออกมาโชว์ให้หมด จะได้สงสาร
SELECT a.AnimalID, a.AnimalName, s.SpeciesName, s.ConservationStatus
FROM Animal a
JOIN Species s ON a.SpeciesID = s.SpeciesID
WHERE s.ConservationStatus = ?;

-- =============================================
-- FUNCTION: ดูข้อมูลโซนและแผนที่สวนสัตว์
-- =============================================

-- READ: ดึงข้อมูลโซนทั้งหมด
-- เอาไว้ render list โซนเริ่มต้น
-- กวาดมาให้หมด โซนมีไม่เยอะหรอก ไม่ต้องทำ Pagination ให้ปวดหัว
SELECT ZoneID, ZoneName, ZoneDescrip, ZoneType -- 4 field ที่ Front ต้องการทั้งหมดอยู่ดี ดึงมาเลย
FROM Zone; -- Full scan แต่โซนมีแค่หยิบมือ ไม่ตายหรอก

-- READ: ค้นหาโซนจากชื่อ
-- [PERF] Prefix search ใช้ index ได้
-- ไว้ทำ Dropdown ให้คนหาโซนแบบกากๆ
SELECT ZoneID, ZoneName -- แค่ ID กับชื่อ ทำ Dropdown ก็พอ ไม่ต้องดึง Description มาเปลืองแบนด์วิดท์
FROM Zone
WHERE ZoneName LIKE CONCAT(?, '%'); -- prefix search ใช้ index บน ZoneName ได้ อย่าใส่ % ข้างหน้าเด็ดขาด

-- READ: ดูรายละเอียดโซนพร้อมจำนวน Enclosure
-- [DATA INTEGRITY] Aggregate พร้อม LEFT JOIN เพื่อนับกรงทั้งหมดในโซน ถ้าไม่มีกรงก็ออก 0
-- จัด GROUP BY เต็มยศเพราะโหมด ONLY_FULL_GROUP_BY มันบังคับ ขัดใจชะมัด
SELECT z.ZoneID, z.ZoneName, z.ZoneDescrip, z.ZoneType, COUNT(e.EnclosureID) AS TotalEnclosures -- นับกรงรวมใน Zone นี้ ถ้าไม่มีกรงได้ 0 ดีกว่าหาย
FROM Zone z
LEFT JOIN Enclosure e ON z.ZoneID = e.ZoneID -- LEFT เพราะโซนว่างๆ ไม่มีกรงก็ต้องออกมา ได้ COUNT = 0
WHERE z.ZoneID = ? -- ดึงแค่ Zone เดียวตาม ID ไม่ full scan
GROUP BY z.ZoneID, z.ZoneName, z.ZoneDescrip, z.ZoneType; -- ต้อง list ทุก non-aggregate column เพราะ ONLY_FULL_GROUP_BY บังคับ ขัดใจแต่ก็ถูก

-- READ: ดูรายชื่อสัตว์ทั้งหมดในโซน
-- ดิ่งลงไปหา Animal จาก Zone -> Enclosure
-- สัตว์ตัวไหนกรงพัง ไม่มีกรงอยู่ ก็หายวับไปกับสายลมจาก INNER JOIN อันนี้แหละ
SELECT a.AnimalID, a.AnimalName, s.SpeciesName, e.EnclosureID -- field หลักสำหรับ list สัตว์ในโซน
FROM Animal a
JOIN Species s ON a.SpeciesID = s.SpeciesID -- ต้องการชื่อสปีชีส์มาโชว์ด้วย ไม่งั้น ID ดิบๆ ดูไม่รู้เรื่อง
JOIN Enclosure e ON a.EnclosureID = e.EnclosureID -- INNER JOIN ดังนั้นสัตว์ที่ไม่มีกรง = หายไปเลย ใครออกแบบ schema นี้รู้ตัวนะ
WHERE e.ZoneID = ?; -- filter ผ่านกรง -> โซน เพราะ Animal ไม่มี ZoneID ตรงๆ ทางเดียวที่ทำได้ใน schema นี้

-- READ: ดูกิจกรรมที่จัดในโซน
-- List schedule กิจกรรมตาม Zone
-- ดึงมาโชว์หน้าโซนตรงๆ
SELECT EventID, EventName, EventDate, EventTime, EventDetail -- field ที่ต้องโชว์ใน event card ของหน้าโซน
FROM EventSchedule
WHERE ZoneID = ?; -- กรองกิจกรรมของ Zone นี้โดยตรง ZoneID ต้องมี index นะ

-- READ: สรุปภาพรวมทุกโซน (schema ปัจจุบันยังไม่มีพิกัด map)
-- [TODO] ถ้าจะทำ map จริงๆ ต้องไปเพิ่ม column MapCoordinateX, Y ในตาราง Zone ก่อน
-- ตอนนี้ก็ส่งข้อมูลขยะไปให้ Frontend มโนแผนที่เอาเองก่อนละกัน
SELECT ZoneID, ZoneName, ZoneType, ZoneDescrip -- ซ้ำกับ query แรกเลย แค่สลับลำดับ column แต่ purpose ต่างกันคือส่งให้ Frontend มโนแผนที่
FROM Zone; -- [TODO] ถ้าอยากทำ map จริงๆ ต้องไปเพิ่ม MapX, MapY ใน Zone ก่อน ตอนนี้ full scan ส่งขยะไปก่อนละกัน

-- =============================================
-- FUNCTION: ดูตารางการแสดงสัตว์
-- =============================================

-- READ: ดึงตารางการแสดงทั้งหมดที่ยังไม่ผ่านมา
-- [LOGIC] กรองเฉพาะโชว์ในอนาคต (วันที่เกินวันนี้) หรือ (วันนี้ แต่เวลาเกินตอนนี้)
-- ถ้าไม่อยากโชว์ของเก่าให้โดนด่า ก็ต้องเขียนโคตรเงื่อนไข OR แบบนี้แหละ
SELECT EventID, EventName, EventDate, EventTime, ZoneID, EventDetail -- ทุก field ที่ calendar หน้า schedule ต้องการ
FROM EventSchedule
WHERE (EventDate > CURDATE()) OR (EventDate = CURDATE() AND EventTime >= CURTIME()) -- อนาคตล้วนๆ: วันหน้า หรือ วันนี้แต่เวลายังไม่ผ่าน OR condition นี้โหดพอสมควร
ORDER BY EventDate ASC, EventTime ASC; -- เรียงจากใกล้สุดก่อน UX พื้นฐานที่ลืมทำกันบ่อยมาก

-- READ: กรองตารางการแสดงตามวันที่
-- Exact match ตามวันที่ระบุ
-- โชว์ของวันไหนก็ดึงวันนั้น จบๆ ไป
SELECT EventID, EventName, EventTime, ZoneID, EventDetail -- ไม่ดึง EventDate เพราะ WHERE filter มาแล้ว ดึงมาก็ซ้ำซ้อน
FROM EventSchedule
WHERE EventDate = ?; -- exact match วันที่ ใช้ index ได้ถ้ามี index บน EventDate

-- READ: กรองตารางการแสดงตามประเภท/คำสำคัญ
-- ค้นหาชื่อและรายละเอียดกิจกรรม
-- LIKE บ้าบอคอแตก หวังว่าข้อมูลคงไม่ถึงล้านบรรทัดนะ ไม่งั้นระเบิด
SELECT EventID, EventName, EventDate, EventTime, ZoneID, EventDetail -- ดึงครบสำหรับหน้า search result
FROM EventSchedule
WHERE EventName LIKE CONCAT(?, '%') OR EventDetail LIKE CONCAT(?, '%'); -- prefix ทั้งคู่ แต่ OR ทำให้ optimizer ต้องทำงานหนักขึ้น ระวังถ้าข้อมูลเยอะ

-- READ: ดูรายละเอียดการแสดง พร้อมรายชื่อสัตว์ที่ร่วมแสดงและโซนที่จัด
-- [AGGREGATION] GROUP_CONCAT รวบชื่อสัตว์ทุกตัวที่ร่วมโชว์มาเป็น string เดียว คั่นด้วย comma ฝั่ง client จะได้ไม่ต้องลูปแมพเอง
-- หน้าที่ของ SQL คือทำ data ให้ย่อยง่ายสุด ฝั่งโน้นจะได้ไม่ต้องเขียนโค้ดเยิ่นเย้อ
SELECT es.EventID, es.EventName, es.EventDate, es.EventTime, es.EventDetail, -- ข้อมูลหลักของ event ทั้งหมด
       z.ZoneName, -- ชื่อโซน JOIN มาโชว์แทน ZoneID ดิบๆ
       GROUP_CONCAT(a.AnimalName SEPARATOR ', ') AS ParticipatingAnimals -- รวมชื่อสัตว์ทุกตัวเป็น string เดียว Front ไม่ต้องลูปเองอีกแล้ว
FROM EventSchedule es
JOIN Zone z ON es.ZoneID = z.ZoneID -- INNER JOIN เพราะ event ต้องมีโซนเสมอ ถ้าโซนหายก็ควรพัง
LEFT JOIN Show_Reference sr ON es.EventID = sr.EventID -- LEFT เผื่อ event ที่ไม่มีสัตว์ร่วมแสดงจะได้ไม่หายไป
LEFT JOIN Animal a ON sr.AnimalID = a.AnimalID -- LEFT ตามมา ถ้าไม่มีสัตว์ ParticipatingAnimals จะเป็น NULL
WHERE es.EventID = ? -- ระบุ event เดียว ไม่ดึงมาทั้งหมด
GROUP BY es.EventID, es.EventName, es.EventDate, es.EventTime, es.EventDetail, z.ZoneName; -- GROUP_CONCAT บังคับ GROUP BY ทุก non-aggregate column ไม่มีทางลัด

-- =============================================
-- FUNCTION: ค้นหาและแนะนำข้อมูล
-- =============================================

-- READ: ค้นหาแบบ Global Search (สัตว์ + โซน + กิจกรรม)
-- [PERF] ยอมใช้ UNION กวาด 3 ตารางเพราะต้องการผลรวมศูนย์กลาง ค้นด้วย prefix สบายๆ
-- โคตร overhead แต่ก็ต้องทำเพราะ User อยากค้นปุ่มเดียวเจอทุกสิ่งครอบจักรวาล
SELECT 'Animal' AS Type, a.AnimalID AS ID, a.AnimalName AS Name -- hardcode Type string ไว้ Front จะได้รู้ว่า row นี้คืออะไร
FROM Animal a
WHERE a.AnimalName LIKE CONCAT(?, '%') -- prefix search สัตว์ ใช้ index ได้
UNION -- UNION ไม่ใช่ UNION ALL บล็อก duplicate อยู่แล้ว ช้ากว่า ALL นิดนึงแต่ยอมได้
SELECT 'Zone' AS Type, z.ZoneID AS ID, z.ZoneName AS Name -- ชุดเดียวกันสำหรับโซน
FROM Zone z
WHERE z.ZoneName LIKE CONCAT(?, '%') -- prefix search โซน
UNION -- แบบเดียวกันเลย รูปแบบ UNION นี้แหล่มาก แต่ต้องทำเพื่อ search ปุ่มเดียว
SELECT 'Event' AS Type, es.EventID AS ID, es.EventName AS Name -- สุดท้ายคือกิจกรรม
FROM EventSchedule es
WHERE es.EventName LIKE CONCAT(?, '%'); -- prefix สุดท้าย 3 ? 3 ค่า อย่าลืมใส่ param ให้ครบ Backend จะเหนือย

-- READ: แนะนำสัตว์ที่อยู่ในสถานะใกล้สูญพันธุ์
-- [DESIGN] ดึงตัวที่น่าสนใจมาโชว์หน้าแรก
-- สุ่มโชว์ 5 ตัวที่น่าสงสารที่สุด หวังว่าคนจะคลิกเข้าไปดู
SELECT a.AnimalID, a.AnimalName, s.SpeciesName -- minimal field เอาไว้แค่ card หน้าแรก
FROM Animal a
JOIN Species s ON a.SpeciesID = s.SpeciesID -- ต้องการ ConservationStatus กับชื่อสปีชีส์จาก Species เลย JOIN
WHERE s.ConservationStatus IN ('Endangered', 'Critically Endangered') -- เฉพาะสัตว์ใกล้สูญพันธุ์ สวสามหน้าแรกให้ได้สงสารสักนิด
ORDER BY a.AnimalName ASC -- เรียง A-Z ตายตัว ตัด ORDER BY RAND() ที่ช้ากว่านี้ 3 เท่า
LIMIT 5; -- แค่ 5 ตัวพอ หน้าแรกไม่ใช่ Zoo Annual Report

-- READ: แนะนำกิจกรรมที่กำลังจะมาถึงภายใน 2 ชั่วโมง
-- [LOGIC] เล่นกับ TIMESTAMP(Date, Time) ประกอบร่างเทียบกับ NOW() แบบเป๊ะๆ
-- ฟังก์ชันปราบเซียน ใครใช้ Date กับ Time แยกตารางกัน ก็ต้องมาทนเขียนอะไรเหนื่อยๆ แบบนี้
SELECT EventID, EventName, EventDate, EventTime, ZoneID -- field สำหรับโชว์ card กิจกรรมใกล้ๆ
FROM EventSchedule
WHERE TIMESTAMP(EventDate, EventTime) BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 2 HOUR) -- ประกอบ Date+Time เป็น TIMESTAMP แล้วเทียบกับ NOW() เพราะ schema แยก column ไว้ เหนือยแต่เป็นทางเดียว
ORDER BY EventDate ASC, EventTime ASC; -- เรียงจากใกล้สุดก่อน จะรู้ว่ามีอะไรเดี๋ยวนี้

-- READ: แนะนำสัตว์ที่เข้าร่วมกิจกรรมบ่อยที่สุด
-- [DATA] สัตว์ที่ฮอตที่สุด โผล่ในตาราง Show_Reference บ่อยสุด
-- ไอตัวไหนโดนใช้งานหนักสุดก็ขึ้น Top Chart ไปเลย
SELECT a.AnimalID, a.AnimalName, COUNT(sr.EventID) AS EventCount -- นับว่าแต่ละตัวโผล่ใน event กี่ครั้ง
FROM Animal a
JOIN Show_Reference sr ON a.AnimalID = sr.AnimalID -- INNER JOIN กรองเฉพาะสัตว์ที่เคยร่วมแสดง ตัวที่ไม่เคยโครงสร้าง = ไม่ติด Top Chart
GROUP BY a.AnimalID, a.AnimalName -- GROUP BY สองตัว เพราะ ONLY_FULL_GROUP_BY บังคับเสมอ
ORDER BY EventCount DESC, a.AnimalName ASC -- rank ตามความดังเป็นอันดับแรก ถ้า tie ก็เรียงชื่อตาม
LIMIT 5; -- Top 5 ดาราสัตว์ประจำสวนสัตว์

-- READ: แนะนำสัตว์สายพันธุ์เดียวกันจาก AnimalID ที่กำลังดูอยู่
-- [LOGIC] โคตรฉลาด: เอาตัวที่กำลังดูอยู่ ไปหาสัตว์อื่นที่มี SpeciesID เดียวกัน แต่ไอดีต้องไม่ใช่ตัวมันเอง
-- แบบว่า "คุณอาจจะสนใจตัวอื่นที่เป็นสายพันธุ์เดียวกันนะ" แหม ทรงอย่างกับเว็บขายของ
SELECT DISTINCT a2.AnimalID, a2.AnimalName -- DISTINCT กัน duplicate ถ้า self-join ทำไม่ครบถ้วน
FROM Animal a1
JOIN Animal a2 ON a1.SpeciesID = a2.SpeciesID AND a1.AnimalID <> a2.AnimalID -- self-join หาสัตว์ species เดียวกัน แต่นอกจากตัวเอง ฉลาดมาก
WHERE a1.AnimalID = ? -- ระบุตัวที่กำลังดูอยู่
LIMIT 5; -- 5 คำแนะนำพอ ไม่ต้องยิงของ Amazon

-- [MIGRATION] เปลี่ยน TicketID ทื่อๆ เป็น Token สุ่ม ป้องกันพวกลองภูมิสุ่มเลขตั๋วชาวบ้าน (IDOR)
-- ย้ำอีกรอบ! ไอพวกชอบรัน 1, 2, 3 ดูข้อมูลชาวบ้าน ต้องเจอ UUID ฟาดหน้า
ALTER TABLE Ticket -- ตารางตั๋วหลัก กำลังจะเสริม security
ADD COLUMN TicketToken CHAR(36) NULL; -- เพิ่ม UUID column ไว้ก่อน ให้ NULL เพราะ row เก่ายังไม่มีค่า ถ้า NOT NULL เลย migration พังคา

UPDATE Ticket -- เติม UUID ให้ทุก row เก่าที่ยังไม่มี token
SET TicketToken = UUID() -- built-in UUID() ของ MySQL ใช้ได้เลย ไม่ต้องไปสร้างเอง
WHERE TicketToken IS NULL; -- แตะเฉพาะ row ที่ยังไม่มี token ไม่เขียนทับ row ที่มีค่าแล้ว

ALTER TABLE Ticket -- ตอนนี้ทุก row มีค่าแล้ว ปลอดภัยที่จะเปลี่ยนเป็น NOT NULL
MODIFY COLUMN TicketToken CHAR(36) NOT NULL; -- แก้เป็น NOT NULL ปิดช่องโหว์ ทำหลัง UPDATE เสมอ !

CREATE UNIQUE INDEX uq_ticket_token ON Ticket (TicketToken); -- UNIQUE INDEX บังคับ token ไม่ซ้ำกัน และ WHERE ตาม token ก็เร็วด้วย

-- =============================================
-- FUNCTION: ซื้อตั๋วเข้าชมออนไลน์
-- =============================================

-- READ: ดึงประเภทตั๋วที่เคยมีในระบบ
-- [DESIGN] ไม่มีตาราง TicketType งั้นก็ดึง Distinct มาจากที่เคยขายไปเลย
-- ซกมกไปหน่อย แต่ทำไงได้ ก็ Schema เอ็งไม่มีตาราง Master ให้ใช้นี่หว่า
SELECT DISTINCT TicketType -- dedup ประเภทตั๋ว เพราะ schema ไม่มีตาราง master TicketType แยก ซกมกแต่ทำไงได้
FROM Ticket
ORDER BY TicketType ASC; -- เรียง A-Z เพื่อ UX dropdown พื้นฐานที่มนุษย์คาดหวัง

-- READ: ตรวจสอบโปรโมชั่น/ส่วนลดที่ใช้ได้
-- ต้องยังไม่หมดอายุและรหัสตรง
-- โค้ดหมดอายุไปแล้วก็คือจบ ห้ามโวยวาย
SELECT PromotionID, PromotionCode, DiscountAmount, Conditions, PromotionExpireDate -- ดึงรายละเอียดโปโมชั่นสดๆ เอาไปให้ Frontend โชว์เอง
FROM Promotion
WHERE PromotionCode = ? AND PromotionExpireDate >= NOW(); -- ตรวจโค้ดและวันหมดอายุพร้อมกัน single query จบ โค้ดหมดอายุก็คือจบ อย่าโวยวาย

-- CREATE: สร้างรายการตั๋ว/คำสั่งซื้อ
-- [SECURITY] ยัด UUID() ใส่ TicketToken ไว้เลยตอนสร้างตั๋ว
-- ข้อมูลที่เหลือปล่อย NULL ไว้นั่นแหละ จ่ายเงินเมื่อไหร่ค่อยมาอัปเดต
INSERT INTO Ticket (VisitorID, PromotionID, TicketType, VisitDate, TicketExpireDate, PurchaseChannel, PurchaseDate, Price, TicketToken) -- ยัดทุก field เข้าเลยสักครั้ง
VALUES (?, ?, ?, ?, ?, NULL, NULL, ?, UUID()); -- PurchaseChannel กับ PurchaseDate เป็น NULL แน่นอน รอจ่ายเงินค่อยมาอัปเดต | UUID() สร้าง token อัตโนมัติ

-- READ: แสดงรายละเอียดคำสั่งซื้อที่เพิ่งสร้าง
-- [FINANCE] ไม่ทำลายราคาตั้งต้น! โชว์ Original Price ควบคู่กับ Discount แล้วคำนวณ NetPrice สดๆ ผ่าน GREATEST ป้องกันยอดติดลบ
-- ใครเอา Price = Price - Discount ไปอัปเดตทับของเดิม ขอให้โดนฝ่ายบัญชีตามกระทืบ
SELECT t.TicketID, t.TicketToken, t.VisitorID, t.PromotionID, t.TicketType, t.VisitDate, t.TicketExpireDate, -- ข้อมูลหลักตั๋วที่เพิ่งสร้าง
       t.Price AS OriginalPrice, -- เก็บราคาตั้งต้นไว้เสมอ ห้ามถูกลบทับ
       IFNULL(p.DiscountAmount, 0) AS DiscountAmount, -- ถ้าไม่มี promo discount = 0 ไม่ใช่ NULL เพราะ Frontend จะเอา NULL ไปบวกไม่ได้
       GREATEST(0, t.Price - IFNULL(p.DiscountAmount, 0)) AS NetPrice -- GREATEST(0,...) กันยอดติดลบ เผื่อ discount มั่วเกินราคา
FROM Ticket t
LEFT JOIN Promotion p ON t.PromotionID = p.PromotionID -- LEFT เพราะตั๋วอาจไม่มีโปโมชั่นก็ต้องออกมา
WHERE t.TicketID = ?; -- ดึงตั๋วที่เพิ่งสร้าง เอาไปโชว์หน้า confirmation

-- =============================================
-- FUNCTION: ชำระเงิน
-- =============================================

-- READ: ดึงข้อมูลตั๋วที่ต้องชำระ
-- เช็กว่า PurchaseDate เป็น NULL แปลว่ายังไม่จ่ายเงินชัวร์ๆ
-- ดึงมากางให้ดูว่าต้องจ่ายเท่าไหร่ อย่าเบี้ยว
SELECT t.TicketID, t.TicketToken, t.VisitorID, t.PromotionID, t.TicketType, t.VisitDate, t.TicketExpireDate, t.PurchaseChannel, t.PurchaseDate, -- ข้อมูลตั๋วครบทุกอย่าง
       t.Price AS OriginalPrice, -- ราคาดิบก่อนลด
       IFNULL(p.DiscountAmount, 0) AS DiscountAmount, -- ส่วนลด default 0
       GREATEST(0, t.Price - IFNULL(p.DiscountAmount, 0)) AS NetPrice, -- ราคาสุทธิ์ ห้ามติดลบ
       CASE
           WHEN t.PurchaseDate IS NULL THEN 'PendingPayment' -- NULL คือยังไม่จ่าย
           ELSE 'Paid' -- มีค่า คือจ่ายแล้ว
       END AS PaymentStatus -- derive สถานะจาก Nullability ล้วนๆ
FROM Ticket t
LEFT JOIN Promotion p ON t.PromotionID = p.PromotionID -- LEFT เผื่อตั๋วไม่มีโปโมชั่น

WHERE t.TicketID = ? AND t.PurchaseDate IS NULL; -- เฉพาะที่ยังค้างชำระ ถ้าจ่ายแล้ว query นี้จะออก empty เลย

-- READ: ตรวจสอบสถานะการชำระเงิน
-- Derive สถานะแบบ on-the-fly จาก Nullability ของ PurchaseDate ล้วนๆ
-- ขี้เกียจสร้างตาราง Payment แยก ก็เช็กมันจากตรงนี้แหละ ง่ายดี
SELECT TicketID, PurchaseDate, -- ไม่ต้อง JOIN จัด เช็คสถานะจ่ายเงินดูแค่ column เดียว
       CASE
           WHEN PurchaseDate IS NULL THEN 'PendingPayment' -- NULL = ยังค้างอยู่
           ELSE 'Paid' -- มีค่า = จ่ายไปแล้ว ไม่ต้องสร้างตาราง Payment แยกให้เปลือง DB
       END AS PaymentStatus -- derive สถานะจ่ายเงินแบบ lazy แต่ผลไม่ต่างกัน
FROM Ticket
WHERE TicketID = ?; -- ระบุ ticket เดียว

-- UPDATE: อัปเดตข้อมูลการชำระเงินสำเร็จ
-- [CONCURRENCY] เช็ก 'AND PurchaseDate IS NULL' ก่อน Update เสมอ ป้องกันการยิง Request ซ้ำ (Double Payment)
-- กันไอ้พวกมือบอนกดจ่ายรัวๆ สองสามรอบ
UPDATE Ticket
SET PurchaseChannel = ?, PurchaseDate = NOW() -- บันทึกช่องทางชำระและ timestamp ที่จ่ายจริง อย่าใช้เวลาจาก Frontend เดี๋ยว
WHERE TicketID = ? AND PurchaseDate IS NULL; -- idempotent! AND IS NULL ทำให้ double-click จ่ายซ้ำไม่ได้ผล

-- UPDATE: เชื่อม Promotion กับ Ticket และหักส่วนลด
-- [FINANCE] แค่ผูก PromotionID พอ! ไม่ต้องไปลบ Price ของเดิมทิ้ง เดี๋ยวบัญชีด่า
-- ล็อกด้วยว่าต้องยังไม่หมดอายุ และตั๋วยังไม่ถูกจ่ายเงิน จะได้ไม่มั่ว
UPDATE Ticket t
JOIN Promotion p ON p.PromotionCode = ? -- JOIN หา promotion จากโค้ดที่ผู้ใช้กรอก
SET t.PromotionID = p.PromotionID -- ผูก PromotionID เข้าตั๋วเลย ไม่ต้องไปลบราคาเดิมทิ้งให้ฝ่ายบัญชีด่า
WHERE t.TicketID = ? AND t.PurchaseDate IS NULL AND p.PromotionExpireDate >= NOW(); -- 3 เงื่อนไขป้องกันการโกง: ticket ถูก, ยังไม่จ่าย, โค้ดยังใช้ได้

-- =============================================
-- FUNCTION: จัดการตั๋วและประวัติการซื้อ
-- =============================================

-- READ: ดึงตั๋วทั้งหมดของ Visitor
-- สังเกตการคัดแยก Status: 1.ยังไม่จ่าย 2.หมดอายุ 3.ยังใช้ได้
-- พี่แกแยก Case กันยิบย่อยมาก แต่โคตรตอบโจทย์ UI
SELECT t.TicketID, t.TicketToken, t.TicketType, t.VisitDate, t.PurchaseDate, -- field หลักสำหรับ list ตั๋วทุกใบของ Visitor
       t.Price AS OriginalPrice, -- ราคาดิบก่อนลด เก็บไว้เสมอ
       IFNULL(p.DiscountAmount, 0) AS DiscountAmount, -- ส่วนลด default 0 ถ้าไม่มีโปโมชั่น
       GREATEST(0, t.Price - IFNULL(p.DiscountAmount, 0)) AS NetPrice, -- ราคาสุทธิ์ ห้ามติดลบ
       CASE
           WHEN t.PurchaseDate IS NULL THEN 'PendingPayment' -- ยังไม่จ่ายเงิน
           WHEN t.TicketExpireDate IS NOT NULL AND t.TicketExpireDate < NOW() THEN 'Expired' -- จ่ายแล้วแต่หมดอายุแล้ว ใช้เข้าไม่ได้แล้ว
           ELSE 'Valid' -- จ่ายแล้วและยังใช้ได้อยู่
       END AS TicketStatus -- 3-state สถานะ machine ที่ derive จากวันที่เมื่อยู่ใน DB ไม่ต้องมี column status แยก
FROM Ticket t
LEFT JOIN Promotion p ON t.PromotionID = p.PromotionID -- LEFT สำหรับตั๋วที่ไม่มีโปโมชั่นก็ต้องออกมาด้วย
WHERE t.VisitorID = ?; -- list ตั๋วทุกใบของ Visitor คนนี้ ทั้งที่จ่ายแล้วและยังค้างอยู่

-- READ: แสดงรายละเอียดตั๋วพร้อมสถานะ
-- ดึงข้อมูลเต็มมาโชว์หน้า detail ตั๋ว
-- ยัด VisitorID เข้าไปใน WHERE ด้วย กันไอพวกชอบแอบดูของคนอื่น
SELECT t.TicketID, t.TicketToken, t.TicketType, t.VisitDate, t.TicketExpireDate, -- ข้อมูลหลักตั๋ว
       t.Price AS OriginalPrice, -- ราคาตั้งต้น
       IFNULL(p.DiscountAmount, 0) AS DiscountAmount, -- ส่วนลด
       GREATEST(0, t.Price - IFNULL(p.DiscountAmount, 0)) AS NetPrice, -- ราคาสุทธิ์
       t.PurchaseChannel, t.PurchaseDate, -- ช่องทางและวันที่จ่าย
       CASE
           WHEN t.PurchaseDate IS NULL THEN 'PendingPayment' -- ยังไม่จ่าย
           WHEN t.TicketExpireDate IS NOT NULL AND t.TicketExpireDate < NOW() THEN 'Expired' -- หมดอายุแล้ว
           ELSE 'Valid' -- ยังใช้ได้อยู่
       END AS TicketStatus, -- 3-state derive จากวันที่ ไม่ต้องสร้าง column status หลอก DB
       p.PromotionCode -- โค้ดโปโมชั่นถ้ามี ถ้าไม่มีก็เป็น NULL ไม่เป็นไร
FROM Ticket t
LEFT JOIN Promotion p ON t.PromotionID = p.PromotionID -- LEFT เพราะตั๋วที่ไม่ใช้โปโมชั่นก็ต้องออกมาแสดงด้วย
WHERE t.TicketID = ? AND t.VisitorID = ?; -- ต้อง match ทั้ง ticket และ visitor กันคนอื่นแอบเข้าหน้าดูตั๋วของชาวบ้าน

-- READ: ดูประวัติการซื้อเรียงตามวันที่
-- List history ตั๋วที่จ่ายเงินแล้ว (PurchaseDate IS NOT NULL) เรียงจากใหม่ไปเก่า
-- คนรวยๆ เค้าชอบดูประวัติการเปย์กัน
SELECT t.TicketID, t.TicketToken, t.TicketType, t.PurchaseDate, -- field สำหรับหน้า purchase history
       t.Price AS OriginalPrice, -- เก็บราคาดิบ
       IFNULL(p.DiscountAmount, 0) AS DiscountAmount, -- ส่วนลดที่ได้
       GREATEST(0, t.Price - IFNULL(p.DiscountAmount, 0)) AS NetPrice -- ที่จ่ายจริง คนรวยๆ ชอบดูประวัติการเปยกัน
FROM Ticket t
LEFT JOIN Promotion p ON t.PromotionID = p.PromotionID -- LEFT เพราะบางใบไม่มีโปโมชั่นก็ต้องติดประวัติไว้ด้วย
WHERE t.VisitorID = ? AND t.PurchaseDate IS NOT NULL -- เฉพาะที่จ่ายเงินแล้วเท่านั้น pending ไม่เอามาปน
ORDER BY t.PurchaseDate DESC; -- ล่าสุดขึ้นก่อน คนชอบดูการซื้อล่าสุดเสมอ

-- =============================================
-- FUNCTION: แสดงตั๋วอิเล็กทรอนิกส์
-- =============================================

-- READ: ดึงข้อมูลตั๋วจาก TicketToken
-- [SECURITY] ตรงนี้แหละของจริง ใช้ TicketToken เป็นคีย์หลักกัน IDOR ยืนยันว่าคนนอกสุ่มเลขไม่เจอแน่
-- ถ้ามันยังเดา Token 36 ตัวอักษรถูกก็ปล่อยมันเข้าสวนสัตว์ฟรีไปเถอะ
SELECT t.TicketID, t.TicketToken AS TicketCode, t.TicketType, t.VisitDate, t.TicketExpireDate, -- TicketToken เป็น TicketCode ที่ใช้เป็น QR code
       t.Price AS OriginalPrice, -- ราคาตั้งต้น
       IFNULL(p.DiscountAmount, 0) AS DiscountAmount, -- ส่วนลด
       GREATEST(0, t.Price - IFNULL(p.DiscountAmount, 0)) AS NetPrice, -- ราคาสุทธิ์
       t.PurchaseChannel, t.PurchaseDate -- ช่องทางและวันจ่าย
FROM Ticket t
LEFT JOIN Promotion p ON t.PromotionID = p.PromotionID -- LEFT เผื่อตั๋วที่ไม่ใช้โปโมชั่นจะได้ออกมา NULL
WHERE t.TicketToken = ? AND t.PurchaseDate IS NOT NULL; -- Token-based access กัน IDOR + ต้องจ่ายแล้วเท่านั้น

-- READ: ดึงข้อมูล Visitor เจ้าของตั๋วจาก TicketToken
-- ดึงเฉพาะคนที่ซื้อตั๋วใบนี้จาก Token
-- ตรวจดูว่าใครคือเจ้าของตัวจริง จะได้เอาไปด่าถูกคน
SELECT v.VisitorFName, v.VisitorLName, v.VisitorEmail -- แค่ชื่อกับอีเมล ไม่ดึงข้อมูลส่วนตัวเกินจำเป็น privacy ขั้นพื้นฐาน
FROM Visitor v
JOIN Ticket t ON v.VisitorID = t.VisitorID -- JOIN ผ่าน ticket เพื่อยืนยันความเป็นเจ้าของ คนอื่นเอา Token อีกคนไปเอาข้อมูลคนอื่นไม่ได้
WHERE t.TicketToken = ? AND t.PurchaseDate IS NOT NULL; -- Token ยืนยันตัวตน + ต้องจ่ายแล้วเท่านั้น

-- READ: ดึงข้อมูล Promotion ที่ใช้กับตั๋วนี้จาก TicketToken
-- หาโปรโมชั่นที่ผูกกับตั๋วใบนี้
-- เผื่อมันอยากรู้ว่าตอนซื้อใช้โค้ดอะไรลดไป
SELECT p.PromotionCode, p.DiscountAmount, p.Conditions -- โค้ด, ส่วนลด, เงื่อนไขล์ ฮีโรไครจะมาโต้อกว่าใช้ไม่ได้ดูตรงนี้
FROM Ticket t
LEFT JOIN Promotion p ON p.PromotionID = t.PromotionID -- LEFT เผื่อตั๋วที่ไม่มีโปโมชั่นจะได้ออกมา NULL ดีกว่าหาย
WHERE t.TicketToken = ? AND t.PurchaseDate IS NOT NULL; -- Token ยืนยันตัวตน + จ่ายแล้ว

-- READ: แสดงรายละเอียดครบถ้วนสำหรับ E-Ticket จาก TicketToken
-- Master Query! ดึงทีเดียวครบทุกอย่างทั้งตั๋ว ลูกค้า โปรโมชั่น แถมคำนวณ NetPrice ให้เสร็จสรรพ
-- อลังการงานสร้าง ยัดข้ามไป 3 ตารางเพื่อรวมทุกอย่างมาส่งให้หน้า E-Ticket โชว์คิวอาร์โค้ดหล่อๆ
SELECT t.TicketID, t.TicketToken AS TicketCode, t.TicketType, t.VisitDate, t.TicketExpireDate, -- TicketCode เอาไปเป็น QR code หน้าตั๋ว
       t.Price AS OriginalPrice, -- ราคาตั้งต้น
       IFNULL(p.DiscountAmount, 0) AS DiscountAmount, -- ส่วนลด
       GREATEST(0, t.Price - IFNULL(p.DiscountAmount, 0)) AS NetPrice, -- ราคาสุทธิ์ ห้ามติดลบ
       t.PurchaseChannel, t.PurchaseDate, -- ช่องทางและวันที่จ่าย
       v.VisitorFName, v.VisitorLName, v.VisitorEmail, -- ข้อมูลเจ้าของตั๋วสำหรับส่งอีเมล E-ticket
       p.PromotionCode -- โค้ดโปโมชั่น NULL ถ้าไม่ใช้
FROM Ticket t
JOIN Visitor v ON t.VisitorID = v.VisitorID -- INNER JOIN เพราะตั๋วต้องมีเจ้าของเสมอ ถ้าไม่มีคนชื่อแสดงถือว่ามีปัญหา DB
LEFT JOIN Promotion p ON t.PromotionID = p.PromotionID -- LEFT เผื่อตั๋วที่ไม่มีโปโมชั่นจะได้ออกมาด้วย PromotionCode เป็น NULL
WHERE t.TicketToken = ? AND t.PurchaseDate IS NOT NULL; -- Master E-Ticket Query: Token-based กัน IDOR + จ่ายแล้วเท่านั้น เอาทุกอย่างให้ E-Ticket หล่อๆ query เดียวจบ
