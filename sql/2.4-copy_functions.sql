DROP TABLE IF EXISTS city_translation;

SELECT city.city_id, external_city.city_id AS ext INTO city_translation
  FROM city RIGHT JOIN external_city USING (name);

ALTER table city_translation ADD PRIMARY KEY (ext);

UPDATE city_translation
   SET city_id = nextval('external_city_seq') WHERE city_id is NULL;

DROP FUNCTION IF EXISTS copy_city;
CREATE FUNCTION copy_city(starting INTEGER) RETURNS VOID AS $$
  DECLARE
  matching RECORD;
  id_off INTEGER;
BEGIN
  id_off := (SELECT id_offset FROM external_volumes WHERE table_name = 'city');
  FOR matching IN (
    SELECT city_translation.city_id, name
      FROM external_city JOIN city_translation ON external_city.city_id = city_translation.ext
     WHERE external_city.city_id > starting AND external_city.city_id <= starting + 10000
       AND city_translation.city_id > id_off)
  LOOP
    INSERT INTO city
    VALUES (
      matching.city_id,
      matching.name
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_employer_account;
CREATE FUNCTION copy_employer_account(starting INTEGER) RETURNS VOID AS $$
  DECLARE
  matching RECORD;
  employer_offset INTEGER;
  account_offset INTEGER;
BEGIN
  employer_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'employer');
  account_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'account');
  FOR matching IN (
    SELECT *
      FROM external_employer_account
     WHERE employer_account_id > starting AND employer_account_id <= starting + 10000)
  LOOP
    INSERT INTO employer_account
    VALUES (
      (matching.employer_id + employer_offset),
      (matching.account_id + account_offset)
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_account;
CREATE FUNCTION copy_account(starting INTEGER) RETURNS void AS $$
  DECLARE
  matching record;
BEGIN
  FOR matching IN (
    SELECT * from external_account
     WHERE account_id > starting AND account_id <= starting + 10000)
    LOOP INSERT INTO account VALUES (
      nextval('external_account_seq'),
      matching.login,
      matching.email,
      matching.password
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_employer;
CREATE FUNCTION copy_employer(starting INTEGER) RETURNS void AS $$
  DECLARE
  matching record;
BEGIN
  FOR matching IN (
    SELECT * from external_employer
     WHERE employer_id > starting AND employer_id <= starting + 10000)
    LOOP INSERT INTO employer VALUES (
      nextval('external_employer_seq'),
      matching.title
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_vacancy;
CREATE FUNCTION copy_vacancy(starting INTEGER) RETURNS void AS $$
  DECLARE
  matching record;
  employer_offset INTEGER;
BEGIN
  employer_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'employer');
  FOR
    matching IN (
      SELECT * from external_vacancy
       WHERE vacancy_id > starting AND vacancy_id <= starting + 10000)
    LOOP INSERT INTO vacancy VALUES (
      nextval('external_vacancy_seq'),
      matching.employer_id + employer_offset,
      matching.title,
      (SELECT city_id FROM city_translation WHERE ext = matching.city_id),
      matching.salary,
      matching.experience_years,
      matching.schedule,
      matching.description,
      matching.vacancy_status
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_applicant;
CREATE FUNCTION copy_applicant(starting INTEGER) RETURNS void AS $$
  DECLARE
  matching record;
  account_offset INTEGER;
BEGIN
  account_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'account');
  FOR
    matching IN (
      SELECT * from external_applicant
       WHERE applicant_id > starting AND applicant_id <= starting + 10000)
    LOOP INSERT INTO applicant VALUES (
      nextval('external_applicant_seq'),
      matching.name,
      matching.account_id + account_offset
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_resume;
CREATE FUNCTION copy_resume(starting INTEGER) RETURNS void AS $$
  DECLARE
  matching record;
  applicant_offset INTEGER;
BEGIN
  applicant_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'applicant');
  FOR matching IN (
    SELECT * from external_resume
     WHERE resume_id > starting AND resume_id <= starting + 10000)
    LOOP INSERT INTO resume VALUES (
      nextval('external_resume_seq'),
      matching.applicant_id + applicant_offset,
      matching.title,
      (SELECT city_id FROM city_translation WHERE ext = matching.city_id),
      matching.salary,
      matching.experience_years,
      matching.schedule,
      matching.text
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_experience;
CREATE FUNCTION copy_experience(starting INTEGER) RETURNS void AS $$
  DECLARE
  matching record;
  resume_offset INTEGER;
BEGIN
  resume_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'resume');
  FOR matching IN (
    SELECT * from external_experience
     WHERE experience_id > starting AND experience_id <= starting + 10000)
    LOOP INSERT INTO experience VALUES (
      nextval('external_experience_seq'),
      matching.resume_id + resume_offset,
      matching.employer,
      matching.job_title,
      matching.job_description,
      matching.dates
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_application;
CREATE FUNCTION copy_application(starting INTEGER) RETURNS void AS $$
  DECLARE
  matching record;
  resume_offset INTEGER;
  vacancy_offset INTEGER;
BEGIN
  resume_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'resume');
  vacancy_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'vacancy');
  FOR matching IN (
    SELECT * from external_application
     WHERE application_id > starting AND application_id <= starting + 10000)
    LOOP INSERT INTO application VALUES (
      nextval('external_application_seq'),
      matching.resume_id + resume_offset,
      matching.vacancy_id + vacancy_offset,
      matching.application_status);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_message;
CREATE FUNCTION copy_message(starting INTEGER) RETURNS void AS $$
  DECLARE
  matching record;
  application_offset INTEGER;
BEGIN
  application_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'application');
  FOR matching IN (
    SELECT * from external_message WHERE message_id > starting AND message_id <= starting + 10000)
    LOOP INSERT INTO message VALUES (
      nextval('external_message_seq'),
      matching.application_id + application_offset,
      matching.created,
      matching.applicant_to_employer,
      matching.text
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;
