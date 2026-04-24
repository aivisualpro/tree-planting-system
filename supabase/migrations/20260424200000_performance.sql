-- Performance: indexes, materialized view refresh, connection pooling & slow-query hints
-- Migration: 20260424200000_performance.sql

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Additional compound indexes to eliminate sequential scans (§12)
-- ─────────────────────────────────────────────────────────────────────────────
-- Visits: cover the dashboard RPC filter pattern (country + status + date)
CREATE INDEX IF NOT EXISTS idx_visits_country_status_date
  ON visits (country_id, status, scheduled_date DESC)
  WHERE deleted_at IS NULL;

-- Visits: outbox pull pattern (updated_at cursor-based pagination)
CREATE INDEX IF NOT EXISTS idx_visits_updated_at_id
  ON visits (updated_at DESC, id)
  WHERE deleted_at IS NULL;

-- Visit trees: aggregation join path
CREATE INDEX IF NOT EXISTS idx_visit_trees_visit_species
  ON visit_trees (visit_id, tree_species_id)
  WHERE deleted_at IS NULL;

-- Visit media: pending-upload query pattern
CREATE INDEX IF NOT EXISTS idx_visit_media_sync_status
  ON visit_media (sync_status, created_at)
  WHERE sync_status IN ('pending', 'failed');

-- Profiles: country + role lookup (RLS helper)
CREATE INDEX IF NOT EXISTS idx_profiles_country_role
  ON profiles (country_id, role);

-- Audit log: time-range scans
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at
  ON audit_log (created_at DESC);

-- Notification events: unread feed
CREATE INDEX IF NOT EXISTS idx_notification_events_user_read
  ON notification_events (user_id, read_at)
  WHERE read_at IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Refresh materialized views via pg_cron (§12 – every 5 min)
-- ─────────────────────────────────────────────────────────────────────────────
-- Enable pg_cron (Supabase Pro already has this; safe to re-run)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Remove any stale schedules before re-creating
SELECT cron.unschedule('refresh-mv-country-kpis')  WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'refresh-mv-country-kpis');
SELECT cron.unschedule('refresh-mv-top-species')   WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'refresh-mv-top-species');
SELECT cron.unschedule('refresh-mv-user-activity') WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'refresh-mv-user-activity');

-- §12: refresh every 5 minutes concurrently (non-blocking)
SELECT cron.schedule(
  'refresh-mv-country-kpis',
  '*/5 * * * *',
  'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_country_kpis'
);

SELECT cron.schedule(
  'refresh-mv-top-species',
  '*/5 * * * *',
  'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_species'
);

SELECT cron.schedule(
  'refresh-mv-user-activity',
  '*/5 * * * *',
  'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_user_activity'
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Visits list RPC – optimised for p95 < 300ms (§14)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_visits_page(
  p_country_id  UUID    DEFAULT NULL,
  p_status      TEXT    DEFAULT NULL,
  p_limit       INT     DEFAULT 25,
  p_offset      INT     DEFAULT 0
)
RETURNS TABLE (
  id              UUID,
  country_id      UUID,
  community_id    UUID,
  scheduled_date  DATE,
  status          visit_status,
  total_trees_planted BIGINT,
  attendance      INT,
  created_by      UUID,
  updated_at      TIMESTAMPTZ
)
LANGUAGE sql STABLE PARALLEL SAFE
SET search_path = public
AS $$
  SELECT
    v.id,
    v.country_id,
    v.community_id,
    v.scheduled_date,
    v.status,
    v.total_trees_planted,
    v.attendance,
    v.created_by,
    v.updated_at
  FROM visits v
  WHERE v.deleted_at IS NULL
    AND (p_country_id IS NULL OR v.country_id = p_country_id)
    AND (p_status     IS NULL OR v.status = p_status::visit_status)
  ORDER BY v.scheduled_date DESC, v.id
  LIMIT  p_limit
  OFFSET p_offset;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. pull_visits_since – sync engine (§16 – batch 100, cursor-based)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pull_visits_since(since TIMESTAMPTZ, limit_ INT DEFAULT 100)
RETURNS SETOF visits
LANGUAGE sql STABLE PARALLEL SAFE
SET search_path = public
AS $$
  SELECT *
  FROM visits
  WHERE updated_at > since
  ORDER BY updated_at ASC, id ASC
  LIMIT least(limit_, 500);  -- hard cap at 500 for safety
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Dashboard KPI RPC – p95 < 500ms (§14)
-- Reads from materialized view; fast even without fresh data
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_dashboard_kpis(p_country_id UUID DEFAULT NULL)
RETURNS JSON
LANGUAGE sql STABLE PARALLEL SAFE
SET search_path = public
AS $$
  SELECT json_build_object(
    'visits',     COALESCE(SUM(total_visits), 0),
    'trees',      COALESCE(SUM(total_trees), 0),
    'attendance', COALESCE(SUM(total_attendance), 0),
    'refreshed_at', now()
  )
  FROM mv_country_kpis
  WHERE (p_country_id IS NULL OR country_id = p_country_id);
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. EXPLAIN ANALYZE hints (run manually in Supabase SQL editor) (§12)
-- ─────────────────────────────────────────────────────────────────────────────
-- EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT get_dashboard_kpis(NULL);
-- EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT * FROM get_visits_page(NULL, NULL, 25, 0);
-- EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT * FROM pull_visits_since(now() - interval '1 day', 100);
-- All should show "Index Scan" – NO sequential scans over 1000 rows.

COMMENT ON FUNCTION get_visits_page IS
  'Paginated visits list. p95 target < 300 ms. Uses idx_visits_country_status_date.';
COMMENT ON FUNCTION get_dashboard_kpis IS
  'Dashboard KPI aggregation. p95 target < 500 ms. Reads from mv_country_kpis materialized view.';
COMMENT ON FUNCTION pull_visits_since IS
  'Sync delta pull. Returns ≤ min(limit_, 500) rows ordered by updated_at ASC for cursor pagination.';
