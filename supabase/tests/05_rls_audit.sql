BEGIN;
SELECT plan(1);
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000300');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "00000000-0000-0000-0000-000000000300"}';
SELECT throws_ok(
  'INSERT INTO audit_log (table_name, row_id, operation) VALUES (''test'', ''00000000-0000-0000-0000-000000000300'', ''INSERT'')',
  '42501',
  'new row violates row-level security policy for table "audit_log"',
  'No direct inserts to audit_log'
);
SELECT * FROM finish();
ROLLBACK;
