
create user 'admin'@'localhost' identified by 'admin123';
grant all privileges on FacultyManagement.* to 'admin'@'localhost' with grant option;

create user 'dean'@'localhost' identified by 'dean123';
grant all privileges on FacultyManagement.* to 'dean'@'localhost';

create user 'lecturer'@'localhost' identified by 'lecturer123';
grant all privileges on FacultyManagement.* to 'lecturer'@'localhost';

create user 'technical_officer'@'localhost' identified by 'officer123';
grant select,insert,update on FacultyManagement.attendance to 'technical_officer'@'localhost'; 

create user 'student'@'localhost' identified by 'student123';
grant select on FacultyManagement.attendance to 'student'@'localhost';
grant select on FacultyManagement.final_marks to 'student'@'localhost';
grant select on FacultyManagement.grades to 'student'@'localhost';

