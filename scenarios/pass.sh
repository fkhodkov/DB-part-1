#!/bin/sh
DB_NAME=hh_homework
psql ${DB_NAME} -e -f 2.1-seeker.sql
psql ${DB_NAME} -e -f 2.2-employer.sql
