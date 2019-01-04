DROP TABLE IF EXISTS employer CASCADE;
DROP TABLE IF EXISTS vacancy CASCADE;
DROP TABLE IF EXISTS applicant CASCADE;
DROP TABLE IF EXISTS resume CASCADE;
DROP TABLE IF EXISTS application CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TYPE IF EXISTS SCHEDULE_T CASCADE;

CREATE TABLE employer (
  id SERIAL PRIMARY KEY,
  title VARCHAR(1000) NOT NULL
);

CREATE TYPE SCHEDULE_T AS ENUM (
  'full_time',
  'part_time',
  'flexible',
  'remote'
);

CREATE TABLE vacancy (
  id SERIAL PRIMARY KEY,
  employer_id BIGINT REFERENCES employer(id) NOT NULL,
  title VARCHAR(1000) NOT NULL,
  city VARCHAR(100) NOT NULL,
  salary NUMRANGE,
  experience_years INTEGER,
  schedule SCHEDULE_T,
  field VARCHAR(1000),
  description TEXT
);

CREATE TABLE applicant (
  id SERIAL PRIMARY KEY,
  name VARCHAR(1000) NOT NULL
);

CREATE TABLE resume (
  id SERIAL PRIMARY KEY,
  applicant_id BIGINT REFERENCES applicant(id) NOT NULL,
  title VARCHAR(1000) NOT NULL,
  city VARCHAR(100) NOT NULL,
  salary NUMRANGE,
  experience_years INTEGER,
  schedule SCHEDULE_T,
  field VARCHAR(1000),
  text TEXT
);

CREATE TABLE message (
  id SERIAL PRIMARY KEY,
  response_to BIGINT REFERENCES message(id),
  text TEXT
  );

CREATE TABLE application (
  id SERIAL PRIMARY KEY,
  resume_id BIGINT REFERENCES resume(id) NOT NULL,
  vacancy_id BIGINT REFERENCES vacancy(id) NOT NULL,
  message_id BIGINT REFERENCES message(id) NOT NULL
  );
