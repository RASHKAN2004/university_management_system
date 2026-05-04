USE FacultyManagement;

-- =============================================
-- 1. Trigger: Student Status (INSERT)
-- =============================================
DELIMITER //

CREATE TRIGGER student_status_before_insert
BEFORE INSERT ON results
FOR EACH ROW
BEGIN
    DECLARE s_status VARCHAR(20);

    SELECT status INTO s_status
    FROM students
    WHERE reg_no = NEW.reg_no;

    IF s_status = 'suspended' THEN
        SET NEW.grade = 'WH';
        SET NEW.gpa = 0.0;

    ELSEIF s_status = 'repeat' THEN
        SET NEW.grade = 'C';
        SET NEW.gpa = 2.0;
    END IF;

END//

DELIMITER ;

-- =============================================
-- 2. Trigger: Student Status (UPDATE)
-- =============================================
DELIMITER //

CREATE TRIGGER student_status_before_update
BEFORE UPDATE ON results
FOR EACH ROW
BEGIN
    DECLARE s_status VARCHAR(20);

    SELECT status INTO s_status
    FROM students
    WHERE reg_no = NEW.reg_no;

    IF s_status = 'suspended' THEN
        SET NEW.grade = 'WH';
        SET NEW.gpa = 0.0;

    ELSEIF s_status = 'repeat' THEN
        SET NEW.grade = 'C';
        SET NEW.gpa = 2.0;
    END IF;

END//

DELIMITER ;

-- =============================================
-- 3. Trigger: Repeat Student Max Grade = C
-- =============================================
DELIMITER //

CREATE TRIGGER repeat_student_max_grade
BEFORE INSERT ON results
FOR EACH ROW
BEGIN
    DECLARE s_status VARCHAR(20);

    SELECT status INTO s_status
    FROM students
    WHERE reg_no = NEW.reg_no;

    IF s_status = 'repeat' THEN
        IF NEW.grade IN ('A','B') THEN
            SET NEW.grade = 'C';
            SET NEW.gpa = 2.0;
        END IF;
    END IF;

END//

DELIMITER ;

-- =============================================
-- 4. Trigger: Prevent Invalid Marks
-- =============================================
DELIMITER //

CREATE TRIGGER prevent_invalid_marks_update
BEFORE UPDATE ON marks
FOR EACH ROW
BEGIN
    IF NEW.marks < 0 OR NEW.marks > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid marks! Must be between 0 and 100';
    END IF;
END//

DELIMITER ;

-- =============================================
-- 5. Trigger: Medical Case Handling
-- =============================================
DELIMITER //

CREATE TRIGGER medical_case_before_update
BEFORE UPDATE ON results
FOR EACH ROW
BEGIN
    DECLARE exam_count INT;

    SELECT COUNT(*) INTO exam_count
    FROM marks
    WHERE reg_no = NEW.reg_no
      AND course_code = NEW.course_code
      AND type IN ('FINAL_THEORY','FINAL_PRACTICAL');

    IF exam_count = 0 THEN
        SET NEW.grade = 'MC';
        SET NEW.gpa = 0.0;
    END IF;

END//

DELIMITER ;

-- =============================================
-- Show all triggers
-- =============================================
SHOW TRIGGERS;