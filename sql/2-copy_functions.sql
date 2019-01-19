DROP FUNCTION IF EXISTS copy_city;
CREATE FUNCTION copy_city(starting INTEGER) RETURNS VOID AS $$
  DECLARE
  matching RECORD;
  id_off INTEGER;
BEGIN
  id_off := (SELECT id_offset FROM external_volumes WHERE table_name = 'city');
  FOR matching IN (
    SELECT city_translation.city_id, name
      FROM external_city JOIN city_translation ON external_city.city_id = city_translation.ext
     WHERE external_city.city_id > starting AND external_city.city_id <= starting + 10000
       AND city_translation.city_id > id_off)
  LOOP
    INSERT INTO city
    VALUES (
      matching.city_id,
      matching.name
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS copy_employer_account;
CREATE FUNCTION copy_employer_account(starting INTEGER) RETURNS VOID AS $$
  DECLARE
  matching RECORD;
  employer_offset INTEGER;
  account_offset INTEGER;
BEGIN
  employer_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'employer');
  account_offset := (SELECT id_offset FROM external_volumes WHERE table_name = 'account');
  FOR matching IN (
    SELECT *
      FROM external_employer_account
     WHERE employer_account_id > starting AND employer_account_id <= starting + 10000)
  LOOP
    INSERT INTO employer_account
    VALUES (
      (matching.employer_id + employer_offset),
      (matching.account_id + account_offset)
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;
