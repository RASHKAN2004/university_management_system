USE FacultyManagement;

DELIMITER //

-- Calculate and Update Final Result
CREATE PROCEDURE CalculateStudentResult(IN p_reg_no VARCHAR(10), IN p_course_code VARCHAR(15))
BEGIN
    DECLARE total_marks DECIMAL(5,2);
    DECLARE final_grade VARCHAR(5);
    DECLARE final_gpa DECIMAL(3,2);

    -- Calculate average of all marks for that student & course
    SELECT AVG(marks) INTO total_marks 
    FROM marks 
    WHERE reg_no = p_reg_no AND course_code = p_course_code;

    -- Grade Logic
    IF total_marks >= 85 THEN 
        SET final_grade = 'A+'; SET final_gpa = 4.00;
    ELSEIF total_marks >= 75 THEN 
        SET final_grade = 'A';  SET final_gpa = 3.70;
    ELSEIF total_marks >= 65 THEN 
        SET final_grade = 'B';  SET final_gpa = 3.00;
    ELSEIF total_marks >= 55 THEN 
        SET final_grade = 'C';  SET final_gpa = 2.00;
    ELSEIF total_marks >= 40 THEN 
        SET final_grade = 'S';  SET final_gpa = 1.00;
    ELSE 
        SET final_grade = 'E';  SET final_gpa = 0.00;
    END IF;

    -- Insert or Update Result
    INSERT INTO results (reg_no, course_code, final_marks, grade, gpa)
    VALUES (p_reg_no, p_course_code, total_marks, final_grade, final_gpa)
    ON DUPLICATE KEY UPDATE 
        final_marks = total_marks,
        grade = final_grade,
        gpa = final_gpa;
END //

DELIMITER ;