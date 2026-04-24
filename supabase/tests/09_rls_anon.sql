BEGIN;
SELECT plan(4);

-- Test table reads (should throw or return 0, but since RLS is active, it just returns 0)
SET LOCAL ROLE anon;

SELECT is(
  (SELECT count(*) FROM visits)::int,
  0,
  'Anon cannot read visits'
);

SELECT is(
  (SELECT count(*) FROM profiles)::int,
  0,
  'Anon cannot read profiles'
);

SELECT throws_ok(
  'INSERT INTO visits (id, client_uuid, country_id, core_area_id, activity_id) VALUES (''00000000-0000-0000-0000-000000000900'', ''00000000-0000-0000-0000-000000000901'', ''00000000-0000-0000-0000-000000000012'', ''00000000-0000-0000-0000-000000000010'', ''00000000-0000-0000-0000-000000000011'')',
  '42501',
  'new row violates row-level security policy for table "visits"',
  'Anon cannot insert visits'
);

SELECT throws_ok(
  'UPDATE profiles SET first_name = ''Test''',
  '42501',
  NULL,
  'Anon cannot update profiles'
);

SELECT * FROM finish();
ROLLBACK;
