--	As a summary for whole batch By giving course code 

DELIMITER //

CREATE PROCEDURE GetBatchCAWeightedTotal(IN input_course_code VARCHAR(15))
BEGIN
    -- Weights: Assignment=10%, Mid=20%, Practical=20% (Total CA = 50%)
    -- Using 100.0 to ensure decimal division for accuracy
    
    SELECT 
        m.reg_no AS 'Registration No',
        s.name AS 'Student Name',
        
        -- Calculated Total Weighted CA Mark (The final score out of 50)
        ROUND(
            ((m.assignment / 100.0) * 10) + 
            ((m.mid_exam / 100.0) * 20) + 
            ((m.practical / 100.0) * 20), 2
        ) AS 'Weighted Total CA',
        
        -- Eligibility based on UGC Circular 12-2024 standards 
        -- (40% of the 50-mark CA component = 20 marks)
        CASE 
            WHEN (((m.assignment / 100.0) * 10) + 
                  ((m.mid_exam / 100.0) * 20) + 
                  ((m.practical / 100.0) * 20)) >= 20 THEN 'Eligible'
            ELSE 'Ineligible'
        END AS 'UGC Eligibility'
        
    FROM marks m
    JOIN students s ON m.reg_no = s.reg_no
    WHERE m.course_code = input_course_code
    ORDER BY m.reg_no ASC;
END //

DELIMITER ;


-- There should be a way to view CA marks details  By giving course code and registration no


DELIMITER //

CREATE PROCEDURE GetIndividualCAWeightedSummary(
    IN input_reg_no VARCHAR(10), 
    IN input_course_code VARCHAR(15)
)
BEGIN
    SELECT 
        s.reg_no AS 'Registration No',
        s.name AS 'Student Name',
        c.name AS 'Course Name',
        
        -- Final Weighted CA Score Calculation
        -- (Assignment/100 * 10) + (Mid/100 * 20) + (Practical/100 * 20)
        ROUND(
            ((m.assignment / 100.0) * 10) + 
            ((m.mid_exam / 100.0) * 20) + 
            ((m.practical / 100.0) * 20), 2
        ) AS 'Final CA Score (Out of 50)',
        
        -- UGC Circular 12-2024 Eligibility Check
        -- 40% threshold of the 50-mark CA component is 20 marks
        CASE 
            WHEN (((m.assignment / 100.0) * 10) + 
                  ((m.mid_exam / 100.0) * 20) + 
                  ((m.practical / 100.0) * 20)) >= 20 THEN 'Eligible'
            ELSE 'Ineligible'
        END AS 'UGC Eligibility Status'
        
    FROM marks m
    JOIN students s ON m.reg_no = s.reg_no
    JOIN courses c ON m.course_code = c.course_code
    WHERE m.reg_no = input_reg_no 
    AND m.course_code = input_course_code;
END //

DELIMITER ;


--should be a way to see the final marks for whole batch as view


CREATE OR REPLACE VIEW View_Batch_Final_Marks AS
SELECT 
    m.course_code AS 'Course Code',
    m.reg_no AS 'Registration No',
    s.name AS 'Student Name',
    
    -- Weighted CA (Out of 50)
    ROUND(
        ((m.assignment / 100.0) * 10) + 
        ((m.mid_exam / 100.0) * 20) + 
        ((m.practical / 100.0) * 20), 2
    ) AS 'Total_CA',
    
    -- Final Exam (Weighted to 50%)
    ROUND((m.final_exam / 100.0) * 50, 2) AS 'Final_Exam',
    
    -- Grand Total (CA + Final Exam)
    ROUND(
        (((m.assignment / 100.0) * 10) + ((m.mid_exam / 100.0) * 20) + ((m.practical / 100.0) * 20)) + 
        ((m.final_exam / 100.0) * 50), 2
    ) AS 'Grand_Total'
    
FROM marks m
JOIN students s ON m.reg_no = s.reg_no;



--see the final marks for individuals with reg no

DELIMITER //

