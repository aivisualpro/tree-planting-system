CREATE MATERIALIZED VIEW mv_country_kpis AS
SELECT 
  country_id,
  count(id) AS total_visits,
  sum(total_trees_planted) AS total_trees,
  sum(attendance) AS total_attendance
FROM visits
WHERE deleted_at IS NULL AND status = 'completed'
GROUP BY country_id;

CREATE MATERIALIZED VIEW mv_top_species AS
SELECT 
  ts.country_id,
  ts.id AS species_id,
  ts.common_name_en,
  sum(vt.count) AS total_planted
FROM visit_trees vt
JOIN tree_species ts ON vt.tree_species_id = ts.id
JOIN visits v ON vt.visit_id = v.id
WHERE vt.deleted_at IS NULL AND v.deleted_at IS NULL AND v.status = 'completed'
GROUP BY ts.country_id, ts.id, ts.common_name_en;

CREATE MATERIALIZED VIEW mv_user_activity AS
SELECT 
  created_by AS user_id,
  count(id) AS visits_created,
  sum(total_trees_planted) AS trees_planted_by_user
FROM visits
WHERE deleted_at IS NULL
GROUP BY created_by;

CREATE UNIQUE INDEX idx_mv_country_kpis ON mv_country_kpis(country_id);
CREATE UNIQUE INDEX idx_mv_top_species ON mv_top_species(country_id, species_id);
CREATE UNIQUE INDEX idx_mv_user_activity ON mv_user_activity(user_id);

-- Note: we skip pg_cron schedule creation here because pg_cron requires configuration in postgresql.conf 
-- to run inside the current DB correctly on Supabase local. It's often safer to rely on edge functions for dashboard refresh 
-- or manual refresh in tests, but per request, here is the command (commented out to prevent migration crash on some local setups):
-- SELECT cron.schedule('refresh-country-kpis', '*/5 * * * *', 'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_country_kpis;');
