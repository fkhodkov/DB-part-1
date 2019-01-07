-- Часть I. «Соискатель»

-- 1. Я ищу работу и хочу зарегистрироваться на сайте огненного стартапа как
-- соискатель, чтобы размещать резюме и искать вакансии
WITH created_account AS (
  INSERT INTO account (login, email, password)
  VALUES ('johndoe', 'johndoe@email', crypt('qwerty', gen_salt('bf'))) RETURNING account_id)
    INSERT INTO applicant (name, account_id)
    VALUES ('Джон Доу', (SELECT account_id FROM created_account));

-- 2. Я зарегистрирован на сайте огненного стартапа как соискатель и хочу
-- авторизоваться, чтобы разместить резюме, найти вакансии и посмотреть ответы
SELECT account_id FROM account
 WHERE login='johndoe' AND password=crypt('qwerty', password);

-- 3. Я авторизованный пользователь огненного стартапа и хочу создать резюме,
-- чтобы откликаться на вакансии
-- 3.1 Узнаем свой applicant_id
SELECT applicant_id FROM applicant WHERE account_id = 11;
-- 3.2 Создадим резюме
INSERT INTO resume (
  applicant_id,
  title,
  city_id,
  experience_years,
  schedule,
  salary
) VALUES (
  6,
  'Архитектор БД',
  1,
  '0-1',
  'FULL_TIME',
  INT4RANGE(50000, NULL)
);
-- 3.3 Узнаем id нашего резюме
SELECT resume_id FROM resume WHERE applicant_id = 6;
-- 3.4 Добавим опыт работы
INSERT INTO experience (resume_id, employer, job_title, job_description, dates)
VALUES (
  7,
  'Огненный стартап',
  'Архитектор БД',
  'Задачи:
  * Понять сценарии использования приложения
  * Спроектировать БД, которая будет это приложение обслуживать.',
  DATERANGE('2019-01-01', NULL)
);

-- 4. Я соискатель с готовым резюме и хочу найти вакансии, которые подходят к
-- этому резюме.
SELECT vacancy_id, vacancy.title, employer.title, vacancy.experience_years, vacancy.salary
  FROM vacancy JOIN resume USING (title, city_id, schedule)
         JOIN employer USING (employer_id)
 WHERE resume_id = 7 AND
       (vacancy.experience_years = 'ANY' OR
       vacancy.experience_years = resume.experience_years) AND
       vacancy.salary && resume.salary;

-- 5. Я нашел нужные вакансии и хочу отправить свое резюме и сообщение
-- работодателям, чтобы начать переписку.
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (7, 6, 'NOT_RESPONDED')
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
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (7, 7, 'NOT_RESPONDED')
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
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (7, 8, 'NOT_RESPONDED')
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
-- 5.1 На некоторые из откликов пришли ответы
BEGIN;
  INSERT INTO message (
    application_id, text, applicant_to_employer, created
  ) VALUES  (
    6,
    'Добрый вечер!
В дополнение к тому, что указано в вакансии, добавляем:
 * рабочий день составляет 25 часов в сутки,
 * без выходных.
Приходите на собеседование завтра в 23:00.
Адрес: за гаражами',
    FALSE,
    now()
  );
  UPDATE application SET application_status = 'RESPONDED'
   WHERE application_id = 6;
END;
BEGIN;
  INSERT INTO message (
    application_id, text, applicant_to_employer, created
  ) VALUES  (
    8,
    'Добрый вечер!
Решите, пожалуйста, тестовое задание.  
Вы можете скачать его по ссылке:
https://eprst-invest/testovoe-zadanie',
    FALSE,
    now()
  );
  UPDATE application SET application_status = 'RESPONDED'
   WHERE application_id = 8;
END;

-- 6. Я соискатель, который отправил резюме работодателями, и хочу посмотреть,
-- на какие их них уже пришли ответы
SELECT application_id, employer.title, vacancy.salary, message.text
  FROM application JOIN vacancy USING (vacancy_id)
         JOIN employer USING (employer_id)
         JOIN message USING (application_id)
 WHERE resume_id = 7
   AND application_status = 'RESPONDED'
   AND NOT applicant_to_employer;

-- 7. Я соискатель, который в ходе переписки с работодателем решил, что не
-- заинтересован в вакансии, и хочу написать работодателю, чтобы сообщить о
-- своем решении
BEGIN;
  INSERT INTO message (
    application_id, text, applicant_to_employer, created
  ) VALUES (
    6,
    'Здравствуйте,
К сожалению, по итогам длительных размышлений я пришел к выводу,
что вынужден отказаться от Вашей вакансии.
Спасибо, что уделили мне время!',
    TRUE,
    now()
  );
  UPDATE application SET application_status = 'WITHDRAWN'
   WHERE application_id = 6;
END;
-- 8. Я соискатель, который получил от работодателя предложение, которое меня
-- устроило, и хочу написать работодателю, чтобы сообщить, что принимаю
-- предложение
BEGIN;
  INSERT INTO message (
    application_id, text, applicant_to_employer, created
  ) VALUES (
    8,
    'Здравствуйте,
Я принимаю Ваше предложение.  С нетерпением жду начала работы!',
    TRUE,
    now()
  );
  UPDATE application SET application_status = 'ACCEPTED'
   WHERE application_id = 8;
END;
