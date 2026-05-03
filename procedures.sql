USE FacultyManagement;

DELIMITER //

CREATE PROCEDURE CalculateStudentResult(
    IN p_reg_no VARCHAR(20),
    IN p_course_code VARCHAR(15)
)
BEGIN
    DECLARE v_total_marks DECIMAL(5,2) DEFAULT 0.00;
    DECLARE v_final_grade VARCHAR(5);
    DECLARE v_gpa DECIMAL(3,2);
    DECLARE v_student_status ENUM('proper', 'repeat', 'suspended');
    DECLARE v_has_medical BOOLEAN DEFAULT FALSE;
    DECLARE v_ca_eligible BOOLEAN DEFAULT FALSE;
    DECLARE v_attendance_eligible BOOLEAN DEFAULT FALSE;

    --  Student Status
    SELECT `status` INTO v_student_status 
    FROM students 
    WHERE reg_no = p_reg_no;

    -- 2. Medical Check
    SELECT EXISTS(
        SELECT 1 FROM medicals 
        WHERE reg_no = p_reg_no AND course_code = p_course_code
    ) INTO v_has_medical;

    IF v_has_medical THEN
        SET v_final_grade = 'MC';
        SET v_gpa = NULL;
        SET v_total_marks = NULL;

    ELSEIF v_student_status = 'suspended' THEN
        SET v_final_grade = 'WH';
        SET v_gpa = NULL;
        SET v_total_marks = NULL;

    ELSE
        -- Weighted Total Marks Calculation
        SELECT COALESCE(SUM(m.marks * ac.weight / 100), 0) INTO v_total_marks
        FROM marks m
        JOIN assessment_components ac ON m.component_id = ac.component_id
        WHERE m.reg_no = p_reg_no 
          AND m.course_code = p_course_code;

        -- CA + Attendance Eligibility
        SELECT 
            ca_eligible = 1 AND attendance_percentage >= 80 
        INTO v_ca_eligible 
        FROM vw_student_ca_attendance 
        WHERE reg_no = p_reg_no AND course_code = p_course_code;

        IF v_ca_eligible = 0 THEN
            SET v_final_grade = 'E';   -- Not eligible for final
            SET v_gpa = 0.00;
        ELSE
            -- UGC Commission Circular No. 12/2024 Grading
            IF v_total_marks >= 85 THEN 
                SET v_final_grade = 'A+'; SET v_gpa = 4.00;
            ELSEIF v_total_marks >= 75 THEN 
                SET v_final_grade = 'A';  SET v_gpa = 4.00;
            ELSEIF v_total_marks >= 70 THEN 
                SET v_final_grade = 'A-'; SET v_gpa = 3.70;
            ELSEIF v_total_marks >= 65 THEN 
                SET v_final_grade = 'B+'; SET v_gpa = 3.30;
            ELSEIF v_total_marks >= 60 THEN 
                SET v_final_grade = 'B';  SET v_gpa = 3.00;
            ELSEIF v_total_marks >= 55 THEN 
                SET v_final_grade = 'B-'; SET v_gpa = 2.70;
            ELSEIF v_total_marks >= 50 THEN 
                SET v_final_grade = 'C+'; SET v_gpa = 2.30;
            ELSEIF v_total_marks >= 45 THEN 
                SET v_final_grade = 'C';  SET v_gpa = 2.00;
            ELSEIF v_total_marks >= 40 THEN 
                SET v_final_grade = 'C-'; SET v_gpa = 1.70;
            ELSE 
                SET v_final_grade = 'E';  SET v_gpa = 0.00;
            END IF;

            -- Repeat student only-
            IF v_student_status = 'repeat' AND v_gpa > 2.00 THEN
                SET v_final_grade = 'C';
                SET v_gpa = 2.00;
            END IF;
        END IF;
    END IF;

    -- Final Insert / Update
    INSERT INTO results (reg_no, course_code, final_marks, grade, gpa, student_status, calculated_at)
    VALUES (p_reg_no, p_course_code, v_total_marks, v_final_grade, v_gpa, v_student_status, NOW())
    ON DUPLICATE KEY UPDATE 
        final_marks = v_total_marks,
        grade = v_final_grade,
        gpa = v_gpa,
        student_status = v_student_status,
        calculated_at = NOW();

END //

DELIMITER ;