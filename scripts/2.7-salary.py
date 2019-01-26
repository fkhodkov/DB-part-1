import sys
import psycopg2

dbname = sys.argv[1]
conn = psycopg2.connect('dbname=%s' % dbname)
cur = conn.cursor()

N = 10000

cur.execute('ALTER TABLE resume ADD COLUMN IF NOT EXISTS salary_min INTEGER')
cur.execute('ALTER TABLE resume ADD COLUMN IF NOT EXISTS salary_max INTEGER')
cur.execute('ALTER TABLE vacancy ADD COLUMN IF NOT EXISTS salary_min INTEGER')
cur.execute('ALTER TABLE vacancy ADD COLUMN IF NOT EXISTS salary_max INTEGER')
conn.commit()

cur.execute('SELECT count(*) from resume')
(resume_qty,) = cur.fetchone()
cur.execute('SELECT count(*) from vacancy')
(vacancy_qty,) = cur.fetchone()

for start in range(0, resume_qty+1, N):
    print('resume', start)
    cur.execute('''UPDATE resume
   SET salary_min = lower(resume.salary), salary_max = upper(resume.salary)
 WHERE resume_id >= %s and resume_id < %s''',
        (start, start + N))
    conn.commit()


for start in range(0, vacancy_qty+1, N):
    print('vacancy', start)
    cur.execute('''UPDATE vacancy
   SET salary_min = lower(vacancy.salary), salary_max = upper(vacancy.salary)
 WHERE vacancy_id >= %s and vacancy_id < %s''',
                (start, start + N))
    conn.commit()

cur.close()
conn.close()
