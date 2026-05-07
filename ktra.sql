create database QLSinhVien;
use QLSinhVien;

CREATE TABLE Department (
    DeptID VARCHAR(5) PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);

CREATE TABLE Student (
    StudentID VARCHAR(6) PRIMARY KEY,
    FullName VARCHAR(50),
    Gender VARCHAR(10),
    BirthDate DATE,
    DeptID VARCHAR(5),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

CREATE TABLE Course (
    CourseID VARCHAR(6) PRIMARY KEY,
    CourseName VARCHAR(50),
    Credits INT
);

CREATE TABLE Enrollment (
    StudentID VARCHAR(6),
    CourseID VARCHAR(6),
    Score DECIMAL(4,2), 
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

INSERT INTO Department VALUES
	('IT','Information Technology'),
	('BA','Business Administration'),
	('ACC','Accounting');

INSERT INTO Student 
VALUES
	('S00001','Nguyen An','Male','2003-05-10','IT'),
	('S00002','Tran Binh','Male','2003-06-15','IT'),
	('S00003','Le Hoa','Female','2003-08-20','BA'),
	('S00004','Pham Minh','Male','2002-12-12','ACC'),
	('S00005','Vo Lan','Female','2003-03-01','IT'),
	('S00006','Do Hung','Male','2002-11-11','BA'),
	('S00007','Nguyen Mai','Female','2003-07-07','ACC'),
	('S00008','Tran Phuc','Male','2003-09-09','IT');
    
INSERT INTO Course (CourseID, CourseName, Credits)
VALUES
	('C00001', 'Introduction to IT', 3),
	('DB202', 'Database Systems', 4),
	('MA301', 'Calculus A1', 3),
	('BA101', 'Business Basics', 2),
	('ACC11', 'Principles of Accounting', 4);
    
INSERT INTO Enrollment (StudentID, CourseID, Score) 
VALUES
	('S00001', 'C00001', 8.50),
	('S00001', 'DB202', 7.00),
	('S00002', 'C00001', 6.00),
	('S00002', 'DB202', 9.25),
	('S00003', 'C00001', 8.00),
	('S00003', 'MA301', 5.50),
	('S00006', 'C00001', 7.50),
	('S00004', 'ACC11', 9.00),
	('S00004', 'MA301', 4.00),
	('S00007', 'ACC11', 8.75),
	('S00005', 'C00001', 10.00),
	('S00008', 'DB202', 6.50);

-- c1
create view ViewStudentBasic
as
select s.StudentID, s.FullName, d.DeptName from Student s
join Department d on d.DeptID = s.DeptID;
select * from ViewStudentBasic;

-- c2
create index idxFullName on Student(FullName);

-- c3
delimiter //
create procedure GetStudentsIT()
begin
	select s.*, d.DeptName from Student s
    join Department d on d.DeptID = s.DeptID
    where d.DeptName = 'Information Technology';
end //
delimiter ;
call GetStudentsIT();

-- c4a
create view ViewStudentCountByDept 
as
select d.DeptName, count(s.studentID) as TotalStudents 
from Department d
join Student s on s.DeptID = d.DeptID
group by d.DeptID;
select * from ViewStudentCountByDept;

-- c4b
select d.DeptName, count(s.studentID) as TotalStudents 
from Department d
join Student s on s.DeptID = d.DeptID
group by d.DeptID
order by TotalStudents desc
limit 1;

-- c5a
delimiter //
create procedure GetTopScoreStudent (IN varCourseID VARCHAR(6))
begin
	select s.studentID, s.FullName, c.CourseName, e.Score from Student s
    join Enrollment e on e.StudentID = s.StudentID
    join Course c on c.courseID = e.courseID
    where e.score = (select max(e2.score) from Enrollment e2 where e2.courseID = varCourseID)
    group by s.studentID, c.courseID;
end //
delimiter ;

-- c5b
call GetTopScoreStudent('C00001');

-- c6a
create View ViewITEnrollmentDB 
as
select s.*, d.DeptName, c.CourseID, c.CourseName 
from Student s
join Enrollment e on e.StudentID = s.StudentID
join Department d on d.DeptID = s.DeptID
join Course c on c.CourseID = e.CourseID
where d.DeptID = 'IT' and c.courseID = 'C00001' and e.score > 0
group by s.StudentID, d.DeptID, c.CourseID
with check option;
select * from ViewITEnrollmentDB;

-- c6b
delimiter //
create procedure UpdateScoreITDB (
	IN varStudentID VARCHAR(6),
	INOUT inoutNewScore DECIMAL(4,2)
)
begin
	if inoutNewScore > 10 then
		set inoutNewScore = 10;
	else 
		set inoutNewScore = varStudentID.score;
	end if;
end //
delimiter ;
call UpdateScoreITDB ('C00001', @inoutNewScore);
select @inoutNewScore;
