DROP TABLE IF EXISTS employer CASCADE;
DROP TABLE IF EXISTS vacancy CASCADE;
DROP TABLE IF EXISTS applicant CASCADE;
DROP TABLE IF EXISTS resume CASCADE;
DROP TABLE IF EXISTS application CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TABLE IF EXISTS experience_years_translation CASCADE;
DROP TABLE IF EXISTS city CASCADE;
DROP TABLE if EXISTS experience CASCADE;
DROP TABLE if EXISTS account CASCADE;
DROP TABLE if EXISTS employer_account CASCADE;
DROP TYPE IF EXISTS SCHEDULE_T CASCADE;
DROP TYPE IF EXISTS APPLICATION_STATUS_T CASCADE;
DROP TYPE IF EXISTS VACANCY_STATUS_T CASCADE;

CREATE TABLE account (
  account_id SERIAL PRIMARY KEY,
  login VARCHAR(100) NOT NULL,
  email VARCHAR(254) NOT NULL,
  password VARCHAR(60) NOT NULL
);

CREATE TABLE employer (
  employer_id SERIAL PRIMARY KEY,
  title VARCHAR(100) NOT NULL
);

CREATE TABLE employer_account (
  employer_id INTEGER REFERENCES employer,
  account_id INTEGER REFERENCES account,
  PRIMARY KEY (employer_id, account_id)
);

CREATE TYPE SCHEDULE_T AS ENUM (
  'FULL_TIME',
  'PART_TIME',
  'FLEXIBLE',
  'REMOTE'
);

CREATE TABLE experience_years_translation (
  experience_years_key VARCHAR(16) PRIMARY KEY,
  experience_years_value INT4RANGE
);

INSERT INTO experience_years_translation
VALUES
  ('0-1', INT4RANGE(0, 1, '[]')),
  ('1-3', INT4RANGE(1, 3, '[]')),
  ('3-6', INT4RANGE(3, 6, '[]')),
  ('6+', INT4RANGE(6, NULL)),
  ('ANY', INT4RANGE(NULL, NULL))
;

CREATE TABLE city (
  city_id SERIAL PRIMARY KEY,
  NAME VARCHAR(100)
);

CREATE TYPE VACANCY_STATUS_T AS ENUM (
  'OPEN',
  'CLOSED'
);

CREATE TABLE vacancy (
  vacancy_id SERIAL PRIMARY KEY,
  employer_id INTEGER REFERENCES employer NOT NULL,
  title VARCHAR(100) NOT NULL,
  city_id INTEGER REFERENCES city NOT NULL,
  salary INT4RANGE,
  experience_years_key VARCHAR(16) REFERENCES experience_years_translation NOT NULL,
  schedule SCHEDULE_T,
  description TEXT,
  vacancy_status VACANCY_STATUS_T NOT NULL
);

CREATE TABLE applicant (
  applicant_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  account_id INTEGER REFERENCES account
);

CREATE TABLE resume (
  resume_id SERIAL PRIMARY KEY,
  applicant_id INTEGER REFERENCES applicant NOT NULL,
  title VARCHAR(100) NOT NULL,
  city_id INTEGER REFERENCES city NOT NULL,
  salary INT4RANGE,
  experience_years_key VARCHAR(16) REFERENCES experience_years_translation NOT NULL,
  schedule SCHEDULE_T,
  text TEXT
);

CREATE TABLE experience (
  experience_id SERIAL PRIMARY KEY,
  resume_id INTEGER REFERENCES resume NOT NULL,
  employer VARCHAR(100) NOT NULL,
  job_title VARCHAR(100) NOT NULL,
  job_description TEXT,
  dates DATERANGE NOT NULL
);

CREATE TYPE APPLICATION_STATUS_T AS ENUM (
  'NOT_RESPONDED',
  'RESPONDED',
  'INTERVIEW_INVITED',
  'REJECTED',
  'WITHDRAWN',
  'ACCEPTED'
);

CREATE TABLE application (
  application_id SERIAL PRIMARY KEY,
  resume_id INTEGER REFERENCES resume NOT NULL,
  vacancy_id INTEGER REFERENCES vacancy NOT NULL,
  application_status  APPLICATION_STATUS_T NOT NULL
);

CREATE TABLE message (
  message_id SERIAL PRIMARY KEY,
  application_id INTEGER REFERENCES application NOT NULL,
  created TIMESTAMP NOT NULL,
  applicant_to_employer BOOLEAN NOT NULL,
  text TEXT
);
