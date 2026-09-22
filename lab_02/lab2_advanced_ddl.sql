-- Laboratory work 2 - Advanced DDL Operations

-- part 1 - Multiple Database Management

-- task 1.1 Database creation with parameters


CREATE DATABASE university_main
    OWNER = altynbekamankozha
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_archive
    TEMPLATE = template0
    CONNECTION LIMIT = 50;

CREATE DATABASE university_test
    IS_TEMPLATE = true
    CONNECTION LIMIT = 10;

-- task 1.2 Tablespace Operations

CREATE TABLESPACE student_data LOCATION '/Users/altynbekamankozha/lab2_data/students';

CREATE TABLESPACE course_data
    OWNER altynbekamankozha
    LOCATION '/Users/altynbekamankozha/lab2_data/courses';

CREATE DATABASE university_distributed
    TEMPLATE = template0
    TABLESPACE = student_data
    ENCODING = 'LATIN9'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C';

-- part 2 - Complex Table Creation

-- task 2.1 University Management System

CREATE TABLE students (
    student_id       SERIAL PRIMARY KEY,
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    email            VARCHAR(100),
    phone            CHAR(15),
    date_of_birth    DATE,
    enrollment_date  DATE,
    gpa              NUMERIC(3,2),
    is_active        BOOLEAN,
    graduation_year  SMALLINT
);

CREATE TABLE professors (
    professor_id      SERIAL PRIMARY KEY,
    first_name        VARCHAR(50),
    last_name         VARCHAR(50),
    email              VARCHAR(100),
    office_number      VARCHAR(20),
    hire_date          DATE,
    salary             NUMERIC(12,2),
    is_tenured         BOOLEAN,
    years_experience   INTEGER
);

CREATE TABLE courses (
    course_id       SERIAL PRIMARY KEY,
    course_code     CHAR(8),
    course_title    VARCHAR(100),
    description     TEXT,
    credits         SMALLINT,
    max_enrollment  INTEGER,
    course_fee      NUMERIC(8,2),
    is_online       BOOLEAN,
    created_at      TIMESTAMP
);

-- task 2.2 Time based and Specialized Tables

CREATE TABLE class_schedule (
    schedule_id    SERIAL PRIMARY KEY,
    course_id      INTEGER,
    professor_id   INTEGER,
    classroom      VARCHAR(20),
    class_date     DATE,
    start_time     TIME,
    end_time       TIME,
    duration       INTERVAL
);

CREATE TABLE student_records (
    record_id               SERIAL PRIMARY KEY,
    student_id               INTEGER,
    course_id                 INTEGER,
    semester                  VARCHAR(20),
    year                       INTEGER,
    grade                     CHAR(2),
    attendance_percentage     NUMERIC(4,1),
    submission_timestamp      TIMESTAMPTZ,
    last_updated              TIMESTAMPTZ
);

-- part 3 - Advanced ALTER TABLE Operations

-- task 3.1 Modifying Existing Tables

-- students table
ALTER TABLE students ADD COLUMN middle_name VARCHAR(30);

ALTER TABLE students ADD COLUMN student_status VARCHAR(20);

ALTER TABLE students ALTER COLUMN phone TYPE VARCHAR(20);

ALTER TABLE students ALTER COLUMN student_status SET DEFAULT 'ACTIVE';

ALTER TABLE students ALTER COLUMN gpa SET DEFAULT 0.00;

-- professors table
ALTER TABLE professors ADD COLUMN department_code CHAR(5);

ALTER TABLE professors ADD COLUMN research_area TEXT;

ALTER TABLE professors ALTER COLUMN years_experience TYPE SMALLINT;

ALTER TABLE professors ALTER COLUMN is_tenured SET DEFAULT false;

ALTER TABLE professors ADD COLUMN last_promotion_date DATE;

-- courses table
ALTER TABLE courses ADD COLUMN prerequisite_course_id INTEGER;

ALTER TABLE courses ADD COLUMN difficulty_level SMALLINT;

ALTER TABLE courses ALTER COLUMN course_code TYPE VARCHAR(10);

