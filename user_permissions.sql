-- =============================================
-- User Permissions for FacultyManagement
-- =============================================

USE FacultyManagement;

-- Drop existing users (Safe for re-running)
DROP USER IF EXISTS 'admin'@'localhost';
DROP USER IF EXISTS 'dean'@'localhost';
DROP USER IF EXISTS 'lecturer'@'localhost';
DROP USER IF EXISTS 'technical_officer'@'localhost';
DROP USER IF EXISTS 'student'@'localhost';

-- =============================================
-- 1. Admin - Full Control
-- =============================================
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON FacultyManagement.* TO 'admin'@'localhost' WITH GRANT OPTION;

-- =============================================
-- 2. Dean - Full Access
-- =============================================
CREATE USER 'dean'@'localhost' IDENTIFIED BY 'dean123';
GRANT ALL PRIVILEGES ON FacultyManagement.* TO 'dean'@'localhost';

-- =============================================
-- 3. Lecturer 
-- =============================================
CREATE USER 'lecturer'@'localhost' IDENTIFIED BY 'lecturer123';
GRANT SELECT, INSERT, UPDATE, DELETE ON FacultyManagement.courses TO 'lecturer'@'localhost';
GRANT SELECT, INSERT, UPDATE ON FacultyManagement.attendance TO 'lecturer'@'localhost';
GRANT SELECT, INSERT, UPDATE ON FacultyManagement.marks TO 'lecturer'@'localhost';
GRANT SELECT, INSERT, UPDATE ON FacultyManagement.results TO 'lecturer'@'localhost';
GRANT SELECT ON FacultyManagement.students TO 'lecturer'@'localhost';

-- =============================================
-- 4. Technical Officer
-- =============================================
CREATE USER 'technical_officer'@'localhost' IDENTIFIED BY 'officer123';
GRANT SELECT, INSERT, UPDATE ON FacultyManagement.attendance TO 'technical_officer'@'localhost';
GRANT SELECT ON FacultyManagement.students TO 'technical_officer'@'localhost';
GRANT SELECT ON FacultyManagement.courses TO 'technical_officer'@'localhost';

-- =============================================
-- 5. Student - Limited Access
-- =============================================
CREATE USER 'student'@'localhost' IDENTIFIED BY 'student123';
GRANT SELECT ON FacultyManagement.attendance TO 'student'@'localhost';
GRANT SELECT ON FacultyManagement.results TO 'student'@'localhost';
GRANT SELECT (reg_no, name, email, phone) ON FacultyManagement.students TO 'student'@'localhost';

-- Apply Permissions
FLUSH PRIVILEGES;

-- =============================================
-- Check Permissions (Verification)
-- =============================================
SHOW GRANTS FOR 'admin'@'localhost';
SHOW GRANTS FOR 'dean'@'localhost';
SHOW GRANTS FOR 'lecturer'@'localhost';
SHOW GRANTS FOR 'technical_officer'@'localhost';
SHOW GRANTS FOR 'student'@'localhost';

SELECT user, host FROM mysql.user WHERE user IN ('admin','dean','lecturer','technical_officer','student');