DROP TABLE IF EXISTS duplicate_logins;

CREATE TABLE duplicate_logins (
  account_id INTEGER PRIMARY KEY,
  old_login VARCHAR(100) NOT NULL
);

DROP INDEX IF EXISTS login_idx;
CREATE INDEX login_idx ON account(login);
VACUUM ANALYZE account;

DROP FUNCTION IF EXISTS external_unique_login;
CREATE FUNCTION external_unique_login (account_id INTEGER, old_login TEXT) RETURNS TEXT AS $$
  DECLARE
  new_login TEXT;
  additional INTEGER;
BEGIN
  IF (SELECT EXISTS (SELECT 1 FROM account WHERE login = old_login)) THEN
    INSERT INTO duplicate_logins (account_id, old_login)
    VALUES (account_id, old_login);
    additional := 0;
    new_login := '@ext_login' || account_id || '_' || additional;
    WHILE (SELECT EXISTS (SELECT 1 FROM account WHERE login = new_login)) LOOP
      additional := additional + 1;
    END loop;
    RETURN new_login;
  ELSE 
    RETURN old_login;
  END IF;
END;
$$ LANGUAGE plpgsql;
