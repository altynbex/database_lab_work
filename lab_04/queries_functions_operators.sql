
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS projects;
DROP TABLE if EXISTS assignments;


-- Create tables
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary NUMERIC(10,2),
    hire_date DATE,
    manager_id INTEGER,
    email VARCHAR(100)
);
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    budget NUMERIC(12,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);
CREATE TABLE assignments (
    assignment_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    project_id INTEGER REFERENCES projects(project_id),
    hours_worked NUMERIC(5,1),
    assignment_date DATE
);
-- Insert sample data
INSERT INTO employees (first_name, last_name, department, salary, hire_date, manager_id, email) VALUES
    ('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,'john.smith@company.com'),
    ('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,'sarah.j@company.com'),
    ('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,'mbrown@company.com'),
    ('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,'emily.davis@company.com'),
    ('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
    ('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date, end_date, status) VALUES
    ('Website Redesign', 150000, '2024-01-01', '2024-06-30', 'Active'),
    ('CRM Implementation', 200000, '2024-02-15', '2024-12-31', 'Active'),
    ('Marketing Campaign', 80000, '2024-03-01', '2024-05-31','Completed'),
    ('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id, hours_worked, assignment_date) VALUES
    (1, 1, 120.5, '2024-01-15'),
    (2, 1, 95.0, '2024-01-20'),
    (1, 4, 80.0, '2024-02-01'),
    (3, 3, 60.0, '2024-03-05'),
    (5, 2, 110.0, '2024-02-20'),
    (6, 3, 75.5, '2024-03-10');

--Task 1.1

select (employees.first_name, employees.last_name) as full_name, employees.department, employees.salary from employees;

--Task 1.2

select distinct department from employees;

--Task 1.3

select projects.project_name,
       projects.budget,
       CASE
       when projects.budget > 150000 then 'Large'
       when projects.budget between 100000 and 150000 then 'Medium'
       ELSE 'Small'
       END as budget_category
from projects;

--Task 1.4

select (employees.first_name, employees.last_name) as names,
       coalesce(employees.email, 'no email provided') as email from employees;

--Task 2.1

select * from employees where hire_date > '2020.01.01';

--Task 2.2

select * from employees where salary between 60000 and 70000;

--Task 2.3

select * from employees where last_name like 'S%' or  last_name like 'J%';

--Task 2.4

select * from employees where manager_id is not null and department = 'IT';

--Task 3.1

select
    (upper(employees.first_name), upper(employees.last_name)) as names,
    length(employees.last_name) as length_last_name,
    substring(employees.email from 1 for 3) as email_first_3
from employees;

--Task 3.2

select (first_name, last_name) as names,
       employees.salary * 12 as annual_salary,
       round(employees.salary, 2) as monthly_salary,
       employees.salary * 0.10 as raise_amount
from employees;

--Task 3.3

select format(
       'Project: %s - Budget: %s - Status: %s',
       project_name,
       budget,
       status
       ) as project_info from projects;

--Task 3.4

select (employees.first_name, employees.last_name) as names,
       extract(year from age(current_date, employees.hire_date)) as years_with_company
from employees;

--Task 4.1

select department, avg(employees.salary) as average_salary from employees group by employees.department;

--Task 4.2

select projects.project_name, sum(assignments.hours_worked) from assignments join projects
    on projects.project_id = assignments.project_id group by projects.project_name;

--Task 4.3

select department, count(*) as employee_count
from employees
group by department
having count(*) > 1;

--Task 4.4

select max(salary) as max_salary,
       min(salary) as min_salary,
       sum(salary) as total_payroll
from employees;

--Task 5.1

select employee_id, first_name || ' ' || last_name as full_name, salary
from employees
where salary > 65000

union

select employee_id, first_name || ' ' || last_name as full_name, salary
from employees
where hire_date > '2020-01-01';

--Task 5.2

select employee_id
from employees
where department = 'IT'

intersect

select employee_id
from employees
where salary > 65000;

--Task 5.3
select employee_id
from employees

except

select employee_id
from assignments;

--Task 6.1

select employees.employee_id, employees.first_name, employees.last_name
from employees
where exists (
    select 1
    from assignments
    where assignments.employee_id = employees.employee_id
);

--Task 6.2

select employee_id, first_name, last_name
from employees
where employee_id in (
    select assignments.employee_id
    from assignments
    join projects
        on projects.project_id = assignments.project_id
    where projects.status = 'Active'
);

--Task 6.3

select employee_id, first_name, last_name, salary
from employees
where salary > any (
    select salary
    from employees
    where department = 'Sales'
);

--Task 7.1

select employees.first_name || ' ' || employees.last_name as employee_name,
       employees.department,
       avg(assignments.hours_worked) as average_hours,
       rank() over (
           partition by employees.department
           order by employees.salary desc
       ) as salary_rank
from employees
left join assignments
    on employees.employee_id = assignments.employee_id
group by employees.employee_id, employees.first_name,
         employees.last_name, employees.department, employees.salary;

--Task 7.2

select projects.project_name,
       sum(assignments.hours_worked) as total_hours,
       count(distinct assignments.employee_id) as number_of_employees
from projects
join assignments
    on projects.project_id = assignments.project_id
group by projects.project_name
having sum(assignments.hours_worked) > 150;

--Task 7.3

select department,
       count(*) as total_employees,
       avg(salary) as average_salary,
       (array_agg(first_name || ' ' || last_name order by salary desc))[1] as highest_paid_employee,
       greatest(max(salary), min(salary)) as greatest_salary,
       least(max(salary), min(salary)) as least_salary
from employees
group by department;



