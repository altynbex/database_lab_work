-- Database constraints - laboratory work 5
-- Amankozha Altynbek
-- student id: 25B031124

-- task 1.1
create table employees (
    employee_id integer,
    first_name text,
    last_name text,
    age integer check(age between 18 and 65),
    salary numeric check(salary > 0)
);
-- check ensures age is between 18 and 65
-- check ensures salary is greater than 0

-- task 1.2
create table products_catalog (
    product_id integer,
    product_name text,
    regular_price numeric,
    discount_price numeric,
    constraint valid_discount check(
        regular_price > 0 and
        discount_price > 0 and
        discount_price < regular_price
    )
);
-- named check ensures both prices are positive
-- discount_price must be less than regular_price


-- task 1.3
create table bookings (
    booking_id integer,
    check_in_date date,
    check_out_date date,
    num_guests integer,
    constraint valid_guests check(num_guests between 1 and 10),
    constraint valid_dates check(check_out_date > check_in_date)
);
-- num_guests must be between 1 and 10
-- check_out_date must be after check_in_date


-- task 1.4

-- valid
insert into employees values
(1, 'altynbek', 'amankozha', 18, 150000),
(2, 'abil', 'amankozha', 22, 350000);

-- invalid: age is below 18
insert into employees values(3, 'askar', 'amankozha', 13, 120000);

-- invalid: salary must be greater than 0
insert into employees values(4, 'sara', 'amankozha', 25, 0);

-- result: 2 valid rows inserted
-- both invalid inserts are expected to fail

-- task 2.1
create table customers (
    customer_id integer not null,
    email text not null,
    phone text,
    registration_date date not null
);
-- not null means customer_id, email and registration_date
-- cannot contain null values

-- task 2.2
create table inventory (
    item_id integer not null,
    item_name text not null,
    quantity integer not null check(quantity >= 0),
    unit_price numeric not null check(unit_price > 0),
    last_updated timestamp not null
);
-- quantity must be >= 0
-- unit_price must be > 0
-- all columns except no columns: every column is not null
-- task 2.3

-- valid
insert into customers values
(1, 'altynbek11@gmail.com', '77767807726', '2026-10-12');

insert into inventory values
(1, 'laptop', 10, 250000, '2026-10-12 12:02:10');

-- invalid: email cannot be null
insert into customers values(2, null, '87007654321', '2026-10-12');

-- invalid: item_name cannot be null
insert into inventory values(2, null, 5, 1000, '2026-10-12 12:00:00');

-- invalid: quantity cannot be negative
insert into inventory values(3, 'mouse', -5, 5000, current_timestamp);

-- invalid: unit_price must be greater than 0
insert into inventory values(4, 'keyboard', 5, 0, current_timestamp);

-- valid: phone is nullable
insert into customers values(3, 'abil234@gmail.com', null, '2026-10-12');

-- result: null phone is accepted
-- not null and check violations are expected to fail


-- task 3.1
create table users (
    user_id integer,
    username text unique,
    email text unique,
    created_at timestamp
);
-- unique prevents duplicate usernames and emails

-- task 3.2
create table course_enrollments (
    enrollment_id integer,
    student_id integer,
    course_code text,
    semester text,
    constraint unique_enrollments
        unique(student_id, course_code, semester)
);
-- the combination of student_id, course_code and semester
-- must be unique

-- valid
insert into course_enrollments values
(1, 101, 'csci2104', 'fall 2026'),
(2, 101, 'csci2105', 'fall 2026'),
(3, 102, 'csci2104', 'fall 2026');

-- invalid: duplicate combination
insert into course_enrollments values(4, 101, 'csci2104', 'fall 2026');

-- task 3.3
alter table users
drop constraint users_username_key;

alter table users
drop constraint users_email_key;

alter table users
add constraint unique_username unique(username);

alter table users
add constraint unique_email unique(email);

-- replace automatically named unique constraints with named constraints

-- valid
insert into users values
(1, 'altynbek', 'altynbek@gmail.com', current_timestamp),
(2, 'abil', 'abil@gmail.com', current_timestamp);

-- invalid: duplicate username
insert into users values(3, 'altynbek', 'new@gmail.com', current_timestamp);

-- invalid: duplicate email
insert into users values(4, 'askar', 'altynbek@gmail.com', current_timestamp);

