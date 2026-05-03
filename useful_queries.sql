USE FacultyManagement;

--Single Student Full Report
SELECT * FROM student_attendance_report WHERE reg_no = 'ICT001';
SELECT * FROM student_results_view WHERE reg_no = 'ICT001';

--Attendance Percentage for all students in a course
SELECT * FROM student_attendance_report 
WHERE course_code = 'ICT1212' 
ORDER BY attendance_percentage DESC;

--Failed Students
SELECT * FROM student_results_view 
WHERE grade IN ('S', 'E') OR final_marks < 50;

--Lecturer wise Courses
SELECT l.name AS lecturer_name, c.course_code, c.name 
FROM lecturers l
JOIN courses c ON l.lec_id = c.lec_id;