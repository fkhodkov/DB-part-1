-- After first pass
CREATE INDEX CONCURRENTLY IF NOT EXISTS applicant_account_idx ON applicant(account_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS application_resume_idx ON application(resume_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS application_vacancy_idx ON application(vacancy_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS message_application_idx ON message(application_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS resume_applicant_idx ON resume(applicant_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS resume_city_idx ON resume(city_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS resume_experience_idx ON resume(experience_years);
CREATE INDEX CONCURRENTLY IF NOT EXISTS resume_salary_idx ON resume(salary);
CREATE INDEX CONCURRENTLY IF NOT EXISTS resume_schedule_idx ON resume(schedule);
CREATE INDEX CONCURRENTLY IF NOT EXISTS resume_title_idx ON resume(title);
CREATE INDEX CONCURRENTLY IF NOT EXISTS vacancy_city_idx ON vacancy(city_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS vacancy_employer_idx ON vacancy(employer_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS vacancy_experience_idx ON vacancy(experience_years);
CREATE INDEX CONCURRENTLY IF NOT EXISTS vacancy_salary_idx ON vacancy(salary);
CREATE INDEX CONCURRENTLY IF NOT EXISTS vacancy_schedule_idx ON vacancy(schedule);
CREATE INDEX CONCURRENTLY IF NOT EXISTS vacancy_title_idx ON vacancy(title);

-- After second pass
CREATE INDEX CONCURRENTLY IF NOT EXISTS resume_query_idx
  ON resume(city_id, experience_years, salary, schedule, title);
CREATE INDEX CONCURRENTLY IF NOT EXISTS vacancy_query_idx
  ON vacancy(city_id, experience_years, salary, schedule, title);


VACUUM ANALYZE applicant;
VACUUM ANALYZE application;
VACUUM ANALYZE message;
VACUUM ANALYZE resume;
VACUUM ANALYZE vacancy;

