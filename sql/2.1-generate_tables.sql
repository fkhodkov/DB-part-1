DROP TABLE if EXISTS external_account CASCADE;
CREATE TABLE external_account(
  login VARCHAR(100),
  email VARCHAR(254),
  password VARCHAR(60)
);

DROP TABLE if EXISTS external_employer CASCADE;
CREATE TABLE external_employer (
  title VARCHAR(100)
);

DROP TABLE if EXISTS external_employer_account CASCADE;
CREATE TABLE external_employer_account (
  employer_id INTEGER,
  account_id INTEGER
);

DROP TABLE if EXISTS external_city CASCADE;
CREATE TABLE external_city (
  NAME VARCHAR(100)
);

DROP TABLE if EXISTS external_vacancy CASCADE;
CREATE TABLE external_vacancy (
  employer_id INTEGER,
  title VARCHAR(100),
  city_id INTEGER,
  salary INT4RANGE,
  experience_years EXPERIENCE_YEARS_T,
  schedule SCHEDULE_T,
  description TEXT,
  vacancy_status VACANCY_STATUS_T
);

DROP TABLE if EXISTS external_applicant CASCADE;
CREATE TABLE external_applicant (
  name VARCHAR(100),
  account_id INTEGER
);

DROP TABLE if EXISTS external_resume CASCADE;
CREATE TABLE external_resume (
  applicant_id INTEGER,
  title VARCHAR(100),
  city_id INTEGER,
  salary INT4RANGE,
  experience_years EXPERIENCE_YEARS_T,
  schedule SCHEDULE_T,
  text TEXT,
  CHECK (experience_years != 'ANY')
);

DROP TABLE if EXISTS external_experience CASCADE;
CREATE TABLE external_experience (
  resume_id INTEGER,
  employer VARCHAR(100),
  job_title VARCHAR(100),
  job_description TEXT,
  dates DATERANGE
);

DROP TABLE if EXISTS external_application CASCADE;
CREATE TABLE external_application (
  resume_id INTEGER,
  vacancy_id INTEGER,
  application_status APPLICATION_STATUS_T
);

DROP TABLE if EXISTS external_message CASCADE;
CREATE TABLE external_message (
  application_id INTEGER,
  created TIMESTAMP,
  applicant_to_employer BOOLEAN,
  text TEXT
);
