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


