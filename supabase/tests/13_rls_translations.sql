BEGIN;
SELECT plan(3);

INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000500');
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000501');
UPDATE profiles SET role = 'field_user' WHERE id = '00000000-0000-0000-0000-000000000500';
UPDATE profiles SET role = 'admin' WHERE id = '00000000-0000-0000-0000-000000000501';

INSERT INTO translations (id, key, locale, value) VALUES ('00000000-0000-0000-0000-000000000502', 'test.key', 'en', 'Test value');

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "00000000-0000-0000-0000-000000000500"}';

SELECT results_eq(
  'SELECT key FROM translations',
  ARRAY['test.key'::text],
  'Field user can read translations'
);

SELECT throws_ok(
  'INSERT INTO translations (id, key, locale, value) VALUES (''00000000-0000-0000-0000-000000000503'', ''test.key2'', ''en'', ''Test value 2'')',
  '42501',
  NULL,
  'Field user cannot write translations'
);

SET LOCAL request.jwt.claims TO '{"sub": "00000000-0000-0000-0000-000000000501"}';

SELECT lives_ok(
  'INSERT INTO translations (id, key, locale, value) VALUES (''00000000-0000-0000-0000-000000000504'', ''test.key3'', ''en'', ''Test value 3'')',
  'Admin can write translations'
);

SELECT * FROM finish();
ROLLBACK;
