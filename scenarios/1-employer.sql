-- Часть II. «Работодатель»

-- 1. Я ищу сотрудников и хочу зарегистрироваться на сайте огненного стартапа
-- как работодатель, чтобы размещать вакансии и искать резюме.
INSERT INTO account (login, email, password)
VALUES (
  'waterhouse',
  'waterhouse@epiphyte',
  crypt('qwerty', gen_salt('bf'))
);

-- 2. Я зарегистрирован на сайте огненного стартапа как работодатель и хочу
-- авторизоваться, чтобы разместить данные о компании, найти работников и
-- посмотреть ответы.
SELECT account_id FROM account
 WHERE login='waterhouse' AND password=crypt('qwerty', password);

-- 3. Я авторизовался на сайте огненного стартапа как работодатель и хочу ввести
-- данные о своей компании, чтобы размещать от ее имени вакансии.
WITH created_employer AS (
  INSERT INTO employer (title)
  VALUES ('Epiphyte Corporation') RETURNING employer_id)
    INSERT INTO employer_account (account_id, employer_id)
    VALUES (12, (SELECT employer_id FROM created_employer));

-- 4. Мы — компания, зарегистрированная на сайте огненного стартапа как
-- работодатель, и хотим разместить вакансию.
-- 4.1 Узнаем id нашей компании
SELECT employer_id FROM employer JOIN employer_account USING (employer_id)
 WHERE account_id = 12 AND employer.title = 'Epiphyte Corporation';
-- 4.2 Создадим вакансию
INSERT INTO vacancy (
  employer_id, title, city_id, salary, experience_years, schedule, vacancy_status)
VALUES (6, 'Java-программист', 1, INT4RANGE(50000, 100000), '1-3', 'FULL_TIME', 'OPEN');

-- 5. Мы — компания, у которой есть открытая вакансия, и хотим найти резюме,
-- которые подходят к этой вакансии, чтобы отправить приглашения.
-- 5.1 Узнаем id нашей вакансии
SELECT vacancy_id FROM vacancy WHERE employer_id = 6;
-- 5.2 Найдет подходящие резюме
SELECT resume_id, applicant.name, resume.experience_years, resume.salary
  FROM vacancy JOIN resume USING (title, city_id, schedule)
         JOIN applicant USING (applicant_id)
 WHERE vacancy_id = 9 AND
       (vacancy.experience_years = 'ANY' OR
       vacancy.experience_years = resume.experience_years) AND
       vacancy.salary && resume.salary;

-- 6. Мы нашли подходящие резюме и хотим отправить приглашения
-- 6.1 Отправляем приглашения
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (5, 9, 'OPEN')
  RETURNING application_id
) INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES (
  (SELECT application_id FROM created_application),
  'Добрый вечер!
Приглашаем Вас пройти тестовое задание на вакансию Java-программист.
Ссылка на задание: https://epiphyte/test',
  FALSE,
  now()
);
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (6, 9, 'OPEN')
  RETURNING application_id
) INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES (
  (SELECT application_id FROM created_application),
  'Добрый вечер!
Приглашаем Вас пройти тестовое задание на вакансию Java-программист.
Ссылка на задание: https://epiphyte/test',
  FALSE,
  now()
);
-- 6.2 Кто-то из соискателей ответил
INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES  (
  9,
  'Добрый вечер!
Вот мое решение тестового задания: https://patrikeevna/reshenie
С нетерпепием жду вашего отклика',
  TRUE,
  now()
);
-- 6.3 Мы также получили отклик на нашу вакансию от соискателя, которому мы
-- приглашения не присылали
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (1, 9, 'OPEN')
  RETURNING application_id
) INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES (
  (SELECT application_id FROM created_application),
  'Добрый вечер!
Прошу рассмотреть мою кандидатуру на должно Java-программист.',
  TRUE,
  now()
);

-- 7. Мы — компания, у которой есть открытая вакансия, и хотим посмотреть
-- отклики на эту вакансию
SELECT application_id, resume_id, message.text
  FROM application JOIN resume USING (resume_id)
         JOIN message USING (application_id)
 WHERE vacancy_id = 9 AND applicant_to_employer;

-- 8. Мы получили отклик на вакансию, и хочу ответить соискателю
INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES  (
  9,
  'Добрый день!
Поздравляем!  Вы приняты!',
  FALSE,
  now()
);

-- 9. Мы наняли нужного нам работника, и хотим закрыть вакансию и все связанные
-- с ней переписки.
BEGIN;
  UPDATE vacancy SET vacancy_status = 'CLOSED' WHERE vacancy_id = 9;
  UPDATE application SET application_status = 'CLOSED' WHERE vacancy_id = 9;
END;
