DROP TABLE IF EXISTS city_translation;

SELECT city.city_id, external_city.city_id AS ext INTO city_translation
  FROM city RIGHT JOIN external_city USING (name);

ALTER table city_translation ADD PRIMARY KEY (ext);

UPDATE city_translation
   SET city_id = nextval('external_city_seq') WHERE city_id is NULL;
