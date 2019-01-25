\pset pager off

-- Часть II. «Работодатель»
CREATE SEQUENCE IF NOT EXISTS scenario2_employer_seq;

-- 1. Я ищу сотрудников и хочу зарегистрироваться на сайте огненного стартапа
-- как работодатель, чтобы размещать вакансии и искать резюме.
EXPLAIN ANALYZE
INSERT INTO account (login, email, password)
VALUES (
  (SELECT 'waterhouse' || nextval('scenario2_employer_seq')),
  'waterhouse@epiphyte',
  crypt('qwerty', gen_salt('bf')));

-- 2. Я зарегистрирован на сайте огненного стартапа как работодатель и хочу
-- авторизоваться, чтобы разместить данные о компании, найти работников и
-- посмотреть ответы.
EXPLAIN ANALYZE
SELECT account_id FROM account
 WHERE login='waterhouse1'
   AND password=crypt('qwerty', password);

-- 3. Я авторизовался на сайте огненного стартапа как работодатель и хочу ввести
-- данные о своей компании, чтобы размещать от ее имени вакансии.
EXPLAIN ANALYZE
WITH created_employer AS (
  INSERT INTO employer (title)
  VALUES ('Epiphyte Corporation') RETURNING employer_id)
    INSERT INTO employer_account (account_id, employer_id)
    VALUES (
      (SELECT account_id FROM account
        WHERE login='waterhouse1'
          AND password=crypt('qwerty', password)),
      (SELECT employer_id FROM created_employer));

-- 4. Мы — компания, зарегистрированная на сайте огненного стартапа как
-- работодатель, и хотим разместить вакансию.
-- 4.1 Узнаем id нашей компании
EXPLAIN ANALYZE
SELECT employer_id, title
  FROM employer JOIN employer_account USING (employer_id)
 WHERE account_id = (SELECT account_id FROM account
                      WHERE login='waterhouse1'
                        AND password=crypt('qwerty', password));
-- 4.2 Создадим вакансию
EXPLAIN ANALYZE
INSERT INTO vacancy (
  employer_id, title, city_id, salary, experience_years, schedule, vacancy_status)
VALUES (
  100007,
  'Java-программист',
  1, INT4RANGE(50000, 100000),
  '1-3',
  'FULL_TIME',
  'OPEN'
);

-- 5. Мы — компания, у которой есть открытая вакансия, и хотим найти резюме,
-- которые подходят к этой вакансии, чтобы отправить приглашения.
-- 5.1 Узнаем id нашей вакансии
EXPLAIN ANALYZE
SELECT vacancy_id, title
  FROM vacancy
 WHERE employer_id = 100007;
-- 5.2 Найдет подходящие резюме
EXPLAIN ANALYZE
WITH my_vacancy AS (
  SELECT title, city_id, schedule, salary, experience_years
    FROM vacancy WHERE vacancy_id = 1000010)
SELECT resume_id, applicant.name, resume.experience_years, resume.salary
  FROM resume JOIN applicant USING (applicant_id)
 WHERE resume.title = (SELECT title FROM my_vacancy) AND
       resume.city_id = (SELECT city_id FROM my_vacancy) AND
       resume.schedule = (SELECT schedule FROM my_vacancy) AND
       resume.experience_years = (SELECT experience_years FROM my_vacancy) AND
       resume.salary && (SELECT salary FROM my_vacancy);

-- 6. Мы нашли подходящие резюме и хотим отправить приглашения
-- 6.1 Отправляем приглашения
EXPLAIN ANALYZE
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (5, 1000010, 'OPEN')
  RETURNING application_id
) SELECT application_id
    FROM created_application;
EXPLAIN ANALYZE
INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES (
  5000015,
  'Добрый вечер!
Приглашаем Вас пройти тестовое задание на вакансию Java-программист.
Ссылка на задание: https://epiphyte/test',
  FALSE,
  now()
);

EXPLAIN ANALYZE
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (6, 1000010, 'OPEN')
  RETURNING application_id
) SELECT application_id
    FROM created_application;
EXPLAIN ANALYZE
INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES (
  5000017,
  'Добрый вечер!
Приглашаем Вас пройти тестовое задание на вакансию Java-программист.
Ссылка на задание: https://epiphyte/test',
  FALSE,
  now()
);

-- 6.2 Кто-то из соискателей ответил
EXPLAIN ANALYZE
INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES  (
  5000015,
  'Добрый вечер!
Вот мое решение тестового задания: https://patrikeevna/reshenie
С нетерпепием жду вашего отклика',
  TRUE,
  now()
);

-- 6.3 Мы также получили отклик на нашу вакансию от соискателя, которому мы
-- приглашения не присылали
EXPLAIN ANALYZE
WITH created_application AS (
  INSERT INTO application (resume_id, vacancy_id, application_status)
  VALUES (1, 1000010, 'OPEN')
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
EXPLAIN ANALYZE
SELECT application_id, resume_id, message.text
  FROM application JOIN resume USING (resume_id)
         JOIN message USING (application_id)
 WHERE vacancy_id = 1000010 AND applicant_to_employer;

-- 8. Мы получили отклик на вакансию, и хочу ответить соискателю
EXPLAIN ANALYZE
INSERT INTO message (
  application_id, text, applicant_to_employer, created
) VALUES  (
  5000015,
  'Добрый день!
Поздравляем!  Вы приняты!',
  FALSE,
  now()
);

-- 9. Мы наняли нужного нам работника, и хотим закрыть вакансию и все связанные
-- с ней переписки.
BEGIN;
  EXPLAIN ANALYZE
  UPDATE vacancy SET vacancy_status = 'CLOSED'
   WHERE vacancy_id = 1000010;
  EXPLAIN ANALYZE
  UPDATE application SET application_status = 'CLOSED'
   WHERE vacancy_id = 1000010;
END;
