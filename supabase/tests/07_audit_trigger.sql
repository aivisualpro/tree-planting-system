BEGIN;
SELECT plan(1);
INSERT INTO countries (id, code, name_en) VALUES ('00000000-0000-0000-0000-000000000500', 'YY', 'YY');
SELECT results_eq(
  'SELECT table_name FROM audit_log WHERE row_id = ''00000000-0000-0000-0000-000000000500''',
  ARRAY['countries'::text],
  'Audit log created'
);
SELECT * FROM finish();
ROLLBACK;
