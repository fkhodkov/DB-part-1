DROP TABLE IF EXISTS external_stats;
CREATE TABLE external_stats (
  table_name VARCHAR(50) PRIMARY KEY,
  volume INTEGER
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

ALTER TABLE external_city ADD COLUMN city_id INTEGER;
ALTER TABLE external_city ADD COLUMN need_to_insert BOOLEAN DEFAULT TRUE;
UPDATE external_city
   SET city_id = nextval('city_city_id_seq');
UPDATE external_city
   SET city_id = city.city_id, need_to_insert = FALSE
       FROM city JOIN external_city AS es USING (name)
 WHERE external_city.external_city_id = es.external_city_id;

ALTER TABLE external_account ADD COLUMN account_id INTEGER;
UPDATE external_account
   SET account_id = nextval('account_account_id_seq');

ALTER TABLE external_employer ADD COLUMN employer_id INTEGER;
UPDATE external_employer
   SET employer_id = nextval('employer_employer_id_seq');

ALTER TABLE external_employer_account ADD COLUMN account_id INTEGER;
ALTER TABLE external_employer_account ADD COLUMN employer_id INTEGER;
UPDATE external_employer_account
   SET account_id = external_account.account_id
       FROM external_account
 WHERE external_employer_account.external_account_id =
       external_account.external_account_id;
UPDATE external_employer_account
   SET employer_id = external_employer.employer_id
       FROM external_employer
 WHERE external_employer_account.external_employer_id =
       external_employer.external_employer_id;

ALTER TABLE external_vacancy ADD COLUMN vacancy_id INTEGER;
ALTER TABLE external_vacancy ADD COLUMN employer_id INTEGER;
ALTER TABLE external_vacancy ADD COLUMN city_id INTEGER;
UPDATE external_vacancy
   SET vacancy_id = nextval('vacancy_vacancy_id_seq');
UPDATE external_vacancy
   SET city_id = external_city.city_id FROM external_city
 WHERE external_vacancy.external_city_id = external_city.external_city_id;
UPDATE external_vacancy
   SET employer_id = external_employer.employer_id
       FROM external_employer
 WHERE external_vacancy.external_employer_id =
       external_employer.external_employer_id;

ALTER TABLE external_applicant ADD COLUMN applicant_id INTEGER;
ALTER TABLE external_applicant ADD COLUMN account_id INTEGER;
UPDATE external_applicant
   SET applicant_id = nextval('applicant_applicant_id_seq');
UPDATE external_applicant
   SET account_id = external_account.account_id
       FROM external_account
 WHERE external_applicant.external_account_id =
       external_account.external_account_id;

ALTER TABLE external_resume ADD COLUMN resume_id INTEGER;
ALTER TABLE external_resume ADD COLUMN applicant_id INTEGER;
ALTER TABLE external_resume ADD COLUMN city_id INTEGER;
UPDATE external_resume
   SET resume_id = nextval('resume_resume_id_seq');
UPDATE external_resume
   SET city_id = external_city.city_id FROM external_city
 WHERE external_resume.external_city_id = external_city.external_city_id;
UPDATE external_resume
   SET applicant_id = external_applicant.applicant_id
       FROM external_applicant
 WHERE external_resume.external_applicant_id =
       external_applicant.external_applicant_id;

ALTER TABLE external_experience ADD COLUMN experience_id INTEGER;
ALTER TABLE external_experience ADD COLUMN resume_id INTEGER;
UPDATE external_experience
   SET experience_id = nextval('experience_experience_id_seq');
UPDATE external_experience
   SET resume_id = external_resume.resume_id
       FROM external_resume
 WHERE external_experience.external_resume_id =
       external_resume.external_resume_id;

ALTER TABLE external_application ADD COLUMN application_id INTEGER;
ALTER TABLE external_application ADD COLUMN resume_id INTEGER;
ALTER TABLE external_application ADD COLUMN vacancy_id INTEGER;
UPDATE external_application
   SET application_id = nextval('application_application_id_seq');
UPDATE external_application
   SET vacancy_id = external_vacancy.vacancy_id
       FROM external_vacancy
 WHERE external_application.external_vacancy_id =
       external_vacancy.external_vacancy_id;
UPDATE external_application
   SET resume_id = external_resume.resume_id
       FROM external_resume
 WHERE external_application.external_resume_id =
       external_resume.external_resume_id;

ALTER TABLE external_message ADD COLUMN message_id INTEGER;
ALTER TABLE external_message ADD COLUMN application_id INTEGER;
UPDATE external_message
   SET message_id = nextval('message_message_id_seq');
UPDATE external_message
   SET application_id = external_application.application_id
       FROM external_application
 WHERE external_message.external_application_id =
       external_application.external_application_id;
