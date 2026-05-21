-- Phần 1: Thiết kế CSDL
DROP DATABASE IF EXISTS hcm_cntt6_vuhuutai;
CREATE DATABASE hcm_cntt6_vuhuutai;
USE hcm_cntt6_vuhuutai;

CREATE TABLE patients(
	patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(10) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    date_of_birth DATE 
);

CREATE TABLE doctors(
	doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    specialty VARCHAR(50) NOT NULL,
    phone_number VARCHAR(10) UNIQUE,
    rating DECIMAL(2,1) DEFAULT (5.0) CHECK(rating BETWEEN 0.0 AND 5.0)
);

CREATE TABLE appointments(
	appointment_id VARCHAR(4) PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
	appointment_time DATETIME DEFAULT (CURRENT_TIMESTAMP),
    fee INT,
    status VARCHAR(50) ,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE medical_records(
	record_id VARCHAR(4) PRIMARY KEY,
    appointment_id VARCHAR(4),
    symptoms VARCHAR(100) NOT NULL,
    diagnosis VARCHAR(150) NOT NULL,
    prescription TEXT,
    record_date DATETIME DEFAULT (CURRENT_TIMESTAMP),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

CREATE TABLE visit_log(
	log_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id VARCHAR(4),
    doctor_id INT,
    log_time DATETIME DEFAULT(CURRENT_TIMESTAMP),
    note TEXT,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Phần 2 DML: Insert, Update, Delete
-- Câu 1 - Insert

INSERT INTO patients (full_name, phone_number, gender, date_of_birth)VALUES
('Nguyen Thi Lan', '0901234567','Female', '1999-03-12'),
('Tran Van Minh', '0902345678','Male', '1996-11-25'),
('Le Hoai Phuong', '0913456789','Female', '2001-07-08'),
('pham Duc Anh', '0984567890','Male', '1998-01-19'),
('Hoang Ngoc Mai', '0975678901','Female', '1999-09-30');

INSERT INTO doctors (full_name, specialty, phone_number,rating) VALUES
('BS. Nguyen Van Hai', 'Noi', '0931112223', 4.8),
('BS. Tran Thu Ha', 'Nhi', '0932223334', 5),
('BS. Le Quoc Tuan', 'Ngoai', '0933334445', 4.6),
('BS. Pham Minh Chau', 'Da lieu', '0934445556', 4.9),
('BS. Hoang Gia Bao', 'Mach', '0935556667', 4.7);

INSERT INTO appointments VALUES
('7001', 1, 1, '2024-05-20 8:00', 200000, 'Booked'),
('7002', 2, 2, '2024-05-20 9:30', 250000, 'Completed'),
('7003', 3, 3, '2024-05-20 10:15', 300000, 'Booked'),
('7004', 4, 5, '2024-05-21 7:00', 350000, 'Completed'),
('7005', 5, 4, '2024-05-21 8:45', 220000, 'Cancelled');

INSERT INTO medical_records VALUES
('8001', '7002', 'Sốt cao, ho', 'Viêm họng', 'Paracetamol + Siro ho', '2024-05-20 10:00'),
('8002', '7004', 'Đau ngực nhẹ', 'Theo dõi tim mạch', 'Vitamin + tái khám', '2024-05-21 8:00'),
('8003', '7001', 'Đau bụng', 'Rối loạn tiêu hóa', 'Men tiêu hóa', '2024-05-20 9:00'),
('8004', '7003', 'Đau vai gáy', 'Căng cơ', 'Giảm đau + nghỉ ngơi', '2024-05-20 11:00'),
('8005', '7005', 'Ngứa da', 'Dị ứng', 'Thuốc bôi ngoài da', '2024-05-21 9:00');

INSERT INTO visit_log(record_id, doctor_id, log_time, note) VALUES
('8003', 1, '2024-05-20 9:05', 'Đã khám lần đầu'),
('8001', 2, '2024-05-20 10:05', 'Hoàn tất khám'),
('8004', 3, '2024-05-20 11:10', 'Tư vấn vật lý trị liệu'),
('8002', 4, '2024-05-21 8:10', 'Hướng dẫn tái khám'),
('8005', 5, '2024-05-21 9:05', 'Bệnh nhân hủy hẹn');

-- Câu 2: update & Delete

SET SQL_SAFE_UPDATES = 0;

UPDATE appointments AS ap
INNER JOIN patients AS pa
ON ap.patient_id = pa.patient_id
SET fee = fee * 1.1
WHERE ap.status = 'Completed' AND YEAR(pa.date_of_birth) < 2000;

DELETE 
FROM visit_log
WHERE log_time < '2024-05-20';

-- Phần 4: truy vấn cơ bản
-- Câu 1:
	SELECT
		full_name,
        specialty,
        rating
	FROM doctors
    WHERE rating > 4.7 OR specialty = 'Nhi';
    
-- Câu 2:
	SELECT
		full_name,
        phone_number
	FROM patients
    WHERE date_of_birth BETWEEN '1998-01-01' AND '2001-12-31'
    AND phone_number LIKE '090%';

-- Câu 3:
	SELECT
		appointment_id,
        appointment_time,
        fee
	FROM appointments
    ORDER BY fee DESC
    LIMIT 2 OFFSET 2;
    
-- Phần 4: Truy vấn nâng cao
-- Câu 1:
	SELECT 
		p.full_name,
        d.full_name,
        d.specialty,
        ap.fee,
        ap.appointment_time
	FROM appointments AS ap
    INNER JOIN patients AS p
    ON ap.patient_id = p.patient_id
    INNER JOIN doctors AS d
    ON ap.doctor_id = d.doctor_id;
    
-- Câu 2:
	SELECT
		d.full_name,
        COUNT(ap.doctor_id) AS id,
        SUM(ap.fee) AS total_fee
	FROM appointments AS ap
    INNER JOIN doctors AS d
    ON ap.doctor_id = d.doctor_id
    WHERE ap.status = 'Completed'
    GROUP BY d.full_name
    HAVING SUM(ap.fee) > 500000;
    
-- Câu 3:
	SELECT 
		doctor_id,
        full_name,
        rating
	FROM doctors
    WHERE rating = (
		SELECT MAX(rating)
        FROM doctors
	);
    
-- Phần 5: index&view
-- Câu 1:
	CREATE INDEX idx_appointment_detail
    ON appointments(status, fee);

-- Câu 2:

	CREATE VIEW view_total_doctor_apointment AS
	SELECT 
		d.full_name,
        COUNT(ap.doctor_id) AS total_examination_form,
        SUM(ap.fee) AS total_fee
	FROM appointments AS ap
    INNER JOIN doctors AS d
    ON ap.doctor_id = d.doctor_id 
    WHERE ap.status <> 'Cancelled'
    GROUP BY d.full_name;
    
    SELECT * FROM view_total_doctor_apointment;
    
-- Phần 6: trigger
-- Câu 1:
	DELIMITER \\
    CREATE TRIGGER trg_after_update_status
    AFTER UPDATE appointments
    FOR EACH ROW
    BEGIN
    
    END;
    DELIMITER ;