-- result: duplicate username and email are rejected


-- task 4.1

create table departments (
    dept_id integer primary key,
    dept_name text not null,
    location text
);
-- primary key uniquely identifies every department
-- primary key cannot be null

insert into departments values
(1, 'it', 'almaty'),
(2, 'hr', 'astana'),
(3, 'finance', 'shymkent');

-- invalid: duplicate primary key
insert into departments values (1, 'marketing', 'almaty');

-- invalid: null primary key
insert into departments values (null, 'sales', 'astana');

-- task 4.2
create table student_courses (
    student_id integer,
    course_id integer,
    enrollment_date date,
    grade text,
    primary key(student_id, course_id)
);
-- composite primary key uniquely identifies a student-course pair

insert into student_courses values
(101, 1, '2026-09-01', 'a'),
(101, 2, '2026-09-01', 'b'),
(102, 1, '2026-09-02', 'a');

-- invalid: duplicate combination
insert into student_courses values(101, 1, '2026-09-05', 'c');

-- task 4.3
-- primary key uniquely identifies each row and cannot be null
-- a table can have only one primary key
-- unique prevents duplicate values but can allow null values
-- a table can have multiple unique constraints
-- single-column primary key identifies a row using one column
-- composite primary key identifies a row using multiple columns

-- task 5.1
create table employees_dept (
    emp_id integer primary key,
    emp_name text not null,
    dept_id integer references departments(dept_id),
    hire_date date
);
-- foreign key requires dept_id to exist in departments

insert into employees_dept values
(1, 'altynbek', 1, '2026-09-01'),
(2, 'abil', 2, '2026-09-02');

-- invalid: department 99 does not exist
insert into employees_dept values(3, 'askar', 99, '2026-09-03');

-- result: valid department references are accepted
-- invalid department reference is rejected


-- task 5.2
create table authors (
    author_id integer primary key,
    author_name text not null,
    country text
);

create table publishers (
    publisher_id integer primary key,
    publisher_name text not null,
    city text
);

create table books (
    book_id integer primary key,
    title text not null,
    author_id integer references authors(author_id),
    publisher_id integer references publishers(publisher_id),
    publication_year integer,
    isbn text unique
);
-- books contains foreign keys to authors and publishers
-- isbn must be unique

insert into authors values
(1, 'abdurakhman', 'kazakhstan'),
(2, 'mukhtar auyezov', 'kazakhstan'),
(3, 'j.k. rowling', 'united kingdom'),
(4, 'george orwell', 'united kingdom'),
(5, 'paulo coelho', 'brazil');

insert into publishers values
(1, 'kitap', 'almaty'),
(2, 'atamura', 'almaty'),
(3, 'bloomsbury', 'london'),
(4, 'penguin books', 'london'),
(5, 'harpercollins', 'new york');

insert into books values
(1, 'first book', 1, 1, 2020, '9780000000001'),
(2, 'abai zholy', 2, 2, 1942, '9780000000002'),
(3, 'harry potter', 3, 3, 1997, '9780000000003'),
(4, '1984', 4, 4, 1949, '9780000000004'),
(5, 'the alchemist', 5, 5, 1988, '9780000000005');

-- invalid: author_id 99 does not exist
insert into books values(6, 'unknown book', 99, 1, 2026, '9780000000006');

-- invalid: duplicate isbn
insert into books values(6, 'another book', 1, 1, 2026, '9780000000001');

-- result: five records inserted into each library table


-- task 5.3
create table categories (
    category_id integer primary key,
    category_name text not null
);

create table products_fk (
    product_id integer primary key,
    product_name text not null,
    category_id integer references categories(category_id)
        on delete restrict
);

create table orders (
    order_id integer primary key,
    order_date date not null
);

create table order_items (
    item_id integer primary key,
    order_id integer references orders(order_id)
        on delete cascade,
    product_id integer references products_fk(product_id),
    quantity integer check(quantity > 0)
);
-- restrict prevents deleting a category that has products
-- cascade deletes order_items when the referenced order is deleted
insert into categories values
(1, 'electronics'),
(2, 'books');

insert into products_fk values
(1, 'laptop', 1),
(2, 'book', 2);

insert into orders values
(1, '2026-10-12'),
(2, '2026-10-12');

