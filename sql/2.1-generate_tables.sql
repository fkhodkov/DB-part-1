DROP TABLE if EXISTS external_account CASCADE;
CREATE TABLE external_account (
  external_account_id SERIAL,
  login VARCHAR(100),
  email VARCHAR(254),
  password VARCHAR(60)
);

DROP TABLE if EXISTS external_employer CASCADE;
CREATE TABLE external_employer (
  external_employer_id SERIAL,
  title VARCHAR(100)
);

DROP TABLE if EXISTS external_employer_account CASCADE;
CREATE TABLE external_employer_account (
  external_employer_account_id SERIAL,
  external_employer_id INTEGER,
  external_account_id INTEGER
);

DROP TABLE if EXISTS external_city CASCADE;
CREATE TABLE external_city (
  external_city_id SERIAL,
  NAME VARCHAR(100)
);

DROP TABLE if EXISTS external_vacancy CASCADE;
CREATE TABLE external_vacancy (
  external_vacancy_id SERIAL,
  external_employer_id INTEGER,
  title VARCHAR(100),
  external_city_id INTEGER,
  salary INT4RANGE,
  experience_years EXPERIENCE_YEARS_T,
  schedule SCHEDULE_T,
  description TEXT,
  vacancy_status VACANCY_STATUS_T
);

DROP TABLE if EXISTS external_applicant CASCADE;
CREATE TABLE external_applicant (
  external_applicant_id SERIAL,
  name VARCHAR(100),
  external_account_id INTEGER
);

DROP TABLE if EXISTS external_resume CASCADE;
CREATE TABLE external_resume (
  external_resume_id SERIAL,
  external_applicant_id INTEGER,
  title VARCHAR(100),
  external_city_id INTEGER,
  salary INT4RANGE,
  experience_years EXPERIENCE_YEARS_T,
  schedule SCHEDULE_T,
  text TEXT,
  CHECK (experience_years != 'ANY')
);

DROP TABLE if EXISTS external_experience CASCADE;
CREATE TABLE external_experience (
  external_experience_id SERIAL,
  external_resume_id INTEGER,
  employer VARCHAR(100),
  job_title VARCHAR(100),
  job_description TEXT,
  dates DATERANGE
);

DROP TABLE if EXISTS external_application CASCADE;
CREATE TABLE external_application (
  external_application_id SERIAL,
  external_resume_id INTEGER,
  external_vacancy_id INTEGER,
  application_status APPLICATION_STATUS_T
);

DROP TABLE if EXISTS external_message CASCADE;
CREATE TABLE external_message (
  external_message_id SERIAL,
  external_application_id INTEGER,
  created TIMESTAMP,
  applicant_to_employer BOOLEAN,
  text TEXT
);
