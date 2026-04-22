BEGIN;
SELECT plan(1);
INSERT INTO countries (id, code, name_en, version) VALUES ('00000000-0000-0000-0000-000000000400', 'ZZ', 'ZZ', 1);
UPDATE countries SET name_en = 'ZZZ' WHERE id = '00000000-0000-0000-0000-000000000400';
SELECT results_eq(
  'SELECT version FROM countries WHERE id = ''00000000-0000-0000-0000-000000000400''',
  ARRAY[2],
  'Version bumped on update'
);
SELECT * FROM finish();
ROLLBACK;
