create database FacultyManagement;
use FacultyManagement;

create table students(
 reg_no varchar(10) primary key, 
 name varchar(50),
 nic varchar(50),
 email varchar(50),
 phone varchar(15),
 address varchar(50),
 status enum('proper', 'repeat', 'suspended')
 );

 create table lecturers(
  lec_id int primary key auto_increment,
  name varchar(50),
  email varchar(50),
  phone varchar(15),
  department varchar(50),
  qualification varchar(50)
 );

create table technical_officers(
  tech_officer_id int primary key auto_increment,
  name varchar(50),
  email varchar(50),
  phone varchar(15),
  lab varchar(50),
  shift_time varchar(50),
  experience varchar(15)
);

create table courses(
  course_code varchar(15) primary key,
  name varchar(50),
  credits int,
  type enum('theory', 'practical'),
  lec_id int,
  foreign key(lec_id) references lecturers(lec_id)
);


create table attendance(
  attendance_id int primary key auto_increment,
  reg_no varchar(10),
  course_code varchar(15),
  week int,
  type enum('theory','practical'),
  status enum('present','absent','medical'),
  foreign key(reg_no) references students(reg_no),
  foreign key(course_code) references courses(course_code)
);

create table marks(
  mark_id int primary key auto_increment,
  reg_no varchar(10),
  course_code varchar(15),
  assignment int,
  mid_exam int,
  practical int, 
  final_exam int,
  foreign key(reg_no) references students(reg_no),
  foreign key(course_code) references courses(course_code)    
);


CREATE TABLE results (
    result_id int primary key auto_increment,
    reg_no varchar(20),
    course_code varchar(10),
    final_marks decimal(5,2),
    grade varchar(5),
    gpa decimal(3,2),
    foreign key(reg_no) references students(reg_no),
  foreign key(course_code) references courses(course_code)  
);