CREATE PROCEDURE GetStudentFinalMarksByRegNo(IN input_reg_no VARCHAR(10))
BEGIN
    SELECT 
        s.reg_no AS 'Registration No',
        s.name AS 'Student Name',
        c.course_code AS 'Course Code',
        c.name AS 'Course Name',
        
        -- Calculated Weighted CA (10% Assignment + 20% Mid + 20% Practical)
        ROUND(
            ((m.assignment / 100.0) * 10) + 
            ((m.mid_exam / 100.0) * 20) + 
            ((m.practical / 100.0) * 20), 2
        ) AS 'Total CA (50%)',
        
        -- Weighted Final Exam (50%)
        ROUND((m.final_exam / 100.0) * 50, 2) AS 'Final Exam (50%)',
        
        -- Grand Total (CA + Final)
        ROUND(
            (((m.assignment / 100.0) * 10) + ((m.mid_exam / 100.0) * 20) + ((m.practical / 100.0) * 20)) + 
            ((m.final_exam / 100.0) * 50), 2
        ) AS 'Grand Total'
        
    FROM marks m
    JOIN students s ON m.reg_no = s.reg_no
    JOIN courses c ON m.course_code = c.course_code
    WHERE s.reg_no = input_reg_no;
END //

DELIMITER ;


--There should be a way to see if student/s are eligible according to the criteria of CA to sit for the final exam


DELIMITER //

CREATE PROCEDURE GetBatchExamEligibility(IN input_course_code VARCHAR(15))
BEGIN
    SELECT 
        s.reg_no AS 'Reg No',
        s.name AS 'Name',
        
        -- 1. Attendance Calculation (>= 80%)
        ROUND((COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
            (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = input_course_code)) * 100, 2) AS 'Atten %',
            
        -- 2. CA Marks Calculation (Weighted Total out of 50)
        ROUND(((m.assignment/100.0)*10) + ((m.mid_exam/100.0)*20) + ((m.practical/100.0)*20), 2) AS 'CA Marks',
        
        -- 3. Final Eligibility Logic
        CASE 
            WHEN 
                -- Attendance Check
                (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
                (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = input_course_code)) * 100 >= 80
                AND 
                -- CA Marks Check (40% of 50 = 20 marks)
                (((m.assignment/100.0)*10) + ((m.mid_exam/100.0)*20) + ((m.practical/100.0)*20)) >= 20
            THEN 'ELIGIBLE'
            ELSE 'NOT ELIGIBLE'
        END AS 'Exam Status'
        
    FROM students s
    JOIN attendance a ON s.reg_no = a.reg_no
    JOIN marks m ON s.reg_no = m.reg_no AND a.course_code = m.course_code
    WHERE a.course_code = input_course_code
    GROUP BY s.reg_no;
END //

DELIMITER ;


--grading view
DELIMITER //

CREATE PROCEDURE CalculateGrade(
    IN p_assignment INT,
    IN p_mid_exam INT,
    IN p_practical INT,
    IN p_final_exam INT,
    IN p_medical_ca BOOLEAN,
    IN p_medical_mid BOOLEAN,
    IN p_medical_final BOOLEAN,
    OUT p_final_marks DECIMAL(5,2),
    OUT p_grade VARCHAR(5),
    OUT p_gpa DECIMAL(3,2)
)
BEGIN
    DECLARE ca_marks DECIMAL(5,2);
    DECLARE final_marks DECIMAL(5,2);
    DECLARE total DECIMAL(5,2);

    IF p_medical_ca OR p_medical_mid OR p_medical_final THEN
        SET p_final_marks = NULL;
        SET p_grade = 'MC';
        SET p_gpa = 0.00;

    ELSE
        SET ca_marks = 
            ((COALESCE(p_assignment,0)/100)*10) +
            ((COALESCE(p_mid_exam,0)/100)*20) +
            ((COALESCE(p_practical,0)/100)*20);

        SET final_marks = (COALESCE(p_final_exam,0)/100)*50;

        SET total = ca_marks + final_marks;

        SET p_final_marks = total;

        CASE
            WHEN total >= 85 THEN SET p_grade = 'A+'; SET p_gpa = 4.00;
            WHEN total >= 75 THEN SET p_grade = 'A';  SET p_gpa = 4.00;
            WHEN total >= 70 THEN SET p_grade = 'A-'; SET p_gpa = 3.70;
            WHEN total >= 65 THEN SET p_grade = 'B+'; SET p_gpa = 3.30;
            WHEN total >= 60 THEN SET p_grade = 'B';  SET p_gpa = 3.00;
            WHEN total >= 55 THEN SET p_grade = 'B-'; SET p_gpa = 2.70;
            WHEN total >= 50 THEN SET p_grade = 'C+'; SET p_gpa = 2.30;
            WHEN total >= 45 THEN SET p_grade = 'C';  SET p_gpa = 2.00;
            WHEN total >= 40 THEN SET p_grade = 'C-'; SET p_gpa = 1.70;
            WHEN total >= 35 THEN SET p_grade = 'D';  SET p_gpa = 1.30;
            ELSE SET p_grade = 'E'; SET p_gpa = 0.00;
        END CASE;

    END IF;
END //

DELIMITER ;
--------------------------------------------------------------------------------------------------------------------------------------------------------
--Process Student Results for a Course
DELIMITER //

CREATE PROCEDURE ProcessStudentResult(
    IN p_reg_no VARCHAR(10),
    IN p_course_code VARCHAR(15)
)
BEGIN
    DECLARE v_assignment INT DEFAULT 0;
    DECLARE v_mid INT DEFAULT 0;
    DECLARE v_practical INT DEFAULT 0;
    DECLARE v_final INT DEFAULT 0;

    DECLARE v_medical_ca BOOLEAN DEFAULT FALSE;
    DECLARE v_medical_mid BOOLEAN DEFAULT FALSE;
    DECLARE v_medical_final BOOLEAN DEFAULT FALSE;

    DECLARE v_final_marks DECIMAL(5,2);
    DECLARE v_grade VARCHAR(5);
    DECLARE v_gpa DECIMAL(3,2);

    DECLARE v_student_status ENUM('proper','repeat','suspended');

    -- GET MARKS 

    SELECT 
        COALESCE(assignment,0), 
        COALESCE(mid_exam,0), 
        COALESCE(practical,0), 
        COALESCE(final_exam,0)
    INTO 
        v_assignment, v_mid, v_practical, v_final
    FROM marks 
    WHERE reg_no = p_reg_no 
      AND course_code = p_course_code
    LIMIT 1;

    --  MEDICAL CHECK
    -- For now default FALSE (you can later connect medical table)

    SET v_medical_ca = FALSE;
    SET v_medical_mid = FALSE;
    SET v_medical_final = FALSE;

    --  CALCULATE GRADE (USES YOUR FIXED PROCEDURE)
    CALL CalculateGrade(
        v_assignment, v_mid, v_practical, v_final,
        v_medical_ca, v_medical_mid, v_medical_final,
        v_final_marks, v_grade, v_gpa
    );

    --  STUDENT STATUS RULES
    SELECT status 
    INTO v_student_status 
    FROM students 
    WHERE reg_no = p_reg_no
    LIMIT 1;

    IF v_student_status = 'suspended' THEN
        SET v_grade = 'WH';
        SET v_gpa = 0.00;

    ELSEIF v_student_status = 'repeat' AND v_gpa > 2.00 THEN
        SET v_grade = 'C';   -- Max grade for repeat
        SET v_gpa = 2.00;
    END IF;

    -- 5. INSERT / UPDATE RESULTS
    INSERT INTO results (reg_no, course_code, final_marks, grade, gpa)
    VALUES (p_reg_no, p_course_code, v_final_marks, v_grade, v_gpa)
    ON DUPLICATE KEY UPDATE 
        final_marks = VALUES(final_marks),
        grade = VALUES(grade),
        gpa = VALUES(gpa);

END //

DELIMITER ;