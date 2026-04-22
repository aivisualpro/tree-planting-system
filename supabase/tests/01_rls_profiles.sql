BEGIN;
SELECT plan(1);
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000001');
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000002');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "00000000-0000-0000-0000-000000000001"}';
SELECT results_eq(
  'SELECT id FROM profiles',
  ARRAY['00000000-0000-0000-0000-000000000001'::uuid],
  'Field user can only see own profile'
);
SELECT * FROM finish();
ROLLBACK;
