DROP TABLE IF EXISTS external_stats;
CREATE TABLE external_stats (
  table_name VARCHAR(50) PRIMARY KEY,
  volume INTEGER,
  id_offset INTEGER
);

INSERT INTO external_stats (table_name, volume) VALUES
('city', (SELECT COUNT(*) from external_city)),
('account', (SELECT COUNT(*) from external_account)),
('employer', (SELECT COUNT(*) from external_employer)),
('employer_account', (SELECT COUNT(*) from external_employer_account)),
('vacancy', (SELECT COUNT(*) from external_vacancy)),
('applicant', (SELECT COUNT(*) from external_applicant)),
('resume', (SELECT COUNT(*) from external_resume)),
('experience', (SELECT COUNT(*) from external_experience)),
('application', (SELECT COUNT(*) from external_application)),
('message', (SELECT COUNT(*) from external_message));

BEGIN;
  LOCK city;
  SELECT last_value INTO TEMP city_tmp FROM city_city_id_seq;
  SELECT setval(
    'city_city_id_seq',
    (SELECT last_value FROM city_tmp) +
    (SELECT volume FROM external_stats WHERE table_name = 'city'));
  UPDATE external_stats
     SET id_offset = (SELECT last_value FROM city_tmp)
   WHERE table_name = 'city';
  DROP SEQUENCE IF EXISTS external_city_seq;
  CREATE SEQUENCE external_city_seq;
  SELECT setval('external_city_seq', (SELECT last_value from city_tmp));
COMMIT;

BEGIN;
  LOCK account;
  SELECT last_value INTO TEMP account_tmp FROM account_account_id_seq;
  SELECT setval(
    'account_account_id_seq',
    (SELECT last_value FROM account_tmp) +
    (SELECT volume FROM external_stats WHERE table_name = 'account'));
  UPDATE external_stats
     SET id_offset = (SELECT last_value FROM account_tmp)
   WHERE table_name = 'account';
  DROP SEQUENCE IF EXISTS external_account_seq;
  CREATE SEQUENCE external_account_seq;
  SELECT setval('external_account_seq',(SELECT last_value from account_tmp));
COMMIT;

BEGIN;
  LOCK employer;
  SELECT last_value INTO TEMP employer_tmp FROM employer_employer_id_seq;
  SELECT setval(
    'employer_employer_id_seq',
    (SELECT last_value FROM employer_tmp) +
    (SELECT volume FROM external_stats WHERE table_name = 'employer'));
  UPDATE external_stats
     SET id_offset = (SELECT last_value FROM employer_tmp)
   WHERE table_name = 'employer';
  DROP SEQUENCE IF EXISTS external_employer_seq;
  CREATE SEQUENCE external_employer_seq;
  SELECT setval('external_employer_seq', (SELECT last_value from employer_tmp));
COMMIT;

BEGIN;
  LOCK vacancy;
  SELECT last_value INTO TEMP vacancy_tmp FROM vacancy_vacancy_id_seq;
  SELECT setval(
    'vacancy_vacancy_id_seq',
    (SELECT last_value FROM vacancy_tmp) +
    (SELECT volume FROM external_stats WHERE table_name = 'vacancy'));
  UPDATE external_stats
     SET id_offset = (SELECT last_value FROM vacancy_tmp)
   WHERE table_name = 'vacancy';
  DROP SEQUENCE IF EXISTS external_vacancy_seq;
  CREATE SEQUENCE external_vacancy_seq;
  SELECT setval('external_vacancy_seq', (SELECT last_value from vacancy_tmp));
COMMIT;

BEGIN;
  LOCK applicant;
  SELECT last_value INTO TEMP applicant_tmp FROM applicant_applicant_id_seq;
  SELECT setval(
    'applicant_applicant_id_seq',
    (SELECT last_value FROM applicant_tmp) +
    (SELECT volume FROM external_stats WHERE table_name = 'applicant'));
  UPDATE external_stats
     SET id_offset = (SELECT last_value FROM applicant_tmp)
   WHERE table_name = 'applicant';
  DROP SEQUENCE IF EXISTS external_applicant_seq;
  CREATE SEQUENCE external_applicant_seq;
  SELECT setval('external_applicant_seq', (SELECT last_value from applicant_tmp));
COMMIT;

BEGIN;
  LOCK resume;
  SELECT last_value INTO TEMP resume_tmp FROM resume_resume_id_seq;
  SELECT setval(
    'resume_resume_id_seq',
    (SELECT last_value FROM resume_tmp) +
    (SELECT volume FROM external_stats WHERE table_name = 'resume'));
  UPDATE external_stats
     SET id_offset = (SELECT last_value FROM resume_tmp)
   WHERE table_name = 'resume';
  DROP SEQUENCE IF EXISTS external_resume_seq;
  CREATE SEQUENCE external_resume_seq;
  SELECT setval('external_resume_seq', (SELECT last_value from resume_tmp));
COMMIT;

BEGIN;
  LOCK experience;
  SELECT last_value INTO TEMP experience_tmp FROM experience_experience_id_seq;
  SELECT setval(
    'experience_experience_id_seq',
    (SELECT last_value FROM experience_tmp) +
    (SELECT volume FROM external_stats WHERE table_name = 'experience'));
  UPDATE external_stats
     SET id_offset = (SELECT last_value FROM experience_tmp)
   WHERE table_name = 'experience';
  DROP SEQUENCE IF EXISTS external_experience_seq;
  CREATE SEQUENCE external_experience_seq;
  SELECT setval('external_experience_seq', (SELECT last_value from experience_tmp));
COMMIT;

BEGIN;
  LOCK application;
  SELECT last_value INTO TEMP application_tmp FROM application_application_id_seq;
  SELECT setval(
    'application_application_id_seq',
    (SELECT last_value FROM application_tmp) +
    (SELECT volume FROM external_stats WHERE table_name = 'application'));
  UPDATE external_stats
     SET id_offset = (SELECT last_value FROM application_tmp)
   WHERE table_name = 'application';
  DROP SEQUENCE IF EXISTS external_application_seq;
  CREATE SEQUENCE external_application_seq;
  SELECT setval('external_application_seq', (SELECT last_value from application_tmp));
COMMIT;

BEGIN;
  LOCK message;
  SELECT last_value INTO TEMP message_tmp FROM message_message_id_seq;
  SELECT setval(
    'message_message_id_seq',
    (SELECT last_value FROM message_tmp) +
    (SELECT volume FROM external_stats WHERE table_name = 'message'));
  UPDATE external_stats
     SET id_offset = (SELECT last_value FROM message_tmp)
   WHERE table_name = 'message';
  DROP SEQUENCE IF EXISTS external_message_seq;
  CREATE SEQUENCE external_message_seq;
  SELECT setval('external_message_seq', (SELECT last_value from message_tmp));
COMMIT;
