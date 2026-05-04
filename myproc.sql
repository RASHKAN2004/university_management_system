
--as a summary for whole batch 
create view attendance_summary  as     
 select 
     reg_no, 
     course_code,
     count(*) as total_sessions,
     sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) as attended_sessions,
     round((sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100, 2) as percentage,
     case 
         when (sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100 >= 80 
         then 'eligible' 
         else 'not eligible' 
     end as eligibility
 from attendance
 group by reg_no, course_code;


 --select * from attendance_summary_for_whole_batch with course code;

DELIMITER //

CREATE PROCEDURE GetBatchAttendanceSummaryCount(IN input_course_code VARCHAR(15))
BEGIN
    SELECT 
        s.reg_no AS 'Registration No',
        
        -- Total days present for the student
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS 'Total Days Present',
        
        -- Percentage Calculation using an inline subquery for the total sessions
        ROUND(
            (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
            (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = input_course_code)) 
            * 100, 2
        ) AS 'Percentage',
        
        -- Eligibility Logic (>= 80%)
        CASE 
            WHEN (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
                 (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = input_course_code)) 
                 * 100 >= 80 THEN 'Eligible'
            ELSE 'Ineligible'
        END AS 'Eligibility'
        
    FROM students s
    JOIN attendance a ON s.reg_no = a.reg_no
    WHERE a.course_code = input_course_code
    GROUP BY s.reg_no;
END //

DELIMITER ;


--per person

DELIMITER //

CREATE PROCEDURE GetStudentAttendanceSummary(IN input_reg_no VARCHAR(10))
BEGIN
    SELECT 
        a.course_code AS 'Course Code',
        c.name AS 'Course Name',
        
        -- Total sessions conducted for this specific course
        (SELECT COUNT(DISTINCT week, type) 
         FROM attendance 
         WHERE course_code = a.course_code) AS 'Total Sessions',
        
        -- Count of sessions where student was 'present'
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS 'Days Present',
        
        -- Percentage calculation
        ROUND(
            (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
            (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = a.course_code)) 
            * 100, 2
        ) AS 'Attendance %',
        
        -- Eligibility Logic
        CASE 
            WHEN (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
                 (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = a.course_code)) 
                 * 100 >= 80 THEN 'Eligible'
            ELSE 'Ineligible'
        END AS 'Exam Eligibility'
        
    FROM attendance a
    JOIN courses c ON a.course_code = c.course_code
    WHERE a.reg_no = input_reg_no
    GROUP BY a.course_code;
END //

DELIMITER ;

--as individual with course code

DELIMITER //

CREATE PROCEDURE GetIndividualCourseAttendanceSummary(
    IN input_reg_no VARCHAR(10), 
    IN input_course_code VARCHAR(15)
)
BEGIN
    SELECT 
        s.reg_no AS 'Registration No',
        s.name AS 'Student Name',
        c.name AS 'Course Name',
        
        -- Total sessions conducted for this course so far
        (SELECT COUNT(DISTINCT week, type) 
         FROM attendance 
         WHERE course_code = input_course_code) AS 'Total Sessions',
        
        -- Total days this specific student was present
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) AS 'Total Days Present',
        
        -- Percentage Calculation
        ROUND(
            (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
            (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = input_course_code)) 
            * 100, 2
        ) AS 'Attendance %',
        
        -- Eligibility Logic
        CASE 
            WHEN (COUNT(CASE WHEN a.status = 'present' THEN 1 END) / 
                 (SELECT COUNT(DISTINCT week, type) FROM attendance WHERE course_code = input_course_code)) 
                 * 100 >= 80 THEN 'Eligible'
            ELSE 'Ineligible'
        END AS 'Status'
        
    FROM students s
    JOIN attendance a ON s.reg_no = a.reg_no
    JOIN courses c ON a.course_code = c.course_code
    WHERE s.reg_no = input_reg_no 
    AND a.course_code = input_course_code
    GROUP BY s.reg_no, c.course_code;
END //

DELIMITER ;







 --theory and practical attendance check

create view attendance_by_type as
 select
     reg_no,
     course_code,
     type, 
     count(*) as total_sessions,
     sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) as attended_sessions,
     round((sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100, 2) as percentage,
     case
        when (sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100 >= 80
        then 'eligible'
        else 'not eligible'
     end as eligibility
from attendance
group by reg_no, course_code, type;













































--Get Attendance by Session Type (Theory/Practical/Combined)
delimiter //
create procedure get_filtered_attendance(
    in p_course_code varchar(15), 
    in p_type varchar(20) -- pass 'THEORY', 'PRACTICAL', or 'COMBINED'
)
begin
    if p_type = 'COMBINED' then
        select * from v_batch_attendance_summary where course_code = p_course_code;
    else
        select 
            reg_no, 
            course_code,
            p_type as session_filter,
            round((sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100, 2) as percentage,
            case 
                when (sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100 >= 80 
                then 'eligible' 
                else 'not eligible' 
            end as eligibility
        from attendance
        where course_code = p_course_code and type = p_type
        group by reg_no, course_code;
    end if;
end //



 





