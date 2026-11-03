drop table if exists employees;
drop table if exists departments;
drop table if exists projects cascade;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
    (101, 'IT', 'Building A'),
    (102, 'HR', 'Building B'),
    (103, 'Finance', 'Building C'),
    (104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
    (1, 'Website Redesign', 101, 100000),
    (2, 'Employee Training', 102, 50000),
    (3, 'Budget Analysis', 103, 75000),
    (4, 'Cloud Migration', 101, 150000),
    (5, 'AI Research', NULL, 200000);

-- part 2 cross join

-- ex 2.1
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
-- answer: 5 emp x 4 dep = 20 rows

-- ex 2.2
-- a)
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;
-- b)
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;

-- ex 2.3
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p;
-- 5x5 = 25 rows

-- part 3 inner join

-- ex 3.1

SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- answer: 4 rows

--ex 3.2

SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- answer: with these selected columns the output is the same. The difference
-- shows with SELECT *: USING returns the dept_id column once (merged),
-- while ON returns it twice (e.dept_id and d.dept_id)

-- ex 3.3

SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
-- joins automatically on the only common column name: dept_id

--ex 3.4
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;
-- 6 rows John and Mike x 2 IT projects (4), Jane x 1, Sarah x 1

-- part 4 left join

-- ex 4.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Answer: Tom Brown appears with NULL in emp_dept, dept_dept and dept_name.

-- ex 4.2
SELECT emp_name, dept_id, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);

-- ex 4.3
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
-- Result: Tom Brown

-- ex 4.4
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;
-- IT = 2, HR = 1, Finance = 1, Marketing = 0
-- COUNT(e.emp_id) is used instead of COUNT(*) so Marketing gets 0, not 1.

-- part 5 right join

-- ex 5.1
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- ex 5.2
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- ex 5.3
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;
-- Result: Marketing (Building D)

-- part 6 full join

-- ex 6.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
-- Answer: NULLs on the LEFT side (employee columns): Marketing department.
--         NULLs on the RIGHT side (department columns): Tom Brown.

-- ex 6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;
-- Marketing has no project (NULL project); AI Research has no department (NULL dept)

-- ex 6.3
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

-- part 7 ON vs WHERE left

-- ex 7.1
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
-- 5 rows: all employees; only John and Mike get dept_name 'IT', others NULL

-- ex 7.2
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- ex 7.3
-- ON version
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
-- WHERE version
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- part 8 complex join scenarios

-- ex 8.1
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- ex 8.2
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;


-- ex 8.3
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;
-- IT (52500), HR (60000), Finance (65000)

-- lab questions (answers)

-- 1. INNER JOIN returns only rows that have a match in both tables.
--    LEFT JOIN returns all rows from the left table plus matching rows from
--    the right table (NULLs where there is no match).

-- 2. CROSS JOIN is useful for generating all combinations: e.g. a schedule or
--    availability matrix (employees x projects), sizes x colors for a product
--    catalog, or a calendar of dates x time slots.

-- 3. In an outer join, rows without a match are kept and filled with NULLs.
--    A condition in ON only affects matching, so those rows survive. A
--    condition in WHERE filters the final result and removes the NULL-filled
--    rows. In an inner join there are no such rows, so ON and WHERE give the
--    same result.

-- 4. 5 x 10 = 50 rows, so COUNT(*) returns 50.

-- 5. NATURAL JOIN automatically joins on all columns that have the same name
--    in both tables, and outputs each of those columns once.

-- 6. Risks: it can silently join on unintended columns that happen to share
--    a name; if a column is added or renamed later, the join changes without
--    any change to the query; if there are no common columns it becomes a
--    CROSS JOIN; the join condition is not visible, so it is harder to read.

-- 7. LEFT JOIN converted to RIGHT JOIN (reverse the table order):
-- SELECT * FROM B RIGHT JOIN A ON A.id = B.id;

-- 8. Use FULL OUTER JOIN when you need all rows from both tables, matched
--    where possible, e.g. comparing two datasets, finding orphaned or
--    mismatched records on both sides, or data reconciliation/auditing.


-- additional challenges (optional)

-- challenge 1
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- challenge 2
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IN (
    SELECT dept_id
    FROM projects
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
    HAVING COUNT(*) > 1
);
-- Result: John Smith and Mike Johnson (IT has 2 projects)

-- challenge 3
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager,
    mm.emp_name AS managers_manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
LEFT JOIN employees mm ON m.manager_id = mm.emp_id;

-- challenge 4
SELECT
    e1.emp_name AS employee1,
    e2.emp_name AS employee2,
    e1.dept_id
FROM employees e1
INNER JOIN employees e2
    ON e1.dept_id = e2.dept_id
   AND e1.emp_id < e2.emp_id;
-- Result: John Smith - Mike Johnson (both in dept 101)

