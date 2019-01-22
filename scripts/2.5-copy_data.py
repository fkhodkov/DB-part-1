import sys
import psycopg2

dbname = sys.argv[1]
conn = psycopg2.connect('dbname=%s' % dbname)
cur = conn.cursor()

tables = ['city', 'account', 'employer', 'employer_account', 'vacancy',
          'applicant', 'resume', 'experience', 'application', 'message']

N = 10000

for table in tables:
    print("===== TABLE: ", table, "=====")
    cur.execute(
        "SELECT volume FROM external_volumes WHERE table_name=%s",
        (table,))
    (volume,) = cur.fetchone()
    for start in range(0, volume + 1, N):
        cur.execute("SELECT copy_%s(%d)" % (table, start))
        conn.commit()

cur.close()
conn.close()
