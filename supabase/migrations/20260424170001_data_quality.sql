CREATE OR REPLACE FUNCTION admin_data_quality_report()
RETURNS JSONB AS $$
DECLARE
  orphaned_visits JSONB;
  missing_photos JSONB;
  zero_trees JSONB;
  inactive_users JSONB;
  duplicates JSONB;
BEGIN
  -- Orphaned visits (e.g. missing country, activity, core_area that doesn't exist? Actually FK constraint prevents this. But if soft-deleted master data, it might be an issue. Let's assume FK is broken or points to deleted records)
  SELECT jsonb_agg(v) INTO orphaned_visits FROM (
    SELECT v.id FROM visits v
    LEFT JOIN countries c ON v.country_id = c.id
    WHERE c.id IS NULL OR v.country_id IS NULL
    LIMIT 50
  ) v;

  -- Visits with missing photos
  SELECT jsonb_agg(v) INTO missing_photos FROM (
    SELECT v.id FROM visits v
    LEFT JOIN visit_media m ON v.id = m.visit_id AND m.kind IN ('activity_photo', 'group_photo')
    WHERE m.id IS NULL AND v.status = 'completed' AND v.deleted_at IS NULL
    LIMIT 50
  ) v;

  -- Visits with 0 trees planted
  SELECT jsonb_agg(v) INTO zero_trees FROM (
    SELECT id FROM visits WHERE total_trees_planted = 0 AND status = 'completed' AND deleted_at IS NULL
    LIMIT 50
  ) v;

  -- Users with no activity in 30 days
  SELECT jsonb_agg(u) INTO inactive_users FROM (
    SELECT p.id, p.role FROM profiles p
    LEFT JOIN visits v ON p.id = v.created_by AND v.created_at > now() - interval '30 days'
    WHERE v.id IS NULL AND p.role != 'viewer'
    LIMIT 50
  ) u;

  -- Duplicate visits
  SELECT jsonb_agg(d) INTO duplicates FROM (
    SELECT created_by, gps_latitude, gps_longitude, scheduled_date, count(*) as count
    FROM visits
    WHERE deleted_at IS NULL AND gps_latitude IS NOT NULL
    GROUP BY created_by, gps_latitude, gps_longitude, scheduled_date
    HAVING count(*) > 1
    LIMIT 50
  ) d;

  RETURN jsonb_build_object(
    'orphaned_visits', COALESCE(orphaned_visits, '[]'::jsonb),
    'missing_photos', COALESCE(missing_photos, '[]'::jsonb),
    'zero_trees', COALESCE(zero_trees, '[]'::jsonb),
    'inactive_users', COALESCE(inactive_users, '[]'::jsonb),
    'duplicates', COALESCE(duplicates, '[]'::jsonb)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
