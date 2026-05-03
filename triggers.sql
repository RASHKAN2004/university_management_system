USE FacultyManagement;


DELIMITER //

-- =============================================
-- 1. Trigger for Student Status
-- =============================================
DROP TRIGGER IF EXISTS trg_before_final_result_insert //
CREATE TRIGGER trg_before_final_result_insert 
BEFORE INSERT ON final_results 
FOR EACH ROW 
BEGIN 
    DECLARE stud_status VARCHAR(20); 
    SELECT status INTO stud_status FROM students WHERE registration_no = NEW.registration_no; 
    
    IF stud_status = 'suspended' THEN 
        SET NEW.grade = 'WH'; 
        SET NEW.marks = 0; 
        SET NEW.gpa_point = 0.0; 
    END IF; 
END //

-- =============================================
-- 2. Trigger for Repeat Student Max Grade 'C'
-- =============================================
DROP TRIGGER IF EXISTS trg_before_final_result_update //
CREATE TRIGGER trg_before_final_result_update 
BEFORE UPDATE ON final_results 
FOR EACH ROW 
BEGIN 
    DECLARE stud_status VARCHAR(20); 
    SELECT status INTO stud_status FROM students WHERE registration_no = NEW.registration_no; 
    
    IF stud_status = 'repeat' AND NEW.grade IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+') THEN 
        SET NEW.grade = 'C'; 
        SET NEW.gpa_point = 2.25; 
    END IF; 
END //

-- =============================================
-- 3. Trigger to Auto Calculate Attendance Percentage
-- =============================================
DROP TRIGGER IF EXISTS trg_after_attendance_insert //
CREATE TRIGGER trg_after_attendance_insert 
AFTER INSERT ON attendance 
FOR EACH ROW 
BEGIN 
    UPDATE attendance_summary 
    SET total_sessions = total_sessions + 1, 
        present_sessions = present_sessions + IF(NEW.status = 'present', 1, 0), 
        medical_sessions = medical_sessions + IF(NEW.status = 'medical', 1, 0) 
    WHERE registration_no = NEW.registration_no AND course_code = NEW.course_code; 
END //

-- =============================================
-- 4. Trigger to Prevent Invalid Marks (>100 or <0)
-- =============================================
DROP TRIGGER IF EXISTS trg_before_marks_insert //
CREATE TRIGGER trg_before_marks_insert 
BEFORE INSERT ON marks 
FOR EACH ROW 
BEGIN 
    IF NEW.marks > 100 OR NEW.marks < 0 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marks must be between 0 and 100'; 
    END IF; 
END //

-- =============================================
-- 5. Trigger for Medical Cases in Exams
-- =============================================
DROP TRIGGER IF EXISTS trg_medical_result //
CREATE TRIGGER trg_medical_result 
BEFORE INSERT ON final_results 
FOR EACH ROW 
BEGIN 
    IF NEW.medical_status = 'yes' THEN 
        SET NEW.grade = 'MC'; 
        SET NEW.marks = 0; 
        SET NEW.gpa_point = 0.0; 
    END IF; 
END //

DELIMITER ;

SHOW TRIGGERS;
