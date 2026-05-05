--view attendance for whole batch by giving cours code

DELIMITER //

create procedure attendance_per_course(IN in_course_code VARCHAR(15))
BEGIN
 select 
      s.reg_no as 'Registration No',
        
      COUNT(CASE when a.status = 'present' then 1 END) as 'Total Days Present',
        
       ROUND(
            (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
            (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = in_course_code)) 
            * 100, 2
        ) AS 'Percentage',
        
        -- eligible if >=80
        CASE 
            when (COUNT(CASE when a.status = 'present' then 1 end) / 
                 (select COUNT(DISTINCT week, type) from attendance where course_code = in_course_code)) 
                 * 100 >= 80 then'Eligible'
            else 'Not Eligible'
        END as 'Eligibility'
        
    from students s
    join attendance a ON s.reg_no = a.reg_no
    where a.course_code = in_course_code
    GROUP BY s.reg_no;
END //

DELIMITER ;

--(sample output) call attendance_per_course('ICT1242');


--view attendance per person 

DELIMITER //

create procedure student_attendance(IN in_reg_no VARCHAR(10))
BEGIN
    select 
        a.course_code AS 'Course Code',
        c.name AS 'Course Name',
        
        -- total lectures
        (select COUNT(distinct week, type) 
         from attendance 
         where course_code = a.course_code) AS 'Total lectures',
        
    
        COUNT(CASE when a.status = 'present' THEN 1 END) AS 'Present days',
        
        ROUND(
            (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
            (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = a.course_code)) 
            * 100, 2
        ) AS 'Attendance',
        
        -- Eligibility check
        CASE 
            WHEN (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
                 (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = a.course_code)) 
                 * 100 >= 80 THEN 'Eligible'
            ELSE 'Not Eligible'
        END AS 'Eligibility'
        
    FROM attendance a
    JOIN courses c ON a.course_code = c.course_code
    WHERE a.reg_no = in_reg_no
    GROUP BY a.course_code;
END //

DELIMITER ;

--(sample output) call student_attendance('TG/1030');

--view attendance per person with course code

DELIMITER //

CREATE PROCEDURE per_person_with_course(
    IN in_reg_no VARCHAR(10), 
    IN in_course_code VARCHAR(15)
)
BEGIN
    SELECT 
        s.reg_no AS 'Registration No',
        s.name AS 'Student Name',
        c.name AS 'Course Name',
        
        -- total lectures
        (SELECT COUNT(DISTINCT week, type) 
         FROM attendance 
         WHERE course_code = in_course_code) AS 'Total Lectures',
        
        -- presant days
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS 'Present Days ',
        
        ROUND(
            (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
            (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = in_course_code)) 
            * 100, 2
        ) AS 'Attendance ',
        
        -- Eligibility Check
        CASE 
            WHEN (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
                 (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = in_course_code)) 
                 * 100 >= 80 THEN 'Eligible'
            ELSE 'Not Eligible'
        END AS 'Status'
        
    FROM students s
    JOIN attendance a ON s.reg_no = a.reg_no
    JOIN courses c ON a.course_code = c.course_code
    WHERE s.reg_no = in_reg_no 
    AND a.course_code = in_course_code
    GROUP BY s.reg_no, c.course_code;
END //

DELIMITER ;
--(sample output) call per_person_with_course('TG/1020','ICT1232');



                                             -- MARKS


--	CA for whole batch By giving course code 

DELIMITER //

create procedure CA_whole_batch(IN in_course_code VARCHAR(15))
BEGIN
    
    
    SELECT 
        m.reg_no AS 'Registration No',
        s.name AS 'Student Name',
        
        -- separate marks
        m.assignment AS 'Assignment Marks',
        m.mid_exam AS 'Mid-Exam Marks',
        m.quiz AS 'Quiz Marks',
        
        -- CA final marks for 50
        ROUND(
            ((m.assignment / 100.0) * 10) + 
            ((m.mid_exam / 100.0) * 20) + 
            ((m.quiz / 100.0) * 20), 2
        ) AS 'Total CA Marks',
        
        
        -- eligiblity check
        CASE 
            WHEN (((m.assignment / 100.0) * 10) + 
                  ((m.mid_exam / 100.0) * 20) + 
                  ((m.quiz / 100.0) * 20)) >= 20 THEN 'Eligible'
            ELSE 'Not Eligible'
        END AS 'Eligibility'
        
    FROM marks m
    JOIN students s ON m.reg_no = s.reg_no
    WHERE m.course_code = in_course_code
    ORDER BY m.reg_no ASC;
