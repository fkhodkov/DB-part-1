import sys
import psycopg2
import random
from datetime import datetime, timedelta

dbname = sys.argv[1]
conn = psycopg2.connect('dbname=%s' % dbname)
cur = conn.cursor()

employers_number = 100000
vacancies_per_employer = 10

applicants_number = 1000000
resumes_per_applicant = 3

applications_number = 5000000
messages_per_application = 3

experience_years = ['0-1', '1-3', '3-6', '6+', 'ANY']
jobs = {'0-1': 1, '1-3': 1, '3-6': 2, '6+': 3}
start_dates = {
    '0-1': ['2018-07-01'],
    '1-3': ['2017-03-01'],
    '3-6': ['2014-05-01', '2017-02-01'],
    '6+': ['2011-08-01', '2014-04-01', '2016-09-01']
}
end_dates = {
    '0-1': [None],
    '1-3': [None],
    '3-6': ['2017-01-31', None],
    '6+': ['2014-03-31', '2016-08-31', None]
}

schedule = ['FULL_TIME', 'PART_TIME', 'FLEXIBLE', 'REMOTE']
status = ['OPEN', 'CLOSED']

cities = ['Москва', 'Санкт-Петербург', 'Владивосток', 'Челябинск', 'Нью-Йорк',
          'Красногорск', 'Истра', 'Дедовск', 'Сочи', 'Нахабино']

insert_city = "INSERT INTO external_city(city_id, name) \
VALUES (%(city_id)s, %(name)s)"
for city_id, name in enumerate(cities):
    cur.execute(insert_city, {'city_id': city_id, 'name': name})

conn.commit()

# Generate employers and vacancies
insert_account = "INSERT INTO external_account(account_id, login, email, password) \
VALUES (%(account_id)s, %(login)s, %(email)s, crypt(%(password)s, gen_salt('bf')))"

insert_employer = "INSERT INTO external_employer(employer_id, title) \
VALUES (%(employer_id)s, %(title)s)"

insert_employer_account = "INSERT INTO external_employer_account\
(employer_id, account_id) \
VALUES (%(employer_id)s, %(account_id)s)"

insert_vacancy = "INSERT INTO external_vacancy\
(vacancy_id, employer_id, title, city_id, salary, experience_years, schedule,\
description, vacancy_status)\
VALUES (%(vacancy_id)s, %(employer_id)s, %(title)s, %(city_id)s, \
INT4RANGE(%(salary_min)s, %(salary_max)s), %(experience_years)s, %(schedule)s,\
%(description)s, %(vacancy_status)s)"

account_id = 0
vacancy_id = 0
for employer_id in range(1, 1+employers_number):
    account_id += 1
    cur.execute(insert_account, {
        'account_id': account_id,
        'login': 'account%d' % account_id,
        'email': '%d@email' % account_id,
        'password': 'password%d' % account_id
    })

    cur.execute(insert_employer, {
        'employer_id': employer_id,
        'title': 'Работодатель %d' % employer_id
    })

    cur.execute(insert_employer_account, {
        'employer_id': account_id,
        'account_id': employer_id
    })

    for vacancy_num in range(vacancies_per_employer):
        vacancy_id += 1
        cur.execute(insert_vacancy, {
            'vacancy_id': vacancy_id,
            'employer_id': employer_id,
            'title': 'Должность %d' % vacancy_num,
            'city_id': employer_id % len(cities),
            'salary_min': 10000 * (vacancy_num+1),
            'salary_max': 10000 * (vacancy_num+2),
            'experience_years': experience_years[
                vacancy_num % len(experience_years)],
            'schedule': schedule[vacancy_num % len(schedule)],
            'description': 'Вакансия №%d Компании %d' % (vacancy_num, employer_id),
            'vacancy_status': status[vacancy_num % len(status)]
        })

    conn.commit()

# Generate applicants and resumes
insert_applicant = "INSERT INTO external_applicant\
(applicant_id, name, account_id) \
VALUES (%(applicant_id)s, %(name)s, %(account_id)s)"

insert_resume = "INSERT INTO external_resume\
(resume_id, applicant_id, title, city_id, salary,\
experience_years, schedule, text) \
VALUES (%(resume_id)s, %(applicant_id)s, %(title)s, %(city_id)s, \
INT4RANGE(%(salary_min)s, %(salary_max)s), %(experience_years)s, %(schedule)s,\
%(text)s)"

insert_experience = "INSERT INTO external_experience\
(experience_id, resume_id, employer, job_title, job_description, dates) \
VALUES (%(experience_id)s, %(resume_id)s, %(employer)s, %(job_title)s,\
%(job_description)s, DATERANGE(%(start_date)s, %(end_date)s))"

resume_id = 0
experience_id = 0
for applicant_id in range(1, 1+applicants_number):
    account_id += 1
    cur.execute(insert_account, {
        'account_id': account_id,
        'login': 'account%d' % account_id,
        'email': '%d@email' % account_id,
        'password': 'password%d' % account_id
    })

    applicant_id += 1
    cur.execute(insert_applicant, {
        'applicant_id': applicant_id,
        'name': 'Соискатель %d' % applicant_id,
        'account_id': account_id
    })

    for resume_num in range(resumes_per_applicant):
        resume_id += 1
        experience = experience_years[
            applicant_id % (len(experience_years) - 1)]
        cur.execute(insert_resume, {
            'resume_id': resume_id,
            'applicant_id': applicant_id,
            'title': 'Должность %d' % 2*resume_num,
            'city_id': applicant_id % len(cities),
            'salary_min': 20000 * (resume_num+1),
            'salary_max': 20000 * (resume_num+2),
            'experience_years': experience,
            'schedule': schedule[applicant_id % len(schedule)],
            'text': 'Резюме №%d Соискателя %d' % (resume_num, applicant_id)
        })

        for job_num in range(jobs[experience]):
            experience_id += 1
            cur.execute(insert_experience, {
                'experience_id': experience_id,
                'resume_id': resume_id,
                'employer': 'Работодатель %d-%d' % (applicant_id, job_num),
                'job_title': 'Работа %d-%d' % (applicant_id, job_num),
                'job_description': 'Описание работы %d-%d % (applicant_id, job_num)',
                'start_date': start_dates[experience][job_num],
                'end_date': end_dates[experience][job_num]
            })

    conn.commit()

# Generate applications and messages
insert_application = "INSERT INTO external_application\
(application_id, resume_id, vacancy_id, application_status) \
VALUES (%(application_id)s, %(resume_id)s, %(vacancy_id)s,\
%(application_status)s)"

insert_message = "INSERT INTO external_message\
(message_id, application_id, created, applicant_to_employer, text)\
VALUES (%(message_id)s, %(application_id)s, %(created)s,\
%(applicant_to_employer)s, %(text)s)"

message_id = 0
for application_id in range(1, 1+applications_number):
    vacancy = random.randint(1, vacancy_id)
    resume = random.randint(1, resume_id)
    cur.execute(insert_application, {
        'application_id': application_id,
        'resume_id': resume,
        'vacancy_id': vacancy,
        'application_status': status[application_id % 2]
    })
    days_ago = sorted(random.sample(range(365), messages_per_application))
    for message_num in range(messages_per_application):
        message_id += 1
        cur.execute(insert_message, {
            'message_id': message_id,
            'application_id': application_id,
            'applicant_to_employer': (application_id + message_num) % 2 == 0,
            'text': 'Сообщение %d' % message_id,
            'created':  datetime.now() - timedelta(
                days=sorted(random.sample(range(800), 3))[message_num],
                hours=random.randint(0, 24),
                minutes=random.randint(0, 60),
                seconds=random.randint(0, 60))
        })

    conn.commit()

cur.close()
conn.close()
