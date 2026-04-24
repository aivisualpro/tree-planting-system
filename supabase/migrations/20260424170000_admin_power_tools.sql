ALTER TYPE audit_operation ADD VALUE IF NOT EXISTS 'impersonate_start';

ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS impersonator_id UUID REFERENCES profiles(id);
ALTER TABLE sync_log ADD COLUMN IF NOT EXISTS local_state JSONB;
ALTER TABLE sync_log ADD COLUMN IF NOT EXISTS server_state JSONB;
ALTER TABLE sync_log ADD COLUMN IF NOT EXISTS target_table TEXT;
ALTER TABLE sync_log ADD COLUMN IF NOT EXISTS target_id UUID;

CREATE OR REPLACE FUNCTION public.audit_trigger()
RETURNS trigger AS $$
DECLARE
  old_row JSONB := NULL;
  new_row JSONB := NULL;
  actor UUID := NULL;
  impersonator UUID := NULL;
BEGIN
  actor := auth.uid();
  
  BEGIN
    impersonator := (current_setting('request.jwt.claims', true)::jsonb ->> 'impersonator_id')::uuid;
  EXCEPTION WHEN OTHERS THEN
    impersonator := NULL;
  END;
  
  IF TG_OP = 'INSERT' THEN
    new_row := to_jsonb(NEW);
  ELSIF TG_OP = 'UPDATE' THEN
    old_row := to_jsonb(OLD);
    new_row := to_jsonb(NEW);
  ELSIF TG_OP = 'DELETE' THEN
    old_row := to_jsonb(OLD);
  END IF;

  INSERT INTO audit_log (table_name, row_id, operation, actor_id, impersonator_id, old_row, new_row)
  VALUES (
    TG_TABLE_NAME::text,
    COALESCE(new_row->>'id', old_row->>'id')::uuid,
    TG_OP::audit_operation,
    actor,
    impersonator,
    old_row,
    new_row
  );

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Bulk Operations
CREATE OR REPLACE FUNCTION bulk_reassign_visits(visit_ids UUID[], new_assignee_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE visits SET assignee = new_assignee_id WHERE id = ANY(visit_ids);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION bulk_cancel_visits(visit_ids UUID[], reason TEXT)
RETURNS void AS $$
BEGIN
  UPDATE visits SET status = 'cancelled', cancellation_reason = reason WHERE id = ANY(visit_ids);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION bulk_update_user_role(user_ids UUID[], new_role user_role)
RETURNS void AS $$
BEGIN
  UPDATE profiles SET role = new_role WHERE id = ANY(user_ids);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION bulk_reassign_user_country(user_ids UUID[], new_country_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE profiles SET primary_country_id = new_country_id WHERE id = ANY(user_ids);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Repair Operations
CREATE OR REPLACE FUNCTION admin_soft_delete_visit(target_visit_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE visits SET deleted_at = now() WHERE id = target_visit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION admin_restore_visit(target_visit_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE visits SET deleted_at = NULL WHERE id = target_visit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION admin_refresh_materialized_views()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_country_kpis;
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_species;
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_user_activity;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
