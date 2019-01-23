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

vacancies_number = employers_number * vacancies_per_employer

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

print("================ CITY ================")
insert_city = "INSERT INTO external_city(name) VALUES (%(name)s)"
for name in cities:
    cur.execute(insert_city, {'name': name})

# Create some name conflicts
insert_old_account = "INSERT INTO account(login, email, password) \
VALUES (%(login)s, %(email)s, crypt(%(password)s, gen_salt('bf')))"
old_accounts = set()
for i in range(500):
    acc_id = 1
    while acc_id in old_accounts:
        acc_id = random.randint(1, employers_number + applicants_number)
    old_accounts.add(acc_id)
for acc_id in old_accounts:
    cur.execute(insert_old_account, {
        'login': 'account%s' % acc_id,
        'email': 'dup_email%s' % acc_id,
        'password': 'password%s' % acc_id
    })

# Generate employers and vacancies
insert_account = "INSERT INTO external_account(login, email, password) \
VALUES (%(login)s, %(email)s, crypt(%(password)s, gen_salt('bf')))"

insert_employer = "INSERT INTO external_employer(title) VALUES (%(title)s)"

insert_employer_account = "INSERT INTO external_employer_account\
(external_employer_id, external_account_id) VALUES (%(employer_id)s, %(account_id)s)"

insert_vacancy = "INSERT INTO external_vacancy\
(external_employer_id, title, external_city_id, salary, experience_years, schedule, description,\
vacancy_status)\
VALUES (%(employer_id)s, %(title)s, %(city_id)s, \
INT4RANGE(%(salary_min)s, %(salary_max)s), %(experience_years)s, %(schedule)s,\
%(description)s, %(vacancy_status)s)"

print("================ EMPLOYER ================")
account_id = 0
vacancy_id = 0
employer_account_id = 0
for employer_id in range(1, 1+employers_number):
    account_id += 1
    cur.execute(insert_account, {
        'login': 'account%d' % account_id,
        'email': '%d@email' % account_id,
        'password': 'password%d' % account_id
    })

    cur.execute(insert_employer, {
        'employer_id': employer_id,
        'title': 'Работодатель %d' % employer_id
    })

    employer_account_id += 1
    cur.execute(insert_employer_account, {
        'employer_id': employer_id,
        'account_id': account_id
    })

    for vacancy_num in range(vacancies_per_employer):
        cur.execute(insert_vacancy, {
            'employer_id': employer_id,
            'title': 'Должность %d' % vacancy_num,
            'city_id': 1 + (employer_id % len(cities)),
            'salary_min': 10000 * (vacancy_num+1),
            'salary_max': 10000 * (vacancy_num+2),
            'experience_years': experience_years[
                vacancy_num % len(experience_years)],
            'schedule': schedule[vacancy_num % len(schedule)],
            'description': 'Вакансия №%d Компании %d' % (vacancy_num, employer_id),
            'vacancy_status': status[vacancy_num % len(status)]
        })

# Generate applicants and resumes
insert_applicant = "INSERT INTO external_applicant (name, external_account_id) \
VALUES (%(name)s, %(account_id)s)"

insert_resume = "INSERT INTO external_resume\
(external_applicant_id, title, external_city_id, salary, experience_years, schedule, text) \
VALUES (%(applicant_id)s, %(title)s, %(city_id)s, \
INT4RANGE(%(salary_min)s, %(salary_max)s), %(experience_years)s, %(schedule)s,\
%(text)s)"

insert_experience = "INSERT INTO external_experience\
(external_resume_id, employer, job_title, job_description, dates) \
VALUES (%(resume_id)s, %(employer)s, %(job_title)s, %(job_description)s, \
DATERANGE(%(start_date)s, %(end_date)s))"

print("================ APPLICANT ================")
resume_id = 0
experience_id = 0
for applicant_id in range(1, 1+applicants_number):
    account_id += 1
    cur.execute(insert_account, {
        'login': 'account%d' % account_id,
        'email': '%d@email' % account_id,
        'password': 'password%d' % account_id
    })

    cur.execute(insert_applicant, {
        'name': 'Соискатель %d' % applicant_id,
        'account_id': account_id
    })

    for resume_num in range(resumes_per_applicant):
        resume_id += 1
        experience = experience_years[
            applicant_id % (len(experience_years) - 1)]
        cur.execute(insert_resume, {
            'applicant_id': applicant_id,
            'title': 'Должность %d' % 2*resume_num,
            'city_id': 1 + (applicant_id % len(cities)),
            'salary_min': 20000 * (resume_num+1),
            'salary_max': 20000 * (resume_num+2),
            'experience_years': experience,
            'schedule': schedule[applicant_id % len(schedule)],
            'text': 'Резюме №%d Соискателя %d' % (resume_num, applicant_id)
        })

        for job_num in range(jobs[experience]):
            experience_id += 1
            cur.execute(insert_experience, {
                'resume_id': resume_id,
                'employer': 'Работодатель %d-%d' % (applicant_id, job_num),
                'job_title': 'Работа %d-%d' % (applicant_id, job_num),
                'job_description': 'Описание работы %d-%d % (applicant_id, job_num)',
                'start_date': start_dates[experience][job_num],
                'end_date': end_dates[experience][job_num]
            })

# Generate applications and messages
insert_application = "INSERT INTO external_application\
(external_resume_id, external_vacancy_id, application_status) \
VALUES (%(resume_id)s, %(vacancy_id)s, %(application_status)s)"

insert_message = "INSERT INTO external_message\
(external_application_id, created, applicant_to_employer, text)\
VALUES (%(application_id)s, %(created)s, %(applicant_to_employer)s, %(text)s)"

print("================ MESSAGE ================")
message_id = 0
for application_id in range(1, 1+applications_number):
    vacancy = random.randint(1, vacancies_number)
    resume = random.randint(1, resume_id)
    cur.execute(insert_application, {
        'resume_id': resume,
        'vacancy_id': vacancy,
        'application_status': status[application_id % 2]
    })
    days_ago = sorted(random.sample(range(365), messages_per_application))
    for message_num in range(messages_per_application):
        message_id += 1
        cur.execute(insert_message, {
            'application_id': application_id,
            'applicant_to_employer': (application_id + message_num) % 2 == 0,
            'text': 'Сообщение %d' % message_id,
            'created':  datetime.now() - timedelta(
                days=sorted(random.sample(range(800), 3))[message_num],
                hours=random.randint(0, 24),
                minutes=random.randint(0, 60),
                seconds=random.randint(0, 60))
        })

tables = ['city', 'account', 'employer', 'employer_account', 'vacancy',
          'applicant', 'resume', 'experience', 'application', 'message']

for table in tables:
    cur.execute("CREATE INDEX external_%s_idx ON external_%s(external_%s_id)" %
                (table, table, table))
conn.commit()

conn.autocommit = True
for table in tables:
    cur.execute('VACUUM ANALYZE external_' + table)
conn.autocommit = False

cur.close()
conn.close()
