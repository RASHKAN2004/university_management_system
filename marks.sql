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