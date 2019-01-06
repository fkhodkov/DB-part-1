\pset pager off

-- 1. Зарегистрировать работодателя.
INSERT INTO employer (title, email, password)
VALUES ('Contora Ltd.', 'contora@email', crypt('qwerty', gen_salt('bf')));

-- 2. Зарегистрировать соискателя.
INSERT INTO applicant (name, email, password)
VALUES ('Джон Доу', 'doe@email', crypt('qwerty', gen_salt('bf')));

-- 3. Найти аккаунт с правильным паролем
SELECT employer_id FROM employer
 WHERE email='contora@email' AND password=crypt('qwerty', password);

-- 4. НЕ найти аккаунт с неправильным паролем
SELECT applicant_id FROM applicant
 WHERE email='doe@email' AND password=crypt('not qwerty', password);

-- 5. Создать вакансию.
-- Указаны обязательные параметры (id работодателя, название и город);
-- из необязательных указаны желаемый опыт и график работы.
INSERT INTO vacancy (
  employer_id,
  title,
  city_id,
  expyears_key,
  schedule
) VALUES (
  4,
  'Зиц-председатель',
  5,
  '6+',
  'REMOTE'
);

-- 6. Создать резюме.
-- Указаны обязательные параметры (id соискателя, название, город);
-- из необязательных: опыт работы и желательный график.
INSERT INTO resume (
  applicant_id,
  title,
  city_id,
  experience_years,
  schedule
) VALUES (
  5,
  'Штирлиц',
  6,
  25,
  'FULL_TIME'
);

-- 7. Откликнуться на вакансию, отправив резюме и сообщение
-- (создается в процессе отклика).
WITH created_application AS (
  INSERT INTO application(
    resume_id,
    vacancy_id,
    status
  ) VALUES (6, 4, 'NOT_RESPONDED')
  RETURNING application_id
) INSERT INTO message (
  application_id,
  text,
  applicant_to_employer,
  created
) VALUES (
  (SELECT application_id FROM created_application),
  'Добрый день!
Рассмотрите, пожалуйста, мою кандидатуру
С уважением, Мария',
  TRUE,
  now()
);

-- 8. Мы — Лютик (employer_id = 2) и хотим посмотреть наши вакансии
-- с количеством неотвеченных откликов для каждой.
SELECT vacancy_id, COUNT(application_id)
  FROM application JOIN vacancy USING (vacancy_id)
 WHERE vacancy.employer_id = 2 AND status = 'NOT_RESPONDED'
 GROUP BY vacancy_id
;

-- 9. Мы — Лютик (employer_id = 2) и хотим посмотреть отклики на вакансию
-- Java-программиста (id=4).
SELECT application_id, applicant.name, experience_years, salary, city.name
  FROM application JOIN resume USING (resume_id)
         JOIN applicant USING (applicant_id)
         JOIN city USING (city_id)
 WHERE vacancy_id = 4 AND status = 'NOT_RESPONDED'
;

-- 10. Мы — Лютик (employer_id = 2) и хотим посмотреть отклики на вакансию
-- Java-программиста (id=4), которые удовлетворяют нашим требованиям.
SELECT application_id, applicant.name, experience_years, resume.salary
  FROM application JOIN vacancy USING (vacancy_id)
         JOIN resume USING (resume_id)
         JOIN expyears_translation USING (expyears_key)
         JOIN applicant USING (applicant_id)
 WHERE vacancy_id = 4 AND status = 'NOT_RESPONDED' AND
       resume.city_id = vacancy.city_id AND
       experience_years <@ expyears_value AND
       resume.schedule = vacancy.schedule AND
       resume.salary && vacancy.salary
;

-- 11. Мы — Лютик (employer_id = 2) и хотим отправить тестовое задание
-- подходящим кандидатам на нашу вакансию Java-программиста (id=4).
DROP FUNCTION IF EXISTS buttercup_reply;
CREATE FUNCTION buttercup_reply(vac_id INTEGER) RETURNS void AS $$
  DECLARE
  matching record;
BEGIN
  FOR matching IN (
    SELECT application_id, applicant.name, vacancy.title
      FROM application JOIN vacancy USING (vacancy_id)
             JOIN resume USING (resume_id)
             JOIN expyears_translation USING (expyears_key)
             JOIN applicant USING (applicant_id)
     WHERE vacancy_id = vac_id AND status = 'NOT_RESPONDED' AND
           resume.city_id = vacancy.city_id AND
           experience_years <@ expyears_value AND
           resume.schedule = vacancy.schedule AND
           resume.salary && vacancy.salary
  ) LOOP
    INSERT INTO message (
      application_id,
      created,
      applicant_to_employer,
      text
    ) VALUES (
      matching.application_id,
      now(),
      FALSE,
      'Здравствуйте, ' || matching.name || '!
Спасибо за интерес к нашей вакансии ' || matching.title || '
Решите, пожалуйста, тестовое задание, которое вы можете найти по адресу:
https://lyutik/testovoe_zadanie
-- 
С уважением, Лютиков Л. Л.'
    );
    UPDATE application SET status = 'RESPONDED'
     WHERE application_id = matching.application_id;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM buttercup_reply(4);

-- 12. Мы — по-прежнему Лютик и хотим посмотреть всю переписку с
-- Лисой Патрикеевной Рыжей (application_id = 3)
SELECT applicant_to_employer, text
  FROM message
 WHERE application_id = 3
 ORDER BY created;
