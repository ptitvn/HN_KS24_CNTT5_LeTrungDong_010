-- PHẦN 1: TẠO CSDL + BẢNG
DROP DATABASE IF EXISTS hackathon;
CREATE DATABASE hackathon;
USE hackathon;

DROP TABLE IF EXISTS Assignment;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Project;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
  dept_id VARCHAR(5) PRIMARY KEY,
  dept_name VARCHAR(100) NOT NULL UNIQUE,
  location VARCHAR(100) NOT NULL,
  manager_name VARCHAR(50) NOT NULL
);

CREATE TABLE Employee (
  emp_id VARCHAR(5) PRIMARY KEY,
  emp_name VARCHAR(50) NOT NULL,
  dob  DATE NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(15) NOT NULL UNIQUE,
  dept_id VARCHAR(5) NOT NULL,
  CONSTRAINT fk_employee_department
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);


CREATE TABLE Project (
  project_id VARCHAR(5) PRIMARY KEY,
  project_name  VARCHAR(200) NOT NULL UNIQUE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  budget DECIMAL(10,2) NOT NULL CHECK (budget >= 0)
);

CREATE TABLE Assignment (
  assignment_id INT PRIMARY KEY AUTO_INCREMENT,
  emp_id VARCHAR(5) NOT NULL,
  project_id VARCHAR(5) NOT NULL,
  role VARCHAR(20) NOT NULL,
  hours_worked INT NOT NULL,
  CONSTRAINT fk_assignment_employee
    FOREIGN KEY (emp_id) REFERENCES Employee(emp_id),
  CONSTRAINT fk_assignment_project
    FOREIGN KEY (project_id) REFERENCES Project(project_id),
  CONSTRAINT chk_hours_worked
    CHECK (hours_worked >= 0)
);

-- PHẦN 1: CHÈN DỮ LIỆU MẪU

INSERT INTO Department (dept_id, dept_name, location, manager_name) VALUES
('D01', 'IT', 'Floor 5', 'Nguyen Van An'),
('D02', 'HR', 'Floor 2', 'Tran Thi Binh'),
('D03', 'Sales', 'Floor 1', 'Le Van Cuong'),
('D04', 'Marketing', 'Floor 3', 'Pham Thi Dung'),
('D05', 'Finance',   'Floor 4', 'Hoang Van Tu');

INSERT INTO Employee (emp_id, emp_name, dob, email, phone, dept_id) VALUES
('E001', 'Nguyen Van Tuan', '1990-01-01', 'tuan@email.com', '0901234567', 'D01'),
('E002', 'Tran Thi Lan',  '1995-05-09', 'lan@email.com',  '0902345678', 'D02'),
('E003', 'Le Minh Khoi', '1992-10-10', 'khoi@email.com', '0903456789', 'D01'),
('E004', 'Pham Hoang Nam',  '1998-12-12', 'nam@email.com',  '0904567890', 'D03'),
('E005', 'Vu Minh Ha', '1996-07-07', 'ha@email.com', '0905678901', 'D01');

INSERT INTO Project (project_id, project_name, start_date, end_date, budget) VALUES
('P001', 'Website Redesign', '2025-01-01', '2025-06-01',  50000.00),
('P002', 'Mobile App Dev',  '2025-02-01', '2025-08-01',  80000.00),
('P003', 'HR System', '2025-03-01', '2025-09-01',  30000.00),
('P004', 'Marketing Campaign', '2025-04-01', '2025-05-01',  10000.00),
('P005', 'AI Research', '2025-05-01', '2025-12-31', 100000.00);

INSERT INTO Assignment (emp_id, project_id, role, hours_worked) VALUES
('E001', 'P001', 'Developer',  150),
('E003', 'P001', 'Tester',  100),
('E001', 'P002', 'Tech Lead',  200),
('E005', 'P005', 'Data Scientist', 180),
('E004', 'P004', 'Content Creator', 50);

-- PHẦN 2: TRUY VẤN CƠ BẢN

-- 3 Cập nhật location dept_id='C001' -> Floor 10 (theo đề)
UPDATE Department
SET location = 'Floor 10'
WHERE dept_id = 'C001';

-- 4 Tăng budget P005 10% + lùi end_date 1 tháng
UPDATE Project
SET budget = budget * 1.10,
    end_date = DATE_ADD(end_date, INTERVAL 1 MONTH)
WHERE project_id = 'P005';

-- 5 Xóa Assignment có hours_worked=0 hoặc role='Intern'
DELETE FROM Assignment
WHERE hours_worked = 0
   OR role = 'Intern';

-- 6 Liệt kê emp_id, emp_name, email thuộc dept_id='D01'
SELECT emp_id, emp_name, email
FROM Employee
WHERE dept_id = 'D01';

-- 7 project_name, start_date, budget có tên chứa 'System'
SELECT project_name, start_date, budget
FROM Project
WHERE project_name LIKE '%System%';

-- 8 Danh sách dự án (id, name, budget) sắp xếp budget giảm dần
SELECT project_id, project_name, budget
FROM Project
ORDER BY budget DESC;

-- 9 3 nhân viên lớn tuổi nhất (dob nhỏ nhất)
SELECT emp_id, emp_name, dob
FROM Employee
ORDER BY dob ASC
LIMIT 3;

-- 10 Lấy project_id, project_name bỏ qua 1 dòng đầu, lấy 3 dòng tiếp
SELECT project_id, project_name
FROM Project
LIMIT 3 OFFSET 1;

-- PHẦN 3: TRUY VẤN NÂNG CAO

-- 11 assignment_id, emp_name, project_name, role với hours_worked > 100
SELECT a.assignment_id, e.emp_name, p.project_name, a.role
FROM Assignment a
JOIN Employee e ON e.emp_id = a.emp_id
JOIN Project  p ON p.project_id = a.project_id
WHERE a.hours_worked > 100;

-- 12 Tất cả phòng ban + emp_name (kể cả chưa có nhân viên)
SELECT d.dept_id, d.dept_name, e.emp_name
FROM Department d
LEFT JOIN Employee e ON e.dept_id = d.dept_id;

-- 13 Tổng giờ theo dự án
SELECT p.project_name, SUM(a.hours_worked) AS Total_Hours
FROM Project p
JOIN Assignment a ON a.project_id = p.project_id
GROUP BY p.project_name;

-- 14 Đếm nhân viên mỗi phòng ban, chỉ hiện >=2
SELECT d.dept_name, COUNT(e.emp_id) AS Employee_Count
FROM Department d
JOIN Employee e ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING COUNT(e.emp_id) >= 2;

-- 15 Nhân viên tham gia dự án budget > 50000
SELECT DISTINCT e.emp_name, e.email
FROM Employee e
JOIN Assignment a ON a.emp_id = e.emp_id
JOIN Project p ON p.project_id = a.project_id
WHERE p.budget > 50000;

