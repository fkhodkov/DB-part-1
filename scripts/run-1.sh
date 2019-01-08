#!/bin/sh
DB_NAME=hh_homework
psql ${DB_NAME} -f sql/1-createdb.sql
psql ${DB_NAME} -f sql/1-filldb.sql
psql ${DB_NAME} -f scenarios/1.1-seeker.sql
psql ${DB_NAME} -f scenarios/1.2-employer.sql
psql ${DB_NAME} -f sql/2-generate_tables.sql
python3 scripts/2-fill_tables.py ${DB_NAME}

