CREATE DATABASE FacultyManagement;
USE FacultyManagement;

CREATE TABLE students(
    reg_no VARCHAR(15) PRIMARY KEY, 
    name VARCHAR(50),
    nic VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(15),
    address VARCHAR(100),
    status ENUM('proper', 'repeat', 'suspended')
);

CREATE TABLE lecturers(
    lec_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(15),
    department VARCHAR(50),
    qualification VARCHAR(100)
);

CREATE TABLE technical_officers(
    tech_officer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(15),
    lab VARCHAR(50),
    shift_time VARCHAR(50),
    experience VARCHAR(20)
);

CREATE TABLE courses(
    course_code VARCHAR(15) PRIMARY KEY,
    name VARCHAR(50),
    credits INT,
    type ENUM('theory', 'practical'),
    lec_id INT,
    FOREIGN KEY(lec_id) REFERENCES lecturers(lec_id)
);

CREATE TABLE attendance(
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    reg_no VARCHAR(15),
    course_code VARCHAR(15),
    type ENUM('THEORY','PRACTICAL'),
    week INT,
    status ENUM('PRESENT','ABSENT','MEDICAL'),
    FOREIGN KEY(reg_no) REFERENCES students(reg_no),
    FOREIGN KEY(course_code) REFERENCES courses(course_code)
);

CREATE TABLE marks(
    mark_id INT PRIMARY KEY AUTO_INCREMENT,
    reg_no VARCHAR(15),
    course_code VARCHAR(15),
    type ENUM('QUIZ','ASSESSMENT','MID_THEORY','MID_PRACTICAL','FINAL_THEORY','FINAL_PRACTICAL'),
    marks INT,
    FOREIGN KEY(reg_no) REFERENCES students(reg_no),
    FOREIGN KEY(course_code) REFERENCES courses(course_code)    
);

CREATE TABLE results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    reg_no VARCHAR(15),
    course_code VARCHAR(15),
    final_marks DECIMAL(5,2),
    grade VARCHAR(5),
    gpa DECIMAL(3,2),
    FOREIGN KEY(reg_no) REFERENCES students(reg_no),
    FOREIGN KEY(course_code) REFERENCES courses(course_code)  
);