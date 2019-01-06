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
  'remote'
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
  'full_time'
);

-- 5. Откликнуться на вакансию, отправив резюме и сообщение
-- (создается в процессе отклика).
BEGIN;
  WITH created_message AS (
    INSERT INTO message(text)
    VALUES ('Добрый день!
Рассмотрите, пожалуйста, мою кандидатуру
С уважением, Мария')
    RETURNING message_id
  ) INSERT INTO application(
    resume_id,
    vacancy_id,
    message_id
  ) VALUES (
    3,
    4,
    (SELECT message_id from created_message)
  );
END;

-- 6. Версия прошлой транзакции, где что-то пошло не так.
-- Сообщение не нужно и в базе не сохраняется.
SELECT COUNT(message_id) AS before_count FROM message;

BEGIN;
  WITH created_message AS (
    INSERT INTO message(text)
    VALUES ('Это сообщение не должно оказаться в базе')
    RETURNING message_id
  ) INSERT INTO application(
    resume_id,
    message_id
  ) VALUES (
    3,
    (SELECT message_id from created_message)
  );
END;

SELECT COUNT(message_id) AS after_count FROM message;

-- 7. Мы — фирма Лютик (employer_id = 2) и хотим посмотреть все отклики на наши вакансии.
SELECT resume_id, message.text
  FROM application JOIN vacancy ON application.vacancy_id = vacancy.vacancy_id
         JOIN message ON application.message_id = message.message_id
 WHERE vacancy.employer_id = 2;

-- 8. Мы — фирма Ромашка (employer_id = 1) и хотим посмотреть все отклики на наши
-- вакансии, где параметры резюме не совпадают с параметрами вакансии.
SELECT application.resume_id, application.vacancy_id, message.text
  FROM application JOIN vacancy ON application.vacancy_id = vacancy.vacancy_id
         JOIN message ON application.message_id = message.message_id
         JOIN resume ON resume.resume_id = application.resume_id
 WHERE vacancy.employer_id = 1
   AND (resume.city != vacancy.city OR
        resume.experience_years < vacancy.experience_years OR
        resume.schedule != vacancy.schedule OR
        resume.field != vacancy.field OR
        NOT resume.salary && vacancy.salary
   );
