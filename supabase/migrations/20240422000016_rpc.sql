CREATE OR REPLACE FUNCTION pull_visits_since(since timestamptz, limit_ int DEFAULT 100)
RETURNS SETOF visits LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT * FROM visits 
  WHERE updated_at > since
    AND (created_by = auth.uid() OR has_country_access(country_id) OR (SELECT view_all_visits FROM profiles WHERE id = auth.uid()) = true)
  ORDER BY updated_at ASC
  LIMIT limit_;
$$;

CREATE OR REPLACE FUNCTION push_visit_batch(visits_payload jsonb, trees_payload jsonb, media_payload jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF visits_payload IS NOT NULL AND jsonb_array_length(visits_payload) > 0 THEN
    INSERT INTO visits (client_uuid, country_id, core_area_id, activity_id, status, created_by)
    SELECT 
      (v->>'client_uuid')::uuid, (v->>'country_id')::uuid, (v->>'core_area_id')::uuid, 
      (v->>'activity_id')::uuid, (v->>'status')::visit_status, auth.uid()
    FROM jsonb_array_elements(visits_payload) AS v
    ON CONFLICT (client_uuid) DO UPDATE 
    SET status = EXCLUDED.status;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION dashboard_kpis(from_date date, to_date date, target_country_ids uuid[])
RETURNS jsonb LANGUAGE sql STABLE AS $$
  SELECT jsonb_build_object(
    'total_visits', count(*),
    'total_trees', COALESCE(sum(total_trees_planted), 0),
    'total_attendance', COALESCE(sum(attendance), 0)
  )
  FROM visits
  WHERE deleted_at IS NULL
    AND scheduled_date BETWEEN from_date AND to_date
    AND country_id = ANY(target_country_ids);
$$;
