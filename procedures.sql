USE FacultyManagement;

DELIMITER //

-- =============================================
-- 1. Record Attendance
-- =============================================
CREATE PROCEDURE sp_record_attendance(
    IN p_registration_no VARCHAR(20),
    IN p_course_code VARCHAR(10),
    IN p_session_date DATE,
    IN p_status ENUM('present', 'absent', 'medical'),
    IN p_session_type ENUM('theory', 'practical')
)
BEGIN
    INSERT INTO attendance (registration_no, course_code, session_date, status, session_type)
    VALUES (p_registration_no, p_course_code, p_session_date, p_status, p_session_type);
    
    SELECT 'Attendance recorded successfully' AS message;
END //

-- =============================================
-- 2. Calculate Attendance Percentage + Eligibility
-- =============================================
CREATE PROCEDURE sp_calculate_attendance(
    IN p_registration_no VARCHAR(20),
    IN p_course_code VARCHAR(10)
)
BEGIN
    SELECT 
        registration_no,
        course_code,
        COUNT(*) AS total_sessions,
        SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) AS present,
        SUM(CASE WHEN status = 'medical' THEN 1 ELSE 0 END) AS medical,
        ROUND(
            (SUM(CASE WHEN status IN ('present', 'medical') THEN 1 ELSE 0 END) * 100.0) 
            / COUNT(*), 2
        ) AS attendance_percentage,
        CASE 
            WHEN ROUND((SUM(CASE WHEN status IN ('present', 'medical') THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) >= 80 
            THEN 'Eligible' 
            ELSE 'Not Eligible' 
        END AS eligibility
    FROM attendance
    WHERE registration_no = p_registration_no 
      AND course_code = p_course_code
    GROUP BY registration_no, course_code;
END //

-- =============================================
-- 3. Batch Attendance Summary
-- =============================================
CREATE PROCEDURE sp_batch_attendance_summary(IN p_course_code VARCHAR(10))
BEGIN
    SELECT 
        s.registration_no,
        s.name,
        ROUND(
            (SUM(CASE WHEN a.status IN ('present', 'medical') THEN 1 ELSE 0 END) * 100.0) 
            / COUNT(a.id), 2
        ) AS attendance_percentage,
        CASE 
            WHEN ROUND((SUM(CASE WHEN a.status IN ('present', 'medical') THEN 1 ELSE 0 END) * 100.0) / COUNT(a.id), 2) >= 80 
            THEN 'Eligible' 
            ELSE 'Not Eligible' 
        END AS eligibility
    FROM students s
    JOIN attendance a ON s.registration_no = a.registration_no
    WHERE a.course_code = p_course_code
    GROUP BY s.registration_no, s.name
    ORDER BY attendance_percentage DESC;
END //

-- =============================================
-- 4. Record Marks
-- =============================================
CREATE PROCEDURE sp_record_marks(
    IN p_registration_no VARCHAR(20),
    IN p_course_code VARCHAR(10),
    IN p_assessment_type VARCHAR(30),   -- Quiz, MidTheory, MidPractical, etc.
    IN p_marks DECIMAL(5,2)
)
BEGIN
    INSERT INTO marks (registration_no, course_code, assessment_type, marks)
    VALUES (p_registration_no, p_course_code, p_assessment_type, p_marks)
    ON DUPLICATE KEY UPDATE marks = p_marks;
    
    SELECT 'Marks recorded/updated successfully' AS message;
END //

-- =============================================
-- 5. Calculate CA Marks & Eligibility
-- =============================================
CREATE PROCEDURE sp_calculate_ca(IN p_registration_no VARCHAR(20), IN p_course_code VARCHAR(10))
BEGIN
    -- Assuming 30% CA (adjust according to course)
    SELECT 
        ROUND(SUM(marks * weight/100), 2) AS ca_marks,
        CASE 
            WHEN ROUND(SUM(marks * weight/100), 2) >= 40 THEN 'Eligible' 
            ELSE 'Not Eligible' 
        END AS ca_eligibility
    FROM marks 
    WHERE registration_no = p_registration_no AND course_code = p_course_code;
END //

-- =============================================
-- 6. Final Result with Grade (UGC Circular 12/2024 style)
-- =============================================
CREATE PROCEDURE sp_assign_final_grade(
    IN p_registration_no VARCHAR(20),
    IN p_course_code VARCHAR(10),
    IN p_final_marks DECIMAL(5,2),
    IN p_medical ENUM('yes','no')
)
BEGIN
    DECLARE final_grade VARCHAR(5);
    DECLARE gpa_point DECIMAL(3,2);

    IF p_medical = 'yes' THEN
        SET final_grade = 'MC';
        SET gpa_point = 0.0;
    ELSE
        CASE 
            WHEN p_final_marks >= 85 THEN SET final_grade = 'A+', gpa_point = 4.00;
            WHEN p_final_marks >= 80 THEN SET final_grade = 'A',  gpa_point = 4.00;
            WHEN p_final_marks >= 75 THEN SET final_grade = 'A-', gpa_point = 3.75;
            WHEN p_final_marks >= 70 THEN SET final_grade = 'B+', gpa_point = 3.50;
            WHEN p_final_marks >= 65 THEN SET final_grade = 'B',  gpa_point = 3.25;
            WHEN p_final_marks >= 60 THEN SET final_grade = 'B-', gpa_point = 3.00;
            WHEN p_final_marks >= 55 THEN SET final_grade = 'C+', gpa_point = 2.75;
            WHEN p_final_marks >= 50 THEN SET final_grade = 'C',  gpa_point = 2.50;
            WHEN p_final_marks >= 45 THEN SET final_grade = 'C-', gpa_point = 2.25;
            WHEN p_final_marks >= 40 THEN SET final_grade = 'D',  gpa_point = 2.00;
            ELSE SET final_grade = 'E', gpa_point = 0.00;
        END CASE;
    END IF;

    INSERT INTO final_results (registration_no, course_code, marks, grade, gpa_point, medical_status)
    VALUES (p_registration_no, p_course_code, p_final_marks, final_grade, gpa_point, p_medical)
    ON DUPLICATE KEY UPDATE 
        marks = p_final_marks, 
        grade = final_grade, 
        gpa_point = gpa_point,
        medical_status = p_medical;

    SELECT 'Final result processed successfully' AS message;
END //

-- =============================================
-- 7. Calculate SGPA for a Student
-- =============================================
CREATE PROCEDURE sp_calculate_sgpa(IN p_registration_no VARCHAR(20))
BEGIN
    SELECT 
        ROUND(SUM(fr.gpa_point * c.credits) / SUM(c.credits), 2) AS SGPA
    FROM final_results fr
    JOIN course_units c ON fr.course_code = c.course_code
    WHERE fr.registration_no = p_registration_no
    GROUP BY fr.registration_no;
END //

-- =============================================
-- 8. View Full Student Report
-- =============================================
CREATE PROCEDURE sp_student_full_report(IN p_registration_no VARCHAR(20))
BEGIN
    SELECT 
        c.course_code,
        c.course_name,
        m.ca_marks,
        fr.marks AS final_marks,
        fr.grade,
        fr.gpa_point,
        c.credits
    FROM course_units c
    LEFT JOIN (
        SELECT course_code, ROUND(SUM(marks * weight/100),2) AS ca_marks 
        FROM marks 
        WHERE registration_no = p_registration_no 
        GROUP BY course_code
    ) m ON c.course_code = m.course_code
    LEFT JOIN final_results fr ON c.course_code = fr.course_code 
                              AND fr.registration_no = p_registration_no
    WHERE c.is_active = 1
    ORDER BY c.course_code;
END //

DELIMITER ;

-- Show all procedures
SHOW PROCEDURE STATUS WHERE Db = 'FacultyManagement';