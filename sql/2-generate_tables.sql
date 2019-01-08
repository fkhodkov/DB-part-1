DROP TABLE if EXISTS external_account CASCADE;
CREATE TABLE external_account(
  account_id INTEGER PRIMARY KEY,
  login VARCHAR(100) NOT NULL,
  email VARCHAR(254) NOT NULL,
  password VARCHAR(60) NOT NULL
);

DROP TABLE if EXISTS external_employer CASCADE;
CREATE TABLE external_employer (
  employer_id INTEGER PRIMARY KEY,
  title VARCHAR(100) NOT NULL
);

DROP TABLE if EXISTS external_employer_account CASCADE;
CREATE TABLE external_employer_account (
  employer_id INTEGER REFERENCES external_employer,
  account_id INTEGER REFERENCES external_account,
  PRIMARY KEY (employer_id, account_id)
);

DROP TABLE if EXISTS external_city CASCADE;
CREATE TABLE external_city (
  city_id INTEGER PRIMARY KEY,
  NAME VARCHAR(100)
);

DROP TABLE if EXISTS external_vacancy CASCADE;
CREATE TABLE external_vacancy (
  vacancy_id INTEGER PRIMARY KEY,
  employer_id INTEGER REFERENCES external_employer NOT NULL,
  title VARCHAR(100) NOT NULL,
  city_id INTEGER REFERENCES external_city NOT NULL,
  salary INT4RANGE NOT NULL,
  experience_years EXPERIENCE_YEARS_T NOT NULL,
  schedule SCHEDULE_T,
  description TEXT,
  vacancy_status VACANCY_STATUS_T NOT NULL
);

DROP TABLE if EXISTS external_applicant CASCADE;
CREATE TABLE external_applicant (
  applicant_id INTEGER PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  account_id INTEGER REFERENCES external_account
);

DROP TABLE if EXISTS external_resume CASCADE;
CREATE TABLE external_resume (
  resume_id INTEGER PRIMARY KEY,
  applicant_id INTEGER REFERENCES external_applicant NOT NULL,
  title VARCHAR(100) NOT NULL,
  city_id INTEGER REFERENCES external_city NOT NULL,
  salary INT4RANGE NOT NULL,
  experience_years EXPERIENCE_YEARS_T NOT NULL,
  schedule SCHEDULE_T,
  text TEXT,
  CHECK (experience_years != 'ANY')
);

DROP TABLE if EXISTS external_experience CASCADE;
CREATE TABLE external_experience (
  experience_id INTEGER PRIMARY KEY,
  resume_id INTEGER REFERENCES external_resume NOT NULL,
  employer VARCHAR(100) NOT NULL,
  job_title VARCHAR(100) NOT NULL,
  job_description TEXT,
  dates DATERANGE NOT NULL
);

DROP TABLE if EXISTS external_application CASCADE;
CREATE TABLE external_application (
  application_id INTEGER PRIMARY KEY,
  resume_id INTEGER REFERENCES external_resume NOT NULL,
  vacancy_id INTEGER REFERENCES external_vacancy NOT NULL,
  application_status  APPLICATION_STATUS_T NOT NULL
);

DROP TABLE if EXISTS external_message CASCADE;
CREATE TABLE external_message (
  message_id INTEGER PRIMARY KEY,
  application_id INTEGER REFERENCES external_application NOT NULL,
  created TIMESTAMP NOT NULL,
  applicant_to_employer BOOLEAN NOT NULL,
  text TEXT
);
