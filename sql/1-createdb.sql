DROP TABLE IF EXISTS employer CASCADE;
DROP TABLE IF EXISTS vacancy CASCADE;
DROP TABLE IF EXISTS applicant CASCADE;
DROP TABLE IF EXISTS resume CASCADE;
DROP TABLE IF EXISTS application CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TYPE IF EXISTS SCHEDULE_T CASCADE;

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

CREATE TABLE vacancy (
  vacancy_id SERIAL PRIMARY KEY,
  employer_id BIGINT REFERENCES employer(employer_id) NOT NULL,
  title VARCHAR(1000) NOT NULL,
  city VARCHAR(100) NOT NULL,
  salary NUMRANGE,
  experience_years INTEGER,
  schedule SCHEDULE_T,
  field VARCHAR(1000),
  description TEXT
);

CREATE TABLE applicant (
  applicant_id SERIAL PRIMARY KEY,
  name VARCHAR(1000) NOT NULL
);

CREATE TABLE resume (
  resume_id SERIAL PRIMARY KEY,
  applicant_id BIGINT REFERENCES applicant(applicant_id) NOT NULL,
  title VARCHAR(1000) NOT NULL,
  city VARCHAR(100) NOT NULL,
  salary NUMRANGE,
  experience_years INTEGER,
  schedule SCHEDULE_T,
  field VARCHAR(1000),
  text TEXT
);

CREATE TABLE message (
  message_id SERIAL PRIMARY KEY,
  response_to BIGINT REFERENCES message(message_id),
  text TEXT
  );

CREATE TABLE application (
  application_id SERIAL PRIMARY KEY,
  resume_id BIGINT REFERENCES resume(resume_id) NOT NULL,
  vacancy_id BIGINT REFERENCES vacancy(vacancy_id) NOT NULL,
  message_id BIGINT REFERENCES message(message_id) NOT NULL
  );