insert into order_items values
(1, 1, 1, 2),
(2, 1, 2, 1),
(3, 2, 1, 1);

-- test 1: expected to fail because products reference category 1
-- delete from categories where category_id = 1;

-- result: delete is rejected by on delete restrict

-- test 2: delete order 1
delete from orders where order_id = 1;

-- test 3: check remaining items
select * from order_items;

-- result: item_id 1 and 2 are deleted automatically
-- item_id 3 remains because it belongs to order 2


-- remove task 5.3 tables before reusing the orders name
drop table order_items;
drop table products_fk;
drop table categories;
drop table orders;


-- task 6.1

create table customers (
    customer_id integer primary key,
    name text not null,
    email text not null unique,
    phone text,
    registration_date date not null
);

create table products (
    product_id integer primary key,
    name text not null,
    description text,
    price numeric not null check(price >= 0),
    stock_quantity integer not null check(stock_quantity >= 0)
);

create table orders (
    order_id integer primary key,
    customer_id integer not null references customers(customer_id)
        on delete restrict,
    order_date date not null,
    total_amount numeric not null check(total_amount >= 0),
    status text not null check(status in (
        'pending',
        'processing',
        'shipped',
        'delivered',
        'cancelled'
    ))
);

create table order_details (
    order_detail_id integer primary key,
    order_id integer not null references orders(order_id)
        on delete cascade,
    product_id integer not null references products(product_id)
        on delete restrict,
    quantity integer not null check(quantity > 0),
    unit_price numeric not null check(unit_price >= 0)
);

-- customers
insert into customers values
(1, 'altynbek', 'altynbek@gmail.com', '87776780726', '2026-09-01'),
(2, 'abil', 'abil@gmail.com', '87007654321', '2026-09-02'),
(3, 'askar', 'askar@gmail.com', '87001112233', '2026-09-03'),
(4, 'sara', 'sara@gmail.com', '87004445566', '2026-09-04'),
(5, 'dana', 'dana@gmail.com', null, '2026-09-05');

-- products
insert into products values
(1, 'laptop', 'gaming laptop', 350000, 10),
(2, 'mouse', 'wireless mouse', 5000, 50),
(3, 'keyboard', 'mechanical keyboard', 15000, 25),
(4, 'monitor', '27 inch monitor', 90000, 15),
(5, 'headphones', 'wireless headphones', 25000, 30);

-- orders
insert into orders values
(1, 1, '2026-10-01', 360000, 'pending'),
(2, 2, '2026-10-02', 15000, 'processing'),
(3, 3, '2026-10-03', 90000, 'shipped'),
(4, 4, '2026-10-04', 25000, 'delivered'),
(5, 5, '2026-10-05', 0, 'cancelled');

-- order_details
insert into order_details values
(1, 1, 1, 1, 350000),
(2, 1, 2, 2, 5000),
(3, 2, 3, 1, 15000),
(4, 3, 4, 1, 90000),
(5, 4, 5, 1, 25000);

-- test 1: duplicate email, expected to fail
insert into customers values(6, 'test', 'altynbek@gmail.com', null, '2026-10-12');

-- test 2: negative price, expected to fail
insert into products values(6, 'tablet', 'new tablet', -1000, 5);

-- test 3: negative stock, expected to fail
insert into products values(7, 'phone', 'new phone', 100000, -5);

-- test 4: invalid status, expected to fail
insert into orders values(6, 1, '2026-10-12', 1000, 'waiting');

-- test 5: quantity must be positive, expected to fail
insert into order_details values(6, 1, 2, 0, 5000);

-- test 6: customer does not exist, expected to fail
insert into orders values(7, 99, '2026-10-12', 1000, 'pending');

-- test 7: show orders with customer names
select
    orders.order_id,
    customers.name,
    orders.total_amount,
    orders.status
from orders
join customers
    on orders.customer_id = customers.customer_id;

-- test 8: show order details
select
    order_details.order_id,
    products.name,
    order_details.quantity,
    order_details.unit_price
from order_details
join products
    on order_details.product_id = products.product_id;

-- final results:
-- all valid inserts should succeed
-- uncommented invalid test statements should fail
-- task 5.3 cascade test should leave only item_id 3
-- task 6.1 creates four tables with five sample rows each