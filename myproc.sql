
--whole batch summarycreate view v_batch_attendance_summary as
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

--batch attendance summary for specific course

delimiter //

create procedure get_final_batch_summary(in p_course_code varchar(15))
begin
    select 
        reg_no,
        -- counts total sessions recorded for the student in this course
        count(attendance_id) as total_sessions,
        -- counts only present and medical statuses
        sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) as attended_count,
        -- calculates percentage based on the recorded sessions
        round((sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(attendance_id)) * 100, 2) as final_percentage,
        -- eligibility check based on the 80% threshold
        case 
            when (sum(case when status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(attendance_id)) * 100 >= 80 
            then 'ELIGIBLE' 
            else 'NOT ELIGIBLE' 
        end as eligibility_status
    from attendance
    where course_code = p_course_code
    group by reg_no
    order by reg_no;
end //

delimiter ;

--Multi-Subject Batch Summary View
create view v_all_subjects_summary as
select 
    a.reg_no,
    s.name as student_name,
    c.course_code,
    c.name as course_name,
    count(a.attendance_id) as total_sessions,
    sum(case when a.status in ('PRESENT', 'MEDICAL') then 1 else 0 end) as attended_count,
    round((sum(case when a.status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(a.attendance_id)) * 100, 2) as final_percentage,
    case 
        when (sum(case when a.status in ('PRESENT', 'MEDICAL') then 1 else 0 end) / count(a.attendance_id)) * 100 >= 80 
        then 'ELIGIBLE' 
        else 'NOT ELIGIBLE' 
    end as eligibility_status
from attendance a
join students s on a.reg_no = s.reg_no
join courses c on a.course_code = c.course_code
group by a.reg_no, c.course_code
order by a.reg_no, c.course_code;

--Get Individual Student Summary
delimiter //
create procedure get_student_summary(in student_reg varchar(15))
begin
    select 
        course_code,
        percentage,
        eligibility
    from v_batch_attendance_summary
    where reg_no = student_reg;
end //
delimiter ;

--Individual Subject Attendance Procedure

delimiter //

create procedure get_individual_course_attendance(
    in p_reg_no varchar(15), 
    in p_course_code varchar(15)
)
begin
    select 
        reg_no, 
        course_code,
        count(*) as total_sessions,
        sum(case when status in ('present', 'medical') then 1 else 0 end) as attended_with_medical,
        round((sum(case when status in ('present', 'medical') then 1 else 0 end) / count(*)) * 100, 2) as attendance_percentage,
        case 
            when (sum(case when status in ('present', 'medical') then 1 else 0 end) / count(*)) * 100 >= 80 
            then 'eligible' 
            else 'not eligible' 
        end as eligibility_status
    from attendance
    where reg_no = p_reg_no and course_code = p_course_code
    group by reg_no, course_code;
end //

delimiter ;



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



 





