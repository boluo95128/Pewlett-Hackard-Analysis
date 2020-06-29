-- Creating tables for Employee Database
CREATE TABLE departments(
		dept_no VARCHAR(4) NOT NULL,
		dept_name VARCHAR(40) NOT NULL,
		PRIMARY KEY (dept_no),
		UNIQUE (dept_name)
);

CREATE TABLE employees(
		emp_no INT NOT NULL,
		birth_date DATE NOT NULL,
		first_name VARCHAR NOT NULL,
		last_name VARCHAR NOT NULL,
		gender VARCHAR NOT NULL,
		hire_date DATE NOT NULL,
		PRIMARY KEY (emp_no)
);

CREATE TABLE dept_emp(
		emp_no INT NOT NULL,
		dept_no VARCHAR (4) NOT NULL,
		from_date DATE NOT NULL,
		to_date DATE NOT NULL,
		FOREIGN KEY (emp_no) REFERNCES employees (emp_no),
		FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
		PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
		emp_no INT NOT NULL,
		title VARCHAR (50) NOT NULL,
		from_date DATE NOT NULL,
		to_date DATE NOT NULL,
		FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
		PRIMARY KEY (emp_no, title, from_date)
);

CREATE TABLE salaries (
		emp_no INT NOT NULL,
		salary INT NOT NULL,
		from_date DATE NOT NULL,
		to_date DATE NOT NULL,
		FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
		PRIMARY KEY (emp_no, from_date)
);

-- Deliverable 1: Number of Retiring Employees by Title
-- Creating a table for retirement eligible employees born between 1952-01-01 and 1955-12-31.
SELECT employees.emp_no,
	   employees.first_name,
	   employees.last_name,
	   titles.title,
	   dept_emp.from_date,
	   dept_emp.to_date,
	   salaries.salary
INTO retiring_employee_by_title
FROM employees
INNER JOIN dept_emp
On (employees.emp_no = dept_emp.emp_no)
INNER JOIN titles
ON (employees.emp_no = titles.emp_no)
INNER JOIN salaries
ON (employees.emp_no = salaries.emp_no)
WHERE (employees.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (dept_emp.to_date = '9999-01-01');

-- Partition the data to show only most recent title per employee
SELECT emp_no,
	   first_name,
	   last_name,
	   title,
	   from_date,
	   salary,
	   to_date
INTO retiring_employee_current_title
FROM
(SELECT * ,
  ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM retiring_employee_by_title
 ) tmp WHERE rn = 1
ORDER BY emp_no

-- Creating a table showing number of employees retiring per title
SELECT title, COUNT(emp_no) 
INTO no_of_emp_per_title
FROM retiring_employee_current_title
GROUP BY title

-- Creating a table showing the number of titles retiring
SELECT COUNT(title)
INTO no_of_titles_retiring
FROM no_of_emp_per_title

-- Deliverable 2: Mentorship Eligibility
-- Creating a table holding all 
SELECT employees.emp_no,
	   employees.first_name,
	   employees.last_name,
	   titles.title,
	   titles.from_date,
	   titles.to_date
INTO eligible_mentors
FROM employees
INNER JOIN dept_emp
ON (employees.emp_no = dept_emp.emp_no)
INNER JOIN titles
ON (employees.emp_no = titles.emp_no)
WHERE (employees.birth_date BETWEEN '1965-01-01' and '1965-12-31')
AND (dept_emp.to_date = '9999-01-01');

-- Partitioning the eligible_mentors table to remove duplicates
SELECT emp_no,
	   first_name,
	   last_name,
	   title,
	   from_date,
	   to_date
INTO eligible_mentors_no_dup
FROM
(SELECT * ,
  ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM eligible_mentors
 ) tmp WHERE rn = 1
ORDER BY emp_no;