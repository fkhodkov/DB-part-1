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
  city,
  expyears_key,
  schedule
) VALUES (
  4,
  'Зиц-председатель',
  'Черноморск',
  '6+',
  'REMOTE'
);

-- 6. Создать резюме.
-- Указаны обязательные параметры (id соискателя, название, город);
-- из необязательных: опыт работы и желательный график.
INSERT INTO resume (
  applicant_id,
  title,
  city,
  experience_years,
  schedule
) VALUES (
  5,
  'Штирлиц',
  'Берлин',
  25,
  'FULL_TIME'
);

-- 7. Откликнуться на вакансию, отправив резюме и сообщение
-- (создается в процессе отклика).
WITH created_application AS (
  INSERT INTO application(
    resume_id,
    vacancy_id
  ) VALUES (3, 4)
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

-- 8. Мы — фирма Лютик (employer_id = 2) и хотим посмотреть все отклики на наши вакансии.
SELECT resume_id, message.text
  FROM application JOIN vacancy USING (vacancy_id)
         JOIN message USING (application_id)
 WHERE employer_id = 2;

-- 9. Мы — фирма Ромашка (employer_id = 1) и хотим посмотреть все отклики на наши
-- вакансии, где параметры резюме не совпадают с параметрами вакансии.
SELECT application.application_id
  FROM application JOIN vacancy USING (vacancy_id)
         JOIN resume USING (resume_id)
         JOIN expyears_translation USING (expyears_key)
 WHERE vacancy.employer_id = 1
   AND (resume.city != vacancy.city OR
        NOT experience_years <@ expyears_value OR
        resume.schedule != vacancy.schedule OR
        NOT resume.salary && vacancy.salary
   );

-- 10. Посмотреть переписку с соискателем, начиная с последнего сообщения, зная
-- id отклика.
SELECT text, applicant_to_employer
  FROM message
 WHERE application_id = 1
 ORDER BY created DESC;

-- 11. Комбинация 9 и 10: Ромашка хочет посмотреть переписки со всеми соискателями
-- на свои вакансии, где параметры резюме не совпадают с параметрами вакансии.
WITH nonmatching_applications AS (
  SELECT application.application_id
    FROM application JOIN vacancy USING (vacancy_id)
           JOIN resume USING (resume_id)
           JOIN expyears_translation USING (expyears_key)
   WHERE vacancy.employer_id = 1
     AND (resume.city != vacancy.city OR
          NOT experience_years <@ expyears_value OR
          resume.schedule != vacancy.schedule OR
          NOT resume.salary && vacancy.salary
     )
) SELECT message.application_id, text, applicant_to_employer
    FROM message JOIN nonmatching_applications USING (application_id)
   ORDER BY message.application_id, created DESC
;

