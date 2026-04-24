BEGIN;
SELECT plan(2);

INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000400');
UPDATE profiles SET role = 'super_admin' WHERE id = '00000000-0000-0000-0000-000000000400';

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "00000000-0000-0000-0000-000000000400"}';

-- Admin sees it due to select policy, but we test UPDATE/DELETE
SELECT throws_ok(
  'UPDATE audit_log SET operation = ''DELETE''',
  '42501',
  NULL,
  'No role can update audit_log'
);

SELECT throws_ok(
  'DELETE FROM audit_log',
  '42501',
  NULL,
  'No role can delete audit_log'
);

SELECT * FROM finish();
ROLLBACK;
