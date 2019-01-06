DROP TABLE IF EXISTS employer CASCADE;
DROP TABLE IF EXISTS vacancy CASCADE;
DROP TABLE IF EXISTS applicant CASCADE;
DROP TABLE IF EXISTS resume CASCADE;
DROP TABLE IF EXISTS application CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TYPE IF EXISTS SCHEDULE_T CASCADE;

CREATE TABLE employer (
  employer_id BIGSERIAL PRIMARY KEY,
  title VARCHAR(1000) NOT NULL
);

CREATE TYPE SCHEDULE_T AS ENUM (
  'FULL_TIME',
  'PART_TIME',
  'FLEXIBLE',
  'REMOTE'
);

CREATE TABLE vacancy (
  vacancy_id BIGSERIAL PRIMARY KEY,
  employer_id BIGINT REFERENCES employer(employer_id) NOT NULL,
  title VARCHAR(1000) NOT NULL,
  city VARCHAR(100) NOT NULL,
  salary INT4RANGE,
  experience_years INTEGER,
  schedule SCHEDULE_T,
  description TEXT
);

CREATE TABLE applicant (
  applicant_id BIGSERIAL PRIMARY KEY,
  name VARCHAR(1000) NOT NULL
);

CREATE TABLE resume (
  resume_id BIGSERIAL PRIMARY KEY,
  applicant_id BIGINT REFERENCES applicant(applicant_id) NOT NULL,
  title VARCHAR(1000) NOT NULL,
  city VARCHAR(100) NOT NULL,
  salary INT4RANGE,
  experience_years INTEGER,
  schedule SCHEDULE_T,
  text TEXT
);

CREATE TABLE application (
  application_id BIGSERIAL PRIMARY KEY,
  resume_id BIGINT REFERENCES resume(resume_id) NOT NULL,
  vacancy_id BIGINT REFERENCES vacancy(vacancy_id) NOT NULL
  );

CREATE TABLE message (
  message_id BIGSERIAL PRIMARY KEY,
  application_id BIGINT REFERENCES application(application_id) NOT NULL,
  created TIMESTAMP NOT NULL,
  applicant_to_employer BOOLEAN NOT NULL,
  text TEXT
  );
