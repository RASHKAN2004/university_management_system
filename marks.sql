--View: Continuous Assessment (CA) Batch Summary


create view v_ca_batch_summary as
select 
    reg_no, 
    course_code,
    sum(case when type = 'QUIZ' then marks else 0 end) as quiz_marks,
    sum(case when type = 'ASSESSMENT' then marks else 0 end) as assessment_marks,
    sum(case when type = 'MID_THEORY' then marks else 0 end) as mid_theory_marks,
    sum(case when type = 'MID_PRACTICAL' then marks else 0 end) as mid_practical_marks,
    sum(case when type in ('QUIZ', 'ASSESSMENT', 'MID_THEORY', 'MID_PRACTICAL') then marks else 0 end) as total_ca_marks
from marks
group by reg_no, course_code;

--CA Summary for Whole Batch (By Course)

delimiter //
create procedure get_ca_batch_by_course(in p_course_code varchar(15))
begin
    select * from v_ca_batch_summary 
    where course_code = p_course_code;
end //
delimiter ;

--Individual Student CA Details

delimiter //
create procedure get_individual_ca_details(
    in p_reg_no varchar(15), 
    in p_course_code varchar(15)
)
begin
    select type, marks 
    from marks 
    where reg_no = p_reg_no 
    and course_code = p_course_code
    and type in ('QUIZ', 'ASSESSMENT', 'MID_THEORY', 'MID_PRACTICAL');
end //
delimiter ;

--Individual Student Summary (All Subjects)

delimiter //
create procedure get_student_overall_ca_summary(in p_reg_no varchar(15))
begin
    select 
        course_code, 
        total_ca_marks 
    from v_ca_batch_summary 
    where reg_no = p_reg_no;
end //
delimiter ;

--Whole Batch Final Marks (View)

create view v_final_marks_batch as
select 
    r.reg_no,
    s.name as student_name,
    r.course_code,
    r.final_marks,
    r.grade,
    r.gpa
from results r
join students s on r.reg_no = s.reg_no;

--Individual Final Marks (Procedure)

delimiter //
create procedure get_individual_final_marks(in p_reg_no varchar(15))
begin
    select course_code, final_marks, grade, gpa 
    from results 
    where reg_no = p_reg_no;
end //
delimiter ;

--CA Eligibility Status

create view v_ca_eligibility_ugc as
select 
    reg_no, 
    course_code,
    sum(case when type in ('QUIZ', 'ASSESSMENT', 'MID_THEORY', 'MID_PRACTICAL') then marks else 0 end) as total_ca_marks,
    case 
        when sum(case when type in ('QUIZ', 'ASSESSMENT', 'MID_THEORY', 'MID_PRACTICAL') then marks else 0 end) >= 40 
        then 'ELIGIBLE' 
        else 'NOT ELIGIBLE' 
    end as ca_status
from marks
group by reg_no, course_code;


--Final Eligibility (Attendance + CA Marks)


create view v_final_eligibility_check as
select 
    att.reg_no,
    att.course_code,
    att.eligibility as attendance_status,
    ca.ca_status as marks_status,
    case 
        when att.eligibility = 'eligible' and ca.ca_status = 'ELIGIBLE' 
        then 'ALLOWED' 
        else 'BARRED' 
    end as final_exam_permission
from v_batch_attendance_summary att
join v_ca_eligibility_ugc ca on att.reg_no = ca.reg_no and att.course_code = ca.course_code;



--•	Grade students according to the UGC Commission Circular No. 12-2024

delimiter //

create procedure calculate_ugc_grades(in p_course_code varchar(15))
begin
    select 
        m.reg_no,
        s.name,
        sum(m.marks) as total_marks,
        case 
            -- Rule 3: Suspended status displays as WH (Withheld)
            when s.status = 'suspended' then 'WH'
            
            -- Rule 2: Medicals for CA/Exams display as MC
            when exists (select 1 from attendance a 
                         where a.reg_no = m.reg_no 
                         and a.course_code = m.course_code 
                         and a.status = 'MEDICAL') then 'MC'
            
            -- Rule 3: Repeat students maximum grade is 'C'
            when s.status = 'repeat' then
                case 
                    when sum(m.marks) >= 50 then 'C'
                    when sum(m.marks) >= 45 then 'C-'
                    when sum(m.marks) >= 40 then 'D+'
                    else 'E'
                end
            
            -- Standard UGC Grading Scale for 'Proper' students
            else
                case 
                    when sum(m.marks) >= 85 then 'A+'
                    when sum(m.marks) >= 75 then 'A'
                    when sum(m.marks) >= 70 then 'A-'
                    when sum(m.marks) >= 65 then 'B+'
                    when sum(m.marks) >= 60 then 'B'
                    when sum(m.marks) >= 55 then 'B-'
                    when sum(m.marks) >= 50 then 'C+'
                    when sum(m.marks) >= 45 then 'C'
                    when sum(m.marks) >= 40 then 'C-'
                    else 'E'
                end
        end as final_grade
    from marks m
    join students s on m.reg_no = s.reg_no
    where m.course_code = p_course_code
    group by m.reg_no, s.status;
end //

delimiter ;


--View Marks for a Whole Batch (By Subject)

delimiter //
create procedure get_subject_batch_marks(in p_course_code varchar(15))
begin
    select 
        m.reg_no,
        s.name as student_name,
        m.type as assessment_type,
        m.marks
    from marks m
    join students s on m.reg_no = s.reg_no
    where m.course_code = p_course_code
    order by m.reg_no, m.type;
end //
delimiter ;

--View Marks for a Specific Student (All Subjects)

delimiter //
create procedure get_student_gradebook(in p_reg_no varchar(15))
begin
    select 
        c.course_code,
        c.name as course_name,
        m.type as assessment_type,
        m.marks
    from marks m
    join courses c on m.course_code = c.course_code
    where m.reg_no = p_reg_no
    order by c.course_code;
end //
delimiter ;

--View Marks for a Specific Student (All Subjects)

delimiter //

create procedure get_student_marks_all_subjects(in p_reg_no varchar(15))
begin
    select 
        c.course_code,
        c.name as course_name,
        m.type as assessment_type,
        m.marks
    from marks m
    join courses c on m.course_code = c.course_code
    join students s on m.reg_no = s.reg_no
    where m.reg_no = p_reg_no
    order by c.course_code, m.type;
end //

delimiter ;