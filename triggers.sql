USE FacultyManagement;

DELIMITER //

-- Trigger - When marks are added/updated, automatically calculate result
CREATE TRIGGER after_marks_insert_update
AFTER INSERT ON marks
FOR EACH ROW
BEGIN
    CALL CalculateStudentResult(NEW.reg_no, NEW.course_code);
END //

CREATE TRIGGER after_marks_update
AFTER UPDATE ON marks
FOR EACH ROW
BEGIN
    CALL CalculateStudentResult(NEW.reg_no, NEW.course_code);
END //

DELIMITER ;