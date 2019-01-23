DROP FUNCTION IF EXISTS copy_city;
CREATE FUNCTION copy_city(starting INTEGER) RETURNS VOID AS $$
  DECLARE matching RECORD;
BEGIN
  FOR matching IN (
    SELECT city_id, name
      FROM external_city
     WHERE external_city_id > starting AND
           external_city_id <= starting + 10000
       AND need_to_insert)
  LOOP
    INSERT INTO city
    VALUES (matching.city_id, matching.name);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_employer_account;
CREATE FUNCTION copy_employer_account(starting INTEGER) RETURNS VOID AS $$
  DECLARE matching RECORD;
BEGIN
  FOR matching IN (
    SELECT employer_id, account_id
      FROM external_employer_account
     WHERE external_employer_account_id > starting AND
           external_employer_account_id <= starting + 10000)
  LOOP
    INSERT INTO employer_account
    VALUES (matching.employer_id, matching.account_id);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_account;
CREATE FUNCTION copy_account(starting INTEGER) RETURNS void AS $$
  DECLARE matching record;
BEGIN
  FOR matching IN (
    SELECT account_id, login, email, password
      FROM external_account
     WHERE external_account_id > starting AND
           external_account_id <= starting + 10000)
    LOOP INSERT INTO account VALUES (
      matching.account_id,
      (SELECT external_unique_login(matching.account_id, matching.login)),
      matching.email,
      matching.password
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_employer;
CREATE FUNCTION copy_employer(starting INTEGER) RETURNS void AS $$
  DECLARE matching record;
BEGIN
  FOR matching IN (
    SELECT employer_id, title
      FROM external_employer
     WHERE external_employer_id > starting AND
           external_employer_id <= starting + 10000)
    LOOP INSERT INTO employer VALUES (
      matching.employer_id,
      matching.title
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_vacancy;
CREATE FUNCTION copy_vacancy(starting INTEGER) RETURNS void AS $$
  DECLARE matching record;
BEGIN
  FOR
    matching IN (
      SELECT vacancy_id, employer_id, title, city_id, salary,
             experience_years, schedule, description, vacancy_status
        FROM external_vacancy
       WHERE external_vacancy_id > starting AND
             external_vacancy_id <= starting + 10000)
    LOOP INSERT INTO vacancy VALUES (
      matching.vacancy_id,
      matching.employer_id,
      matching.title,
      matching.city_id,
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
  DECLARE matching record;
BEGIN
  FOR
    matching IN (
      SELECT applicant_id, name, account_id
        FROM external_applicant
       WHERE external_applicant_id > starting AND
             external_applicant_id <= starting + 10000)
    LOOP INSERT INTO applicant VALUES (
      matching.applicant_id,
      matching.name,
      matching.account_id
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_resume;
CREATE FUNCTION copy_resume(starting INTEGER) RETURNS void AS $$
  DECLARE matching record;
BEGIN
  FOR matching IN (
    SELECT resume_id, applicant_id, title, city_id, salary,
           experience_years, schedule, text
      FROM external_resume
     WHERE external_resume_id > starting AND
           external_resume_id <= starting + 10000)
    LOOP INSERT INTO resume VALUES (
      matching.resume_id,
      matching.applicant_id,
      matching.title,
      matching.city_id,
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
  DECLARE matching record;
BEGIN
  FOR matching IN (
    SELECT experience_id, resume_id, employer, job_title, job_description, dates
      FROM external_experience
     WHERE external_experience_id > starting AND
           external_experience_id <= starting + 10000)
    LOOP INSERT INTO experience VALUES (
      matching.experience_id,
      matching.resume_id,
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
  DECLARE matching record;
BEGIN
  FOR matching IN (
    SELECT application_id, resume_id, vacancy_id, application_status
      FROM external_application
     WHERE external_application_id > starting AND
           external_application_id <= starting + 10000)
    LOOP INSERT INTO application VALUES (
      matching.application_id,
      matching.resume_id,
      matching.vacancy_id,
      matching.application_status);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_message;
CREATE FUNCTION copy_message(starting INTEGER) RETURNS void AS $$
  DECLARE matching record;
BEGIN
  FOR matching IN (
    SELECT message_id, application_id, created, applicant_to_employer, text
      FROM external_message
     WHERE external_message_id > starting AND
           external_message_id <= starting + 10000)
    LOOP INSERT INTO message VALUES (
      matching.message_id,
      matching.application_id,
      matching.created,
      matching.applicant_to_employer,
      matching.text
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;