END //

DELIMITER ;
--(sample output) call CA_whole_batch('ICT1232');



--view CA marks details  By giving course code and registration no

DELIMITER //

CREATE PROCEDURE CA_indi_with_course(IN in_reg_no VARCHAR(10), IN in_course_code VARCHAR(15))
BEGIN
    SELECT 
        s.reg_no AS 'Registration No',
        s.name AS 'Student Name',
        c.name AS 'Course Name',
        
        -- CA calculation
        ROUND(
            ((m.assignment / 100.0) * 10) + 
            ((m.mid_exam / 100.0) * 20) + 
            ((m.quiz / 100.0) * 20), 2
        ) AS 'Total CA Marks', 

      -- eligibility check
        CASE 
            when (((m.assignment / 100.0) * 10) + 
                  ((m.mid_exam / 100.0) * 20) + 
                  ((m.quiz / 100.0) * 20)) >= 20 THEN 'Eligible'
            else 'Not Eligible'
        END AS 'Eligibility'
        
    from marks m
    join students s ON m.reg_no = s.reg_no
    join courses c ON m.course_code = c.course_code
    where m.reg_no = in_reg_no 
    AND m.course_code = in_course_code;
END //

DELIMITER ;

--(sample output) call CA_indi_with_course('TG/1030','ICT1232');


--final marks for individuals with reg no

DELIMITER //

CREATE PROCEDURE FinalMarks_individual(IN in_reg_no VARCHAR(10))
BEGIN
    SELECT 
        s.reg_no AS 'Registration No',
        s.name AS 'Student Name',
        c.course_code AS 'Course Code',
        c.name AS 'Course Name',
        
        -- Calculated CA 
        ROUND(
            ((m.assignment / 100.0) * 10) + 
            ((m.mid_exam / 100.0) * 20) + 
            ((m.quiz/ 100.0) * 20), 2
        ) AS 'Total CA /50',
        
        -- Final Exam Marks
        ROUND((m.final_exam / 100.0) * 50, 2) AS 'Final Exam Marks /50',
        
        -- Final Marks
        ROUND(
            (((m.assignment / 100.0) * 10) + ((m.mid_exam / 100.0) * 20) + ((m.quiz / 100.0) * 20)) + 
            ((m.final_exam / 100.0) * 50), 2
        ) AS ' Total Marks'
        
    FROM marks m
    JOIN students s ON m.reg_no = s.reg_no
    JOIN courses c ON m.course_code = c.course_code
    WHERE s.reg_no = in_reg_no;
END //

DELIMITER ;

--(sample output) call FinalMarks_individual('TG/1010');


--see if student/s are eligible according to the criteria of CA to sit for the final exam


DELIMITER //

CREATE PROCEDURE ExamEligibility_check(IN in_course_code VARCHAR(15))
BEGIN
    SELECT 
        s.reg_no AS 'Registration No',
        s.name AS 'Name',
        
        -- Attendance calculation
        ROUND((COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
            (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = in_course_code)) * 100, 2) AS 'Attendance',
            
        -- 2. CA Marks Calculation 
        ROUND(((m.assignment/100.0)*10) + ((m.mid_exam/100.0)*20) + ((m.quiz/100.0)*20), 2) AS 'CA Marks',
        
        -- 3. Final Eligibility Logic
        CASE 
            WHEN 
                -- Attendance Check
                (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
                (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = in_course_code)) * 100 >= 80
                AND 
                -- CA Marks Check
                (((m.assignment/100.0)*10) + ((m.mid_exam/100.0)*20) + ((m.quiz/100.0)*20)) >= 20
            THEN 'ELIGIBLE'
            ELSE 'NOT ELIGIBLE'
        END AS 'Exam Status'
        
    FROM students s
    JOIN attendance a ON s.reg_no = a.reg_no
    JOIN marks m ON s.reg_no = m.reg_no AND a.course_code = m.course_code
    WHERE a.course_code = in_course_code
    GROUP BY s.reg_no;
END //

DELIMITER ;

--(sample outpu ) call ExamEligibility_check('ICT1232');



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

 




