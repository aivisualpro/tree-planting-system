BEGIN;
SELECT plan(1);
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000200');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "00000000-0000-0000-0000-000000000200"}';

SELECT throws_ok(
  'INSERT INTO countries (code, name_en) VALUES (''US'', ''USA'')',
  '42501',
  'new row violates row-level security policy for table "countries"',
  'Field user cannot insert into countries'
);
SELECT * FROM finish();
ROLLBACK;
