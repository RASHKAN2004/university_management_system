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





