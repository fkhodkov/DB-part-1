import sys
import psycopg2

dbname = sys.argv[1]
conn = psycopg2.connect('dbname=%s' % dbname)
cur = conn.cursor()

N = 10000

tables = [
    {'name': 'account', 'columns': ['login', 'email', 'password']},
    {'name': 'employer', 'columns': ['title']},
    {'name': 'vacancy',
     'columns': [
         'employer_id', 'title', 'city_id', 'salary', 'experience_years',
         'schedule', 'description', 'vacancy_status']},
    {'name': 'applicant', 'columns': ['name', 'account_id']},
    {'name': 'resume',
     'columns': [
         'applicant_id', 'title', 'city_id', 'salary', 'experience_years',
         'schedule', 'text']},
    {'name': 'experience',
     'columns': [
         'resume_id', 'employer', 'job_title', 'job_description', 'dates']},
    {'name': 'application',
     'columns': ['resume_id', 'vacancy_id', 'application_status']},
    {'name': 'message',
     'columns': ['application_id', 'created', 'applicant_to_employer', 'text']}
]

for table in tables:
    name = table["name"]
    cur.execute("DROP FUNCTION IF EXISTS copy_%s" % name)
    function = [
        "CREATE FUNCTION copy_%s(starting INTEGER) RETURNS void AS $$" % name
    ]
    declare = ["matching record;"]
    assignments = []
    values = ["nextval('external_%s_seq')" % name]
    for column in table["columns"]:
        if column == 'city_id':
            values.append("(SELECT city_id FROM city_translation " +
                          "WHERE ext = matching.city_id)")
        elif column[-3:] == '_id':
            declare.append("%s_offset INTEGER;" % column[:-3])
            assignments.append(
                "%s_offset := (SELECT id_offset FROM external_volumes WHERE table_name = '%s');" %
                ((column[:-3],) * 2))
            values.append("matching.%s + %s_offset" % (column, column[:-3]))
        else:
            values.append("matching.%s" % column)
    function.append("DECLARE " + "".join(declare))
    function.append("BEGIN")
    function.append("".join(assignments))
    function.append("FOR matching IN (SELECT * from external_%s " % name +
                    "WHERE %s_id > starting AND %s_id <= starting + %d)" %
                    (name, name, N) +
                    "LOOP")
    function.append("INSERT INTO %s" % name)
    function.append("VALUES (%s);" % ",".join(values))
    function.append("END LOOP;")
    function.append("END;")
    function.append("$$ LANGUAGE plpgsql;")
    cur.execute(" ".join(function))
    conn.commit()

cur.close()
conn.close()

# DROP FUNCTION IF EXISTS copy_vacancy;
# CREATE FUNCTION copy_vacancy(starting INTEGER) RETURNS void AS $$
#   DECLARE
#   matching RECORD;
#   employer_offset INTEGER;
# BEGIN
#   employer_offset := SELECT id_offset WHERE table_name = 'employer';
#   FOR matching IN (
#     SELECT *
#       FROM external_vacancy
#      WHERE vacancy_id > starting AND vacancy_id <= starting + 10000
#   ) LOOP
#     INSERT INTO vacancy
#     VALUES (
#       nextval('external_vacancy_id_seq'),
#       matching.employer_id + employer_offset,
#       matching.title,
#       (SELECT city_id FROM city_translation WHERE ext = matching.city_id),
#       matching.salary,
#       matching.experience_years,
#       matching.schedule,
#       matching.description,
#       matching.vacancy_status
#     );
#   END LOOP;
# END;
# $$ LANGUAGE plpgsql;
