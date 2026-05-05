-- view attendance for whole batch

create view attendance_summary  as     
 select 
     reg_no, 
     course_code,
     count(*) as total_lectures,
     sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) as attended_lectures,
     round((sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100, 2) as percentage,
     case 
         when (sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100 >= 80 
         then 'eligible' 
         else 'not eligible' 
     end as eligibility
 from attendance
 group by reg_no, course_code;

 --(sample output) select * from attendance_summary;


 --theory and practical attendance check

 create view attendance_by_type as
 select
     reg_no,
     course_code,
     type, 
     count(*) as total_sessions,
     sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) as attended_lectures,
     round((sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100, 2) as percentage,
     case
        when (sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(*)) * 100 >= 80
        then 'eligible'
        else 'not eligible'
     end as eligibility
from attendance
group by reg_no, course_code, type;

--(sample output) select * from attendance_by_type;
--(sample output) select * from attendance_by_type where type='THEORY';


--MARKS


--see the final marks for whole batch as view

Create View Batch_Final_Marks AS
SELECT 
    m.course_code AS 'Course Code',
    m.reg_no AS 'Registration No',
    s.name AS 'Student Name',
    
    -- calculate total CA
    ROUND(
        ((m.assignment / 100.0) * 10) + 
        ((m.mid_exam / 100.0) * 20) + 
        ((m.quiz / 100.0) * 20), 2
    ) AS 'CA_Total',
    
    -- FFinal Marks
    ROUND((m.final_exam / 100.0) * 50, 2) AS 'Final Exam Marks',
    
    -- Grand Total (CA + Final Exam)
    ROUND(
        (((m.assignment / 100.0) * 10) + ((m.mid_exam / 100.0) * 20) + ((m.quiz / 100.0) * 20)) + 
        ((m.final_exam / 100.0) * 50), 2
    ) AS 'Total Marks'
    
FROM marks m
JOIN students s ON m.reg_no = s.reg_no;

--(sample output) SELECT * FROM `Batch_Final_Marks`;
