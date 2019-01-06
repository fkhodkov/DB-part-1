DROP TABLE IF EXISTS employer CASCADE;
DROP TABLE IF EXISTS vacancy CASCADE;
DROP TABLE IF EXISTS applicant CASCADE;
DROP TABLE IF EXISTS resume CASCADE;
DROP TABLE IF EXISTS application CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TABLE IF EXISTS expyears_translation CASCADE;
DROP TYPE IF EXISTS SCHEDULE_T CASCADE;
DROP TYPE IF EXISTS EXPYEARS_T CASCADE;

CREATE TABLE employer (
  employer_id SERIAL PRIMARY KEY,
  title VARCHAR(1000) NOT NULL
);

CREATE TYPE SCHEDULE_T AS ENUM (
  'FULL_TIME',
  'PART_TIME',
  'FLEXIBLE',
  'REMOTE'
);

CREATE TYPE EXPYEARS_T AS ENUM (
  '0-1',
  '1-3',
  '3-6',
  '6+',
  'ANY'
);

CREATE TABLE expyears_translation (
  expyears_key EXPYEARS_T PRIMARY KEY,
  expyears_value INT4RANGE
);

INSERT INTO expyears_translation
VALUES
  ('0-1', INT4RANGE(0, 1, '[]')),
  ('1-3', INT4RANGE(1, 3, '[]')),
  ('3-6', INT4RANGE(3, 6, '[]')),
  ('6+', INT4RANGE(6, NULL)),
  ('ANY', INT4RANGE(NULL, NULL))
;

CREATE TABLE vacancy (
  vacancy_id SERIAL PRIMARY KEY,
  employer_id INTEGER REFERENCES employer(employer_id) NOT NULL,
  title VARCHAR(1000) NOT NULL,
  city VARCHAR(100) NOT NULL,
  salary INT4RANGE,
  expyears_key EXPYEARS_T NOT NULL,
  schedule SCHEDULE_T,
  description TEXT
);

CREATE TABLE applicant (
  applicant_id SERIAL PRIMARY KEY,
  name VARCHAR(1000) NOT NULL
);

CREATE TABLE resume (
  resume_id SERIAL PRIMARY KEY,
  applicant_id INTEGER REFERENCES applicant(applicant_id) NOT NULL,
  title VARCHAR(1000) NOT NULL,
  city VARCHAR(100) NOT NULL,
  salary INT4RANGE,
  experience_years INTEGER,
  schedule SCHEDULE_T,
  text TEXT,
  CHECK (experience_years > 0)
);

CREATE TABLE application (
  application_id SERIAL PRIMARY KEY,
  resume_id INTEGER REFERENCES resume(resume_id) NOT NULL,
  vacancy_id INTEGER REFERENCES vacancy(vacancy_id) NOT NULL
  );

CREATE TABLE message (
  message_id SERIAL PRIMARY KEY,
  application_id INTEGER REFERENCES application(application_id) NOT NULL,
  created TIMESTAMP NOT NULL,
  applicant_to_employer BOOLEAN NOT NULL,
  text TEXT
  );
