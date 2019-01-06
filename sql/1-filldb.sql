TRUNCATE employer CASCADE;
ALTER SEQUENCE employer_employer_id_seq RESTART WITH 1;

TRUNCATE applicant CASCADE;
ALTER SEQUENCE applicant_applicant_id_seq RESTART WITH 1;

TRUNCATE employer CASCADE;
ALTER SEQUENCE resume_resume_id_seq RESTART WITH 1;

TRUNCATE employer CASCADE;
ALTER SEQUENCE vacancy_vacancy_id_seq RESTART WITH 1;

TRUNCATE application CASCADE;
ALTER SEQUENCE application_application_id_seq RESTART WITH 1;

INSERT INTO employer(
  title,
  email,
  password
) VALUES
  ('Ромашка', 'romashka@email', crypt('12345', gen_salt('bf'))),
  ('Лютик', 'lyutik@email', crypt('abcde', gen_salt('bf'))),
  ('Березка', 'berezka@email', crypt('p455w0rd', gen_salt('bf'))),
  ('Рога и копыта', 'roga-i-kopyta@email', crypt('    ', gen_salt('bf'))),
  ('ООО ЕПРСТ-Инвест', 'eprst-invest@email', crypt('qwerty', gen_salt('bf')))
;

INSERT INTO applicant(
  name,
  email,
  password
) VALUES
  ('Василий Иванович Пупкин', 'pupkine@email', crypt('12345', gen_salt('bf'))),
  ('Мария Петровна Сидорова', 'sidorowa@email', crypt('abcde', gen_salt('bf'))),
  ('Михайло Потапович Топтыгин', 'toptygin@email', crypt('p455w0rd', gen_salt('bf'))),
  ('Лиса Патрикеевна Рыжая', 'patrikeevna@email', crypt('    ', gen_salt('bf'))),
  ('Максим Максимович Исаев', 'isaev@email', crypt('qwerty', gen_salt('bf')))
;

INSERT INTO city(name)
VALUES
('Москва'),
('Тула'),
('Челябинск'),
('Красногорск'),
('Черноморск'),
('Берлин')
;

INSERT INTO vacancy(
  employer_id,
  title,
  city_id,
  salary,
  expyears_key,
  schedule,
  description
) VALUES
    (1, 'Менеджер по продажам', 1, INT4RANGE(25000, 35000), '1-3', 'FULL_TIME',
    'Лучший в мире менеджер по продажам для лучшей в мире компании!'),
    (1, 'Генеральный директор', 1, INT4RANGE(150000, 200000), '3-6', 'FULL_TIME',
    'Лучший в мире генеральный директор для лучшей в мире компании!'),
    (1, 'Курьер', 2, NULL, 'ANY', 'FLEXIBLE',
    'Лучший в мире курьер для лучшей в мире компании!
График свободный, оплата сдельная'),
    (2, 'Java-программист', 1, INT4RANGE(75000, 120000), '1-3', 'FULL_TIME',
    'Проектирование и разработка высоконагруженных и отказоустойчивых систем.
Знание Java, SQL (умение писать сложные запросы), Python обязательны.
Желательно знать что-то из набора: Perl, PHP, C++.
Наличие open-source разработок в портфолио будет плюсом.'),
    (2, 'Программист C++', 3, INT4RANGE(NULL, 130000), '1-3', 'FULL_TIME',
    'Хорошее знание STL, SQL (опыт работы с PostgreSQL желателен)')
;

INSERT INTO resume(
  applicant_id,
  title,
  city_id,
  salary,
  experience_years,
  schedule
) VALUES
    (1, 'Менеджер по продажам', 1, INT4RANGE(25000, 35000), 1, 'FULL_TIME'),
    (1, 'Курьер', 1, INT4RANGE(15000, NULL), 1, 'PART_TIME'),
    (2, 'Java-программист', 4, INT4RANGE(50000, NULL), 1, 'FULL_TIME'),
    (3, 'Генеральный директор', 1, INT4RANGE(250000, 300000), 5, 'FULL_TIME'),
    (4, 'Java-программист', 1, INT4RANGE(75000, 120000), 3, 'FULL_TIME'),
    (2, 'Java-программист', 1, INT4RANGE(50000, NULL), 1, 'FULL_TIME')
;

INSERT INTO experience(
  resume_id,
  employer,
  job_title,
  dates
) VALUES
(1, 'ООО Березка', 'Курьер', DATERANGE('2016-09-01', '2017-11-01')),
(1, 'ООО Березка', 'Менеджер по продажам', DATERANGE('2017-11-01', NULL)),
(2, 'ООО Березка', 'Курьер', DATERANGE('2016-09-01', '2017-11-01')),
(2, 'ООО Березка', 'Менеджер по продажам', DATERANGE('2017-11-01', NULL)),
(3, 'ЗАО АБВГДБанк', 'Программист JAVA', DATERANGE('2017-04-01', '2018-12-31')),
(4, 'ЗАО Темный лес', 'Зам. руководителя департамента меда', DATERANGE('2013-03-01', '2015-08-15')),
(4, 'ЗАО Темный лес', 'Руководитель департамента меда', DATERANGE('2015-08-16', NULL)),
(4, 'ЗАО Темный лес', 'Программист JavaScript', DATERANGE('2015-05-01', NULL))
;

INSERT INTO application(
  resume_id,
  vacancy_id,
  status
) VALUES
    (1, 1, 'INTERVIEW_INVITED'),
    (4, 2, 'REJECTED'),
    (5, 4, 'NOT_RESPONDED'),
    (2, 3, 'REJECTED'),
    (3, 4, 'NOT_RESPONDED')
;

INSERT INTO message(
  application_id,
  text,
  applicant_to_employer,
  created
) VALUES
    (1,
    'Привет!
Возьмите меня к себе менеджером по продажам.
Вася',
    TRUE,
    '2019-01-01 10:00:00'
    ),
    (2,
    'Добрый вечер, коллеги.
Прошу рассмотреть мою кандидатуру на должность гендира Вашей компании
С уважением, Топтыгин М. П.',
    TRUE,
    '2019-01-01 11:00:00'),
    (3,
    '',
    TRUE,
    '2019-01-01 12:00:00'),
    (4,
    'Привет!
Возьмите меня к себе курьером.
Вася',
    TRUE,
    '2019-01-01 13:00:00'
    ),
    (1,
    'Привет, Вася!
Приходи в четверг на собеседование.
Ромашкин Р. Р.',
    FALSE,
    '2019-01-02 10:00:00'),
    (2,
    'Добрый день, Михайло Потапович!
К сожалению, мы вынуждены Вам отказать.
Вряд ли мы сможем удовлетворить Ваши финансовые запросы :(.
Ромашкин Р. Р.',
    FALSE,
    '2019-01-02 11:00:00'),
    (4,
    'Привет, Вася!
Нам курьер в Туле нужен, а не в Москве.
Ромашкин Р. Р.',
    FALSE,
    '2019-01-02 12:00:00'
    )
;
