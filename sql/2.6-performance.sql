CREATE INDEX CONCURRENTLY IF NOT EXISTS applicant_account_idx ON applicant(account_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS application_resume_idx ON application(resume_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS application_vacancy_idx ON application(vacancy_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS message_application_idx ON message(application_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS vacancy_gin_idx
    ON vacancy
 USING GIN(vacancy_id, employer_id, title, city_id, experience_years,
           schedule, description, vacancy_status);

CREATE INDEX CONCURRENTLY IF NOT EXISTS resume_gin_idx
    ON resume
 USING GIN(resume_id, applicant_id, title, city_id, experience_years,
           schedule, text);


VACUUM ANALYZE applicant;
VACUUM ANALYZE application;
VACUUM ANALYZE message;
VACUUM ANALYZE resume;
VACUUM ANALYZE vacancy;
