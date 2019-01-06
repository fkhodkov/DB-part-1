\pset pager off

-- 1. Зарегистрировать работодателя.
INSERT INTO employer (title) VALUES ('Contora Ltd.');

-- 2. Зарегистрировать соискателя.
INSERT INTO applicant (name) VALUES ('Джон Доу');

-- 3. Создать вакансию.
-- Указаны обязательные параметры (id работодателя, название и город);
-- из необязательных указаны желаемый опыт и график работы.
INSERT INTO vacancy (
  employer_id,
  title,
  city,
  experience_years,
  schedule
) VALUES (
  4,
  'Зиц-председатель',
  'Черноморск',
  50,
  'REMOTE'
);

-- 4. Создать резюме.
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

-- 5. Откликнуться на вакансию, отправив резюме и сообщение
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

-- 6. Мы — фирма Лютик (employer_id = 2) и хотим посмотреть все отклики на наши вакансии.
SELECT resume_id, message.text
  FROM application JOIN vacancy USING (vacancy_id)
         JOIN message USING (application_id)
 WHERE vacancy.employer_id = 2;

-- 7. Мы — фирма Ромашка (employer_id = 1) и хотим посмотреть все отклики на наши
-- вакансии, где параметры резюме не совпадают с параметрами вакансии.
SELECT application.application_id
  FROM application JOIN vacancy USING (vacancy_id)
         JOIN resume USING (resume_id)
 WHERE vacancy.employer_id = 1
   AND (resume.city != vacancy.city OR
        resume.experience_years < vacancy.experience_years OR
        resume.schedule != vacancy.schedule OR
        NOT resume.salary && vacancy.salary
   );

-- 8. Посмотреть переписку с соискателем, начиная с последнего сообщения, зная
-- id отклика.
SELECT text, applicant_to_employer
  FROM message
 WHERE application_id = 1
 ORDER BY created DESC;

-- 9. Комбинация 7 и 8: Ромашка хочет посмотреть переписки со всеми соискателями
-- на свои вакансии, где параметры резюме не совпадают с параметрами вакансии.
WITH nonmatching_applications AS (
  SELECT application.application_id
    FROM application JOIN vacancy USING (vacancy_id)
           JOIN resume USING (resume_id)
   WHERE vacancy.employer_id = 1
     AND (resume.city != vacancy.city OR
          resume.experience_years < vacancy.experience_years OR
          resume.schedule != vacancy.schedule OR
          NOT resume.salary && vacancy.salary
     )
) SELECT message.application_id, text, applicant_to_employer
    FROM message JOIN nonmatching_applications USING (application_id)
   ORDER BY message.application_id, created DESC
;

