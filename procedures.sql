-- procedures.sql
USE FacultyManagement;

-- Check Student Eligibility
DELIMITER //
CREATE PROCEDURE CheckEligibility(IN p_student_id INT, IN p_course_id INT)
BEGIN
    INSERT INTO Eligibility (student_id, course_id, attendance_percentage, ca_marks, status)
    SELECT 
        a.student_id, 
        a.course_id,
        ROUND(AVG(a.attendance_percentage), 2),
        ROUND(AVG(m.total_marks * 0.4), 2),
        CASE 
            WHEN AVG(a.attendance_percentage) >= 80 AND AVG(m.total_marks) >= 40 
            THEN 'Eligible' 
            ELSE 'Not Eligible' 
        END
    FROM Attendance a
    JOIN Marks m ON a.student_id = m.student_id AND a.course_id = m.course_id
    WHERE a.student_id = p_student_id AND a.course_id = p_course_id
    GROUP BY a.student_id, a.course_id;
END //
DELIMITER ;

-- Calculate GPA
DELIMITER //
CREATE FUNCTION CalculateGPA(p_student_id INT) 
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE total_points DECIMAL(6,2);
    DECLARE total_credits INT;

    SELECT 
        SUM(g.grade_point * cu.credit),
        SUM(cu.credit)
    INTO total_points, total_credits
    FROM Grade g
    JOIN Course_Unit cu ON g.course_id = cu.course_id
    WHERE g.student_id = p_student_id;

    IF total_credits = 0 THEN
        RETURN 0.00;
    END IF;

    RETURN ROUND(total_points / total_credits, 2);
END //
DELIMITER ;