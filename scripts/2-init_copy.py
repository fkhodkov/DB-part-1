import sys
import psycopg2

dbname = sys.argv[1]
conn = psycopg2.connect('dbname=%s' % dbname)
cur = conn.cursor()

tables = ['city', 'account', 'employer', 'employer_account', 'vacancy',
          'applicant', 'resume', 'experience', 'application', 'message']

cur.execute("DROP TABLE IF EXISTS external_volumes")
cur.execute("CREATE TABLE external_volumes" +
            "(table_name VARCHAR(50) PRIMARY KEY," +
            "volume INTEGER, id_offset INTEGER)")

insert = "INSERT INTO external_volumes VALUES (%s, %s)"
for table in tables:
    select = "SELECT count(%s_id) from external_%s" % (table, table)
    cur.execute(select)
    (volume,) = cur.fetchone()
    cur.execute(insert, (table, volume))
conn.commit()

for table in tables:
    if table == 'employer_account':
        continue
    cur.execute("SELECT last_value INTO TEMP %s_tmp FROM %s_%s_id_seq" %
                ((table,) * 3))
    cur.execute("SELECT setval('%s_%s_id_seq'," % (table, table) +
                "(SELECT last_value FROM %s_tmp) +" % table +
                "(SELECT volume FROM external_volumes WHERE table_name = %s))",
                (table,))
    cur.execute("UPDATE external_volumes SET id_offset =" +
                "(SELECT last_value FROM %s_tmp)" % table +
                "WHERE table_name = %s", (table,))
    cur.execute("DROP SEQUENCE IF EXISTS external_%s_seq" % table)
    cur.execute("CREATE SEQUENCE external_%s_seq" % table)
    cur.execute("SELECT setval('external_%s_seq'," % table +
                "(SELECT last_value from %s_tmp))" % table)
conn.commit()

cur.close()
conn.close()
