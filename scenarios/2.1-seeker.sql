\pset pager off

-- Часть I. «Соискатель»
-- 1. Я ищу работу и хочу зарегистрироваться на сайте огненного стартапа как
-- соискатель, чтобы размещать резюме и искать вакансии
EXPLAIN ANALYZE
WITH created_account AS (
  INSERT INTO account (login, email, password)
  VALUES ((SELECT 'johndoe' || nextval('scenario2_applicant_seq')),
          'johndoe@email',
          crypt('qwerty', gen_salt('bf'))
  ) RETURNING account_id)
    INSERT INTO applicant (name, account_id)
    VALUES ('Джон Доу', (SELECT account_id FROM created_account));

-- 2. Я зарегистрирован на сайте огненного стартапа как соискатель и хочу
-- авторизоваться, чтобы разместить резюме, найти вакансии и посмотреть ответы
EXPLAIN ANALYZE
SELECT account_id
  FROM account
 WHERE login='johndoe1'
   AND password=crypt('qwerty', password);

-- 3. Я авторизованный пользователь огненного стартапа и хочу создать резюме,
-- чтобы откликаться на вакансии
-- 3.1 Узнаем свой applicant_id
EXPLAIN ANALYZE
SELECT account_id, applicant_id
  FROM applicant JOIN account USING (account_id)
 WHERE login = 'johndoe1';
-- 3.2 Создадим резюме
EXPLAIN ANALYZE
INSERT INTO resume (
  applicant_id,
  title,
  city_id,
  experience_years,
  schedule,
  salary_min,
  salary_max
) VALUES (
  1000007,
  'Архитектор БД',
  1,
  '0-1',
  'FULL_TIME',
  50000,
  NULL
);
-- 3.3 Узнаем id нашего резюме
EXPLAIN ANALYZE
SELECT resume_id, title FROM resume
 WHERE applicant_id = 1000007;
-- 3.4 Добавим опыт работы
EXPLAIN ANALYZE
INSERT INTO experience (resume_id, employer, job_title, job_description, dates)
VALUES (
  3000008,
  'Огненный стартап',
  'Архитектор БД',
  'Задачи:
  * Понять сценарии использования приложения
  * Спроектировать БД, которая будет это приложение обслуживать.',
  DATERANGE('2019-01-01', NULL)
);

-- 4. Я соискатель с готовым резюме и хочу найти вакансии, которые подходят к
-- этому резюме.
EXPLAIN ANALYZE
WITH my_resume AS (
  SELECT title, city_id, schedule, salary_min, salary_max, experience_years
    FROM resume WHERE resume_id = 3000008)
  SELECT vacancy_id, vacancy.title, employer.title, vacancy.experience_years,
         vacancy.salary_min, vacancy.salary_max
  FROM vacancy JOIN employer USING (employer_id)
 WHERE vacancy.title = (SELECT title FROM my_resume) AND
       vacancy.city_id = (SELECT city_id FROM my_resume) AND
       vacancy.schedule = (SELECT schedule FROM my_resume) AND
       (vacancy.experience_years = 'ANY' OR
        vacancy.experience_years = (SELECT experience_years FROM my_resume)) AND
        (vacancy.salary_min IS NULL OR (SELECT salary_max FROM my_resume) IS NULL OR
         vacancy.salary_min <= (SELECT salary_max FROM my_resume)) AND 
        (vacancy.salary_max IS NULL OR (SELECT salary_min FROM my_resume) IS NULL OR
         vacancy.salary_max >= (SELECT salary_min FROM my_resume));

-- 5. Я нашел нужные вакансии и хочу отправить свое резюме и сообщение
-- работодателям, чтобы начать переписку.
EXPLAIN ANALYZE
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (3000008, 6, 'OPEN')
         RETURNING application_id
) INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES (
  5000012,
  'Добрый вечер!
  Прошу рассмотреть мою кандидатуру на должно Архитектора БД.',
  TRUE,
  now()
);

EXPLAIN ANALYZE
SELECT application_id
  FROM application
 WHERE resume_id = 3000008 AND
       vacancy_id = 6;

EXPLAIN ANALYZE
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (3000008, 7, 'OPEN')
  RETURNING application_id
) INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES (
  (SELECT application_id FROM created_application),
  'Добрый вечер!
Прошу рассмотреть мою кандидатуру на должно Архитектора БД.',
  TRUE,
  now()
) RETURNING application_id;

EXPLAIN ANALYZE
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (3000008, 8, 'OPEN')
         RETURNING application_id
) INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES (
  (SELECT application_id FROM created_application),
  'Добрый вечер!
  Прошу рассмотреть мою кандидатуру на должно Архитектора БД.',
  TRUE,
  now()
);

EXPLAIN ANALYZE
SELECT application_id
  FROM application
 WHERE resume_id = 3000008 AND
       vacancy_id = 8;

-- 5.1 На некоторые из откликов пришли ответы
EXPLAIN ANALYZE
INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES  (
  5000012,
  'Добрый вечер!
В дополнение к тому, что указано в вакансии, добавляем:
  * рабочий день составляет 25 часов в сутки,
  * без выходных.
Приходите на собеседование завтра в 23:00.
Адрес: за гаражами',
  FALSE,
  now()
);

EXPLAIN ANALYZE
INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES  (
  5000014,
  'Добрый вечер!
Решите, пожалуйста, тестовое задание.  
Вы можете скачать его по ссылке:
https://eprst-invest/testovoe-zadanie',
  FALSE,
  now()
);

-- 6. Я соискатель, который отправил резюме работодателями, и хочу посмотреть,
-- на какие их них уже пришли ответы
EXPLAIN ANALYZE
SELECT application_id, employer.title, vacancy.salary_min, vacancy.salary_max, message.text
  FROM application JOIN vacancy USING (vacancy_id)
         JOIN employer USING (employer_id)
         JOIN message USING (application_id)
 WHERE resume_id = 3000008
   AND NOT applicant_to_employer;

-- 7. Я соискатель, который в ходе переписки с работодателем решил, что не
-- заинтересован в вакансии, и хочу написать работодателю, чтобы сообщить о
-- своем решении
BEGIN;
  EXPLAIN ANALYZE
  INSERT INTO message (
    application_id, text, applicant_to_employer, created
  ) VALUES (
    5000012,
    'Здравствуйте,
К сожалению, по итогам длительных размышлений я пришел к выводу,
что вынужден отказаться от Вашей вакансии.
Спасибо, что уделили мне время!',
    TRUE,
    now()
  );
  EXPLAIN ANALYZE
  UPDATE application SET application_status = 'CLOSED'
   WHERE application_id = 5000012;
END;

-- 8. Я соискатель, который получил от работодателя предложение, которое меня
-- устроило, и хочу написать работодателю, чтобы сообщить, что принимаю
-- предложение
BEGIN;
  EXPLAIN ANALYZE
  INSERT INTO message (
    application_id, text, applicant_to_employer, created
  ) VALUES (
    5000014,
    'Здравствуйте,
Я принимаю Ваше предложение.  С нетерпением жду начала работы!',
    TRUE,
    now()
  );
  EXPLAIN ANALYZE
  UPDATE application SET application_status = 'CLOSED'
   WHERE application_id = 5000014;
END;
