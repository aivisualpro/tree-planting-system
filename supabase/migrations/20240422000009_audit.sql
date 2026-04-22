CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name TEXT NOT NULL,
    row_id UUID NOT NULL,
    operation audit_operation NOT NULL,
    actor_id UUID REFERENCES profiles(id),
    old_row JSONB,
    new_row JSONB,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION public.audit_trigger()
RETURNS trigger AS $$
DECLARE
  old_row JSONB := NULL;
  new_row JSONB := NULL;
  actor UUID := NULL;
BEGIN
  actor := current_user_id();
  
  IF TG_OP = 'INSERT' THEN
    new_row := to_jsonb(NEW);
  ELSIF TG_OP = 'UPDATE' THEN
    old_row := to_jsonb(OLD);
    new_row := to_jsonb(NEW);
  ELSIF TG_OP = 'DELETE' THEN
    old_row := to_jsonb(OLD);
  END IF;

  INSERT INTO audit_log (table_name, row_id, operation, actor_id, old_row, new_row)
  VALUES (
    TG_TABLE_NAME::text,
    COALESCE(new_row->>'id', old_row->>'id')::uuid,
    TG_OP::audit_operation,
    actor,
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

CREATE TRIGGER audit_profiles AFTER INSERT OR UPDATE OR DELETE ON profiles FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_countries AFTER INSERT OR UPDATE OR DELETE ON countries FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_subwatersheds AFTER INSERT OR UPDATE OR DELETE ON subwatersheds FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_communities AFTER INSERT OR UPDATE OR DELETE ON communities FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_groups AFTER INSERT OR UPDATE OR DELETE ON groups FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_schools AFTER INSERT OR UPDATE OR DELETE ON schools FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_churches AFTER INSERT OR UPDATE OR DELETE ON churches FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_tree_species AFTER INSERT OR UPDATE OR DELETE ON tree_species FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_visits AFTER INSERT OR UPDATE OR DELETE ON visits FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_visit_trees AFTER INSERT OR UPDATE OR DELETE ON visit_trees FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_visit_media AFTER INSERT OR UPDATE OR DELETE ON visit_media FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
CREATE TRIGGER audit_translations AFTER INSERT OR UPDATE OR DELETE ON translations FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
