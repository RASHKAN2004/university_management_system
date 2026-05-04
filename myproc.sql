
--as a summary for whole batch 
create view attendance_summary  as      --select * from attendance_summary_for_whole_batch;
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



 





