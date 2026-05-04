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