--view attendance for whole batch by giving cours code

DELIMITER //

create procedure attendance_per_course(IN in_course_code VARCHAR(15))
BEGIN
 SELECT 
      s.reg_no AS 'Registration No',
        
      COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS 'Total Days Present',
        
       ROUND(
            (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
            (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = in_course_code)) 
            * 100, 2
        ) AS 'Percentage',
        
        -- eligible if >=80
        CASE 
            WHEN (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
                 (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = in_course_code)) 
                 * 100 >= 80 THEN 'Eligible'
            ELSE 'Not Eligible'
        END AS 'Eligibility'
        
    FROM students s
    JOIN attendance a ON s.reg_no = a.reg_no
    WHERE a.course_code = in_course_code
    GROUP BY s.reg_no;
END //

DELIMITER ;

--(sample output)


--view attendance per person 

DELIMITER //

create procedure student_attendance(IN in_reg_no VARCHAR(10))
BEGIN
    SELECT 
        a.course_code AS 'Course Code',
        c.name AS 'Course Name',
        
        -- total lectures
        (SELECT COUNT(DISTINCT week, type) 
         FROM attendance 
         WHERE course_code = a.course_code) AS 'Total lectures',
        
    
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS 'Present days',
        
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

--(sample output)

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
        ) AS 'Weighted Total CA',
        
        
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

CREATE PROCEDURE CA_indi_with_course(IN in_reg_no VARCHAR(10), IN in_course_code VARCHAR(15)
)
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
        
      --elgibility check
        CASE 
            WHEN (((m.assignment / 100.0) * 10) + 
                  ((m.mid_exam / 100.0) * 20) + 
                  ((m.quiz / 100.0) * 20)) >= 20 THEN 'Eligible'
            ELSE 'Not Eligible'
        END AS 'Eligibility'
        
    FROM marks m
    JOIN students s ON m.reg_no = s.reg_no
    JOIN courses c ON m.course_code = c.course_code
    WHERE m.reg_no = in_reg_no 
    AND m.course_code = in_course_code;
END //

DELIMITER ;

--(sample output) call CA_indi_with_course('TG/1030','ICT1232');