ALTER TABLE courses ALTER COLUMN credits SET DEFAULT 3;

ALTER TABLE courses ADD COLUMN lab_required BOOLEAN DEFAULT false;

-- task 3.2 column management operations

-- class_schedule table
ALTER TABLE class_schedule ADD COLUMN room_capacity INTEGER;

ALTER TABLE class_schedule DROP COLUMN duration;

ALTER TABLE class_schedule ADD COLUMN session_type VARCHAR(15);

ALTER TABLE class_schedule ALTER COLUMN classroom TYPE VARCHAR(30);

ALTER TABLE class_schedule ADD COLUMN equipment_needed TEXT;

-- student_records table
ALTER TABLE student_records ADD COLUMN extra_credit_points NUMERIC(3,1);

ALTER TABLE student_records ALTER COLUMN grade TYPE VARCHAR(5);

ALTER TABLE student_records ALTER COLUMN extra_credit_points SET DEFAULT 0.0;

ALTER TABLE student_records ADD COLUMN final_exam_date DATE;

ALTER TABLE student_records DROP COLUMN last_updated;

-- part 4 - Table Relationships and Management

-- task 4.1 Additional Supporting Tables
CREATE TABLE departments (
    department_id      SERIAL PRIMARY KEY,
    department_name    VARCHAR(100),
    department_code    CHAR(5),
    building             VARCHAR(50),
    phone                VARCHAR(15),
    budget               NUMERIC(14,2),
    established_year     INTEGER
);

CREATE TABLE library_books (
    book_id                 SERIAL PRIMARY KEY,
    isbn                     CHAR(13),
    title                    VARCHAR(200),
    author                   VARCHAR(100),
    publisher                VARCHAR(100),
    publication_date         DATE,
    price                    NUMERIC(8,2),
    is_available             BOOLEAN,
    acquisition_timestamp    TIMESTAMP
);

CREATE TABLE student_book_loans (
    loan_id       SERIAL PRIMARY KEY,
    student_id    INTEGER,
    book_id       INTEGER,
    loan_date     DATE,
    due_date      DATE,
    return_date   DATE,
    fine_amount   NUMERIC(6,2),
    loan_status   VARCHAR(20)
);

-- task 4.2 Table Modifications for Integration

-- 1)
ALTER TABLE professors ADD COLUMN department_id INTEGER;

ALTER TABLE students ADD COLUMN advisor_id INTEGER;

ALTER TABLE courses ADD COLUMN department_id INTEGER;

-- 2)
CREATE TABLE grade_scale (
    grade_id         SERIAL PRIMARY KEY,
    letter_grade     CHAR(2),
    min_percentage   NUMERIC(4,1),
    max_percentage   NUMERIC(4,1),
    gpa_points       NUMERIC(3,2)
);

CREATE TABLE semester_calendar (
    semester_id              SERIAL PRIMARY KEY,
    semester_name            VARCHAR(20),
    academic_year            INTEGER,
    start_date               DATE,
    end_date                 DATE,
    registration_deadline    TIMESTAMPTZ,
    is_current                BOOLEAN
);

-- Part 5 - Table Deletion and Cleanup

-- task 5.1 Conditional Table Operations

-- 1)
DROP TABLE IF EXISTS student_book_loans;

DROP TABLE IF EXISTS library_books;

DROP TABLE IF EXISTS grade_scale;

-- 2)
CREATE TABLE grade_scale (
    grade_id         SERIAL PRIMARY KEY,
    letter_grade     CHAR(2),
    min_percentage   NUMERIC(4,1),
    max_percentage   NUMERIC(4,1),
    gpa_points       NUMERIC(3,2),
    description      TEXT
);

-- 3)
DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id              SERIAL PRIMARY KEY,
    semester_name            VARCHAR(20),
    academic_year            INTEGER,
    start_date               DATE,
    end_date                 DATE,
    registration_deadline    TIMESTAMPTZ,
    is_current                BOOLEAN
);

-- task 5.2 Database Cleanup

ALTER DATABASE university_test WITH IS_TEMPLATE false;

DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;


CREATE DATABASE university_backup TEMPLATE university_main;

