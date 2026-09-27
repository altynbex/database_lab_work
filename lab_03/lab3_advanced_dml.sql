CREATE DATABASE advanced_lab;


DROP TABLE IF EXISTS temp_employees;
DROP TABLE IF EXISTS employee_archive;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  VARCHAR(100) NOT NULL,
    budget     INTEGER,
    manager_id INTEGER
);

CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    department VARCHAR(100),
    salary     INTEGER DEFAULT 40000,
    hire_date  DATE,
    status     VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id      INTEGER,
    start_date   DATE,
    end_date     DATE,
    budget       INTEGER
);

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'Aigerim', 'Nurlanova', 'IT');

INSERT INTO employees (emp_id, first_name, last_name, department, salary, status)
VALUES (2, 'Bekzat', 'Serikov', 'HR', DEFAULT, DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, 1),
    ('HR', 80000, 2),
    ('Sales', 120000, 3);

INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date)
VALUES (3, 'Daulet', 'Ospanov', 'Sales', 50000 * 1.1, CURRENT_DATE);

INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES
    (4, 'Aliya',  'Zhaksybek', 'IT',    95000, '2018-03-14', 'Active'),
    (5, 'Yerlan', 'Tulegenov', 'IT',    62000, '2021-06-01', 'Active'),
    (6, 'Madina', 'Kairat',    'Sales', 45000, '2022-09-20', 'Active'),
    (7, 'Nurlan', 'Abenov',    NULL,    NULL,  '2023-05-10', 'Active'),
    (8, 'Saule',  'Bekova',    'HR',    72000, '2019-11-02', 'Inactive'),
    (9, 'Timur',  'Zhanibek',  'IT',    38000, '2023-02-15', 'Active');

CREATE TEMPORARY TABLE temp_employees AS
SELECT *
FROM employees
WHERE department = 'IT';

UPDATE employees
SET salary = salary * 1.10
WHERE salary IS NOT NULL;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END
WHERE salary IS NOT NULL;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = sub.avg_salary * 1.20
FROM (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees
    WHERE department IS NOT NULL
    GROUP BY department
) AS sub
WHERE d.dept_name = sub.department;

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


DELETE FROM employees
WHERE status = 'Terminated';


DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;


DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);


DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date)
VALUES (10, 'Ainur', 'Mukanova', NULL, NULL, '2024-01-15');


UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;


DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;


INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date)
VALUES (11, 'Zarina', 'Abdullina', 'IT', 55000, CURRENT_DATE)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;


UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;


DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date)
SELECT 12, 'Erlan', 'Sagyndykov', 'Sales', 48000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Erlan'
      AND last_name = 'Sagyndykov'
);

UPDATE employees e
SET salary = CASE
    WHEN (
        SELECT d.budget
        FROM departments d
        WHERE d.dept_name = e.department
    ) > 100000 THEN e.salary * 1.10
    ELSE e.salary * 1.05
END
WHERE e.department IN (SELECT dept_name FROM departments);

INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date)
VALUES
    (20, 'Anel',   'Baitursyn', 'IT',    50000, CURRENT_DATE),
    (21, 'Dias',   'Yermek',    'Sales', 47000, CURRENT_DATE),
    (22, 'Kamila', 'Sultan',    'HR',    52000, CURRENT_DATE),
    (23, 'Rustem', 'Aben',      'IT',    58000, CURRENT_DATE),
    (24, 'Zhanna', 'Orazbek',   'Sales', 46000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE emp_id IN (20, 21, 22, 23, 24);

CREATE TABLE employee_archive AS
TABLE employees
WITH NO DATA;

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';


UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      JOIN departments d ON d.dept_name = e.department
      WHERE d.dept_id = p.dept_id
  ) > 3;

-- results
SELECT * FROM departments;
SELECT * FROM employees;
SELECT * FROM projects;

SELECT * FROM temp_employees;
SELECT emp_id, first_name, last_name, salary FROM employees ORDER BY emp_id;
SELECT emp_id, salary, department FROM employees ORDER BY salary;
SELECT dept_name, budget FROM departments;

SELECT * FROM employees;
SELECT * FROM departments;

SELECT * FROM employee_archive;
SELECT project_id, project_name, end_date FROM projects;