#!/bin/sh
DB_NAME=hh_homework
psql ${DB_NAME} -f sql/1-createdb.sql
psql ${DB_NAME} -f sql/1-filldb.sql
psql ${DB_NAME} -f scenarios/1.1-seeker.sql
psql ${DB_NAME} -f scenarios/1.2-employer.sql
psql ${DB_NAME} -f sql/2.1-generate_tables.sql
python3 scripts/2.2-generate_data.py ${DB_NAME}
psql ${DB_NAME} -f sql/2.3-create_mapping.sql
psql ${DB_NAME} -f sql/2.3.1-duplicate_logins.sql
psql ${DB_NAME} -f sql/2.4-copy_functions.sql
python3 scripts/2.5-copy_data.py ${DB_NAME}
