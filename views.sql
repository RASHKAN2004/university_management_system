USE FacultyManagement;

-- Student Attendance Report
CREATE VIEW student_attendance_report AS
SELECT 
    s.reg_no,
    s.name AS student_name,
    c.course_code,
    c.name AS course_name,
    COUNT(a.attendance_id) AS total_sessions,
    SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END) AS present_count,
    ROUND(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id), 2) AS attendance_percentage
FROM students s
JOIN attendance a ON s.reg_no = a.reg_no
JOIN courses c ON a.course_code = c.course_code
GROUP BY s.reg_no, s.name, c.course_code, c.name;

-- Student Final Results View
CREATE VIEW student_results_view AS
SELECT 
    s.reg_no,
    s.name AS student_name,
    c.name AS course_name,
    r.final_marks,
    r.grade,
    r.gpa
FROM students s
JOIN results r ON s.reg_no = r.reg_no
JOIN courses c ON r.course_code = c.course_code;

-- Course Wise Performance
CREATE VIEW course_performance_view AS
SELECT 
    c.course_code,
    c.name AS course_name,
    COUNT(r.result_id) AS total_students,
    ROUND(AVG(r.final_marks), 2) AS avg_marks,
    MAX(r.final_marks) AS highest_mark,
    MIN(r.final_marks) AS lowest_mark
FROM courses c
LEFT JOIN results r ON c.course_code = r.course_code
GROUP BY c.course_code, c.name;

-- Low Attendance Students
CREATE VIEW low_attendance_students AS
SELECT 
    reg_no,
    student_name,
    course_name,
    attendance_percentage
FROM student_attendance_report
WHERE attendance_percentage < 80;