import os

base_dir = "/Users/adeeljabbar/Downloads/Code Library/Tree-Planting-System/supabase"
migrations_dir = os.path.join(base_dir, "migrations")
tests_dir = os.path.join(base_dir, "tests")

os.makedirs(migrations_dir, exist_ok=True)
os.makedirs(tests_dir, exist_ok=True)

migrations = {
    "20240422000001_extensions.sql": """
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_cron";
CREATE EXTENSION IF NOT EXISTS "pgtap";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
""",
    "20240422000002_enums.sql": """
CREATE TYPE user_role AS ENUM ('super_admin', 'admin', 'coordinator', 'field_user', 'viewer');
CREATE TYPE visit_status AS ENUM ('draft', 'scheduled', 'completed', 'cancelled');
CREATE TYPE sync_status AS ENUM ('draft', 'pending', 'syncing', 'synced', 'failed');
CREATE TYPE media_kind AS ENUM ('group_photo', 'activity_photo', 'signature');
CREATE TYPE media_upload_status AS ENUM ('pending', 'uploading', 'completed', 'failed');
CREATE TYPE translation_entity_type AS ENUM ('country', 'tree_species', 'activity', 'core_area');
CREATE TYPE audit_operation AS ENUM ('INSERT', 'UPDATE', 'DELETE');
""",
    "20240422000003_profiles.sql": """
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'field_user',
    assigned_countries UUID[] DEFAULT '{}',
    primary_country_id UUID,
    language_code TEXT NOT NULL DEFAULT 'en',
    whatsapp TEXT,
    passcode_hash TEXT,
    view_all_visits BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (new.id, 'field_user');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
""",
    "20240422000004_helpers.sql": """
CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS uuid LANGUAGE sql STABLE
AS $$ SELECT auth.uid(); $$;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS user_role LANGUAGE sql STABLE
AS $$ 
  SELECT role FROM public.profiles WHERE id = auth.uid(); 
$$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean LANGUAGE sql STABLE
AS $$ 
  SELECT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role IN ('super_admin', 'admin')
  );
$$;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean LANGUAGE sql STABLE
AS $$ 
  SELECT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'super_admin'
  );
$$;

CREATE OR REPLACE FUNCTION public.has_country_access(target_country_id uuid)
RETURNS boolean LANGUAGE sql STABLE
AS $$ 
  SELECT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() 
      AND (role = 'super_admin' OR target_country_id = ANY(assigned_countries))
  );
$$;

CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  IF NEW.version IS NULL THEN
    NEW.version = 1;
  ELSE
    NEW.version = OLD.version + 1;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
""",
    "20240422000005_master_data.sql": """
CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL,
    name_en TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER touch_countries_updated_at BEFORE UPDATE ON countries FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();

ALTER TABLE profiles ADD CONSTRAINT fk_primary_country FOREIGN KEY (primary_country_id) REFERENCES countries(id);

CREATE TABLE subwatersheds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL REFERENCES countries(id),
    name_en TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
CREATE TRIGGER touch_subwatersheds BEFORE UPDATE ON subwatersheds FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();

CREATE TABLE communities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subwatershed_id UUID NOT NULL REFERENCES subwatersheds(id),
    name_en TEXT NOT NULL,
    year INT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
CREATE TRIGGER touch_communities BEFORE UPDATE ON communities FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();

CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID NOT NULL REFERENCES communities(id),
    name_en TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
CREATE TRIGGER touch_groups BEFORE UPDATE ON groups FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();

CREATE TABLE schools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL REFERENCES countries(id),
    subwatershed_id UUID REFERENCES subwatersheds(id),
    community_id UUID REFERENCES communities(id),
    region TEXT,
    name_en TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
CREATE TRIGGER touch_schools BEFORE UPDATE ON schools FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();

CREATE TABLE churches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL REFERENCES countries(id),
    subwatershed_id UUID REFERENCES subwatersheds(id),
    community_id UUID REFERENCES communities(id),
    region TEXT,
    name_en TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
CREATE TRIGGER touch_churches BEFORE UPDATE ON churches FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();
""",
    "20240422000006_catalog.sql": """
CREATE TABLE core_areas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL,
    name_en TEXT NOT NULL
);

CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    core_area_id UUID NOT NULL REFERENCES core_areas(id),
    name_en TEXT NOT NULL,
    visit_requirements JSONB,
    designated_to TEXT[]
);

CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL,
    name_en TEXT NOT NULL
);

CREATE TABLE activity_units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id),
    unit_id UUID NOT NULL REFERENCES units(id),
    country_id UUID REFERENCES countries(id)
);

CREATE TABLE tree_species (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID REFERENCES countries(id),
    scientific_name TEXT NOT NULL,
    common_name_en TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
CREATE TRIGGER touch_tree_species BEFORE UPDATE ON tree_species FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();
""",
    "20240422000007_visits.sql": """
CREATE TABLE visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_uuid UUID UNIQUE NOT NULL,
    country_id UUID NOT NULL REFERENCES countries(id),
    core_area_id UUID NOT NULL REFERENCES core_areas(id),
    activity_id UUID NOT NULL REFERENCES activities(id),
    
    visit_type TEXT,
    is_group BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT true,
    
    scheduled_date DATE,
    scheduled_start_time TIME,
    scheduled_end_time TIME,
    actual_start_at TIMESTAMPTZ,
    actual_end_at TIMESTAMPTZ,
    planting_start_date DATE,
    planting_end_date DATE,
    
    subwatershed_id UUID REFERENCES subwatersheds(id),
    community_id UUID REFERENCES communities(id),
    group_id UUID REFERENCES groups(id),
    individual_name TEXT,
    school_id UUID REFERENCES schools(id),
    church_id UUID REFERENCES churches(id),
    
    attendance INT,
    comments TEXT,
    feedback TEXT,
    feedback_score INT,
    
    scheduled_by UUID REFERENCES profiles(id),
    assignee UUID REFERENCES profiles(id),
    visited_by UUID REFERENCES profiles(id),
    
    status visit_status NOT NULL DEFAULT 'draft',
    cancellation_reason TEXT,
    cancellation_comments TEXT,
    
    gps_latitude DOUBLE PRECISION,
    gps_longitude DOUBLE PRECISION,
    signature_media_id UUID,
    
    total_trees_planted INT DEFAULT 0,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
CREATE TRIGGER touch_visits BEFORE UPDATE ON visits FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();

CREATE TABLE visit_trees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
    tree_species_id UUID NOT NULL REFERENCES tree_species(id),
    count INT NOT NULL CHECK (count > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
CREATE TRIGGER touch_visit_trees BEFORE UPDATE ON visit_trees FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();

CREATE TABLE visit_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_uuid UUID UNIQUE NOT NULL,
    visit_id UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
    kind media_kind NOT NULL,
    storage_path TEXT,
    sha256 TEXT NOT NULL,
    content_type TEXT NOT NULL,
    size_bytes BIGINT NOT NULL,
    upload_status media_upload_status NOT NULL DEFAULT 'pending',
    uploaded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
CREATE TRIGGER touch_visit_media BEFORE UPDATE ON visit_media FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();

ALTER TABLE visits ADD CONSTRAINT fk_signature FOREIGN KEY (signature_media_id) REFERENCES visit_media(id) ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION update_total_trees_planted()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    UPDATE visits SET total_trees_planted = (
      SELECT COALESCE(SUM(count), 0) FROM visit_trees WHERE visit_id = NEW.visit_id AND deleted_at IS NULL
    ) WHERE id = NEW.visit_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE visits SET total_trees_planted = (
      SELECT COALESCE(SUM(count), 0) FROM visit_trees WHERE visit_id = OLD.visit_id AND deleted_at IS NULL
    ) WHERE id = OLD.visit_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_trees_planted_trigger
  AFTER INSERT OR UPDATE OR DELETE ON visit_trees
  FOR EACH ROW EXECUTE PROCEDURE update_total_trees_planted();
""",
    "20240422000008_translations.sql": """
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type translation_entity_type NOT NULL,
    entity_id UUID NOT NULL,
    field TEXT NOT NULL,
    locale TEXT NOT NULL,
    value TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by UUID REFERENCES profiles(id),
    UNIQUE (entity_type, entity_id, field, locale)
);
CREATE INDEX idx_translations_lookup ON translations USING btree (entity_type, entity_id, locale);
CREATE INDEX idx_translations_gin ON translations USING gin (entity_type, locale);
CREATE TRIGGER touch_translations BEFORE UPDATE ON translations FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();
""",
    "20240422000009_audit.sql": """
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
""",
    "20240422000010_sync_log.sql": """
CREATE TABLE sync_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_uuid UUID NOT NULL,
    user_id UUID REFERENCES profiles(id),
    operation TEXT NOT NULL,
    status TEXT NOT NULL,
    error_message TEXT,
    attempt_count INT DEFAULT 1,
    server_received_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
""",
    "20240422000011_rls_enable.sql": """
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE subwatersheds ENABLE ROW LEVEL SECURITY;
ALTER TABLE communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE churches ENABLE ROW LEVEL SECURITY;
ALTER TABLE core_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE units ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE tree_species ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE visit_trees ENABLE ROW LEVEL SECURITY;
ALTER TABLE visit_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_log ENABLE ROW LEVEL SECURITY;
""",
    "20240422000012_rls_policies.sql": """
-- profiles
CREATE POLICY "Users can select own profile" ON profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Admins can select all profiles" ON profiles FOR SELECT USING (is_admin());
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY "Admins can update any profile" ON profiles FOR UPDATE USING (is_admin());

-- countries/masters
CREATE POLICY "Masters readable by authenticated" ON countries FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Masters modifiable by admin" ON countries FOR ALL USING (is_admin());

CREATE POLICY "Subwatersheds readable by authenticated" ON subwatersheds FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Subwatersheds modifiable by admin" ON subwatersheds FOR ALL USING (is_admin());

CREATE POLICY "Communities readable by authenticated" ON communities FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Communities modifiable by admin" ON communities FOR ALL USING (is_admin());

CREATE POLICY "Groups readable by authenticated" ON groups FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Groups modifiable by admin" ON groups FOR ALL USING (is_admin());

CREATE POLICY "Schools readable by authenticated" ON schools FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Schools modifiable by admin" ON schools FOR ALL USING (is_admin());

CREATE POLICY "Churches readable by authenticated" ON churches FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Churches modifiable by admin" ON churches FOR ALL USING (is_admin());

CREATE POLICY "Core areas readable by authenticated" ON core_areas FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Core areas modifiable by admin" ON core_areas FOR ALL USING (is_admin());

CREATE POLICY "Activities readable by authenticated" ON activities FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Activities modifiable by admin" ON activities FOR ALL USING (is_admin());

CREATE POLICY "Units readable by authenticated" ON units FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Units modifiable by admin" ON units FOR ALL USING (is_admin());

CREATE POLICY "Activity units readable by authenticated" ON activity_units FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Activity units modifiable by admin" ON activity_units FOR ALL USING (is_admin());

CREATE POLICY "Tree species readable by authenticated" ON tree_species FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Tree species modifiable by admin" ON tree_species FOR ALL USING (is_admin());

-- visits
CREATE POLICY "Visits select policy" ON visits FOR SELECT USING (
    created_by = auth.uid() OR
    has_country_access(country_id) OR
    (SELECT view_all_visits FROM profiles WHERE id = auth.uid()) = true
);
CREATE POLICY "Visits insert policy" ON visits FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Visits update policy" ON visits FOR UPDATE USING (
    created_by = auth.uid() OR has_country_access(country_id)
);
CREATE POLICY "Visits delete policy" ON visits FOR DELETE USING (is_admin() AND has_country_access(country_id));

-- visit_trees
CREATE POLICY "Visit trees select policy" ON visit_trees FOR SELECT USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_trees.visit_id)
);
CREATE POLICY "Visit trees insert policy" ON visit_trees FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_trees.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);
CREATE POLICY "Visit trees update policy" ON visit_trees FOR UPDATE USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_trees.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);
CREATE POLICY "Visit trees delete policy" ON visit_trees FOR DELETE USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_trees.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);

-- visit_media
CREATE POLICY "Visit media select policy" ON visit_media FOR SELECT USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_media.visit_id)
);
CREATE POLICY "Visit media insert policy" ON visit_media FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_media.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);
CREATE POLICY "Visit media update policy" ON visit_media FOR UPDATE USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_media.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);
CREATE POLICY "Visit media delete policy" ON visit_media FOR DELETE USING (
    EXISTS (SELECT 1 FROM visits WHERE visits.id = visit_media.visit_id AND (visits.created_by = auth.uid() OR has_country_access(visits.country_id)))
);

-- translations
CREATE POLICY "Translations select policy" ON translations FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Translations all policy" ON translations FOR ALL USING (is_admin());

-- audit_log
CREATE POLICY "Audit log select admin" ON audit_log FOR SELECT USING (is_admin());

-- sync_log
CREATE POLICY "Sync log insert auth" ON sync_log FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Sync log select" ON sync_log FOR SELECT USING (user_id = auth.uid() OR is_admin());
""",
    "20240422000013_indexes.sql": """
CREATE INDEX idx_visits_country_date ON visits (country_id, scheduled_date DESC);
CREATE INDEX idx_visits_created_by_status ON visits (created_by, status);
CREATE INDEX idx_visits_updated_at ON visits (updated_at DESC);
CREATE INDEX idx_visit_media_visit ON visit_media (visit_id);
CREATE INDEX idx_audit_log_row ON audit_log (table_name, row_id);
""",
    "20240422000014_views.sql": """
CREATE OR REPLACE VIEW v_visits_detail AS
SELECT 
  v.*,
  c.name_en AS country_name,
  ca.name_en AS core_area_name,
  a.name_en AS activity_name,
  (SELECT string_agg(ts.common_name_en, ', ') 
   FROM visit_trees vt 
   JOIN tree_species ts ON vt.tree_species_id = ts.id 
   WHERE vt.visit_id = v.id) AS planted_species,
  (SELECT count(*) FROM visit_media vm WHERE vm.visit_id = v.id) AS media_count
FROM visits v
JOIN countries c ON v.country_id = c.id
JOIN core_areas ca ON v.core_area_id = ca.id
JOIN activities a ON v.activity_id = a.id
WHERE v.deleted_at IS NULL;
""",
    "20240422000015_materialized_views.sql": """
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
""",
    "20240422000016_rpc.sql": """
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
"""
}

for name, content in migrations.items():
    with open(os.path.join(migrations_dir, name), "w") as f:
        f.write(content.strip() + "\n")

tests = {
    "01_rls_profiles.sql": """
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
""",
    "02_rls_visits.sql": """
BEGIN;
SELECT plan(1);
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000003');
INSERT INTO core_areas (id, code, name_en) VALUES ('00000000-0000-0000-0000-000000000010', 'CA1', 'Core 1');
INSERT INTO activities (id, core_area_id, name_en) VALUES ('00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000010', 'Act 1');
INSERT INTO countries (id, code, name_en) VALUES ('00000000-0000-0000-0000-000000000012', 'TZ', 'Tanzania');

INSERT INTO visits (id, client_uuid, created_by, country_id, core_area_id, activity_id) VALUES 
('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000011'),
('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000023', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000011');

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "00000000-0000-0000-0000-000000000003"}';
SELECT results_eq(
  'SELECT id FROM visits',
  ARRAY['00000000-0000-0000-0000-000000000020'::uuid],
  'Field user sees only own visits'
);
SELECT * FROM finish();
ROLLBACK;
""",
    "03_rls_visits_country.sql": """
BEGIN;
SELECT plan(1);
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000100');
INSERT INTO countries (id, code, name_en) VALUES ('00000000-0000-0000-0000-000000000101', 'MW', 'Malawi');
UPDATE profiles SET role = 'coordinator', assigned_countries = ARRAY['00000000-0000-0000-0000-000000000101'::uuid] WHERE id = '00000000-0000-0000-0000-000000000100';

INSERT INTO core_areas (id, code, name_en) VALUES ('00000000-0000-0000-0000-000000000102', 'CA2', 'Core 2');
INSERT INTO activities (id, core_area_id, name_en) VALUES ('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000102', 'Act 2');

INSERT INTO visits (id, client_uuid, country_id, core_area_id, activity_id) VALUES 
('00000000-0000-0000-0000-000000000104', '00000000-0000-0000-0000-000000000105', '00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000103');

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "00000000-0000-0000-0000-000000000100"}';
SELECT results_eq(
  'SELECT id FROM visits',
  ARRAY['00000000-0000-0000-0000-000000000104'::uuid],
  'Coordinator sees assigned country visits'
);
SELECT * FROM finish();
ROLLBACK;
""",
    "04_rls_masters.sql": """
BEGIN;
SELECT plan(1);
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-000000000200');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "00000000-0000-0000-0000-000000000200"}';

SELECT throws_ok(
  'INSERT INTO countries (code, name_en) VALUES (''US'', ''USA'')',
  '42501',
  'new row violates row-level security policy for table "countries"',
  'Field user cannot insert into countries'
);
SELECT * FROM finish();
ROLLBACK;
""",
    "05_rls_audit.sql": """
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
""",
    "06_triggers.sql": """
BEGIN;
SELECT plan(1);
INSERT INTO countries (id, code, name_en, version) VALUES ('00000000-0000-0000-0000-000000000400', 'ZZ', 'ZZ', 1);
UPDATE countries SET name_en = 'ZZZ' WHERE id = '00000000-0000-0000-0000-000000000400';
SELECT results_eq(
  'SELECT version FROM countries WHERE id = ''00000000-0000-0000-0000-000000000400''',
  ARRAY[2],
  'Version bumped on update'
);
SELECT * FROM finish();
ROLLBACK;
""",
    "07_audit_trigger.sql": """
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
""",
    "08_idempotency.sql": """
BEGIN;
SELECT plan(1);
INSERT INTO core_areas (id, code, name_en) VALUES ('00000000-0000-0000-0000-000000000600', 'CA3', 'Core 3');
INSERT INTO activities (id, core_area_id, name_en) VALUES ('00000000-0000-0000-0000-000000000601', '00000000-0000-0000-0000-000000000600', 'Act 3');
INSERT INTO countries (id, code, name_en) VALUES ('00000000-0000-0000-0000-000000000602', 'XX', 'XX');

INSERT INTO visits (id, client_uuid, country_id, core_area_id, activity_id) VALUES 
('00000000-0000-0000-0000-000000000603', '00000000-0000-0000-0000-000000000604', '00000000-0000-0000-0000-000000000602', '00000000-0000-0000-0000-000000000600', '00000000-0000-0000-0000-000000000601');

SELECT throws_ok(
  'INSERT INTO visits (id, client_uuid, country_id, core_area_id, activity_id) VALUES (''00000000-0000-0000-0000-000000000605'', ''00000000-0000-0000-0000-000000000604'', ''00000000-0000-0000-0000-000000000602'', ''00000000-0000-0000-0000-000000000600'', ''00000000-0000-0000-0000-000000000601'')',
  '23505',
  'duplicate key value violates unique constraint "visits_client_uuid_key"',
  'Idempotency test via unique client_uuid'
);

SELECT * FROM finish();
ROLLBACK;
"""
}

for name, content in tests.items():
    with open(os.path.join(tests_dir, name), "w") as f:
        f.write(content.strip() + "\n")

seed_content = """
INSERT INTO auth.users (id, instance_id, aud, role, email) VALUES
('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'super@test.com'),
('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin_tz@test.com'),
('33333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'coord_mw@test.com'),
('44444444-4444-4444-4444-444444444444', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'field_tz@test.com'),
('55555555-5555-5555-5555-555555555555', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'field_mw@test.com')
ON CONFLICT (id) DO NOTHING;

INSERT INTO countries (id, code, name_en) VALUES 
('c0000000-0000-0000-0000-000000000001', 'TZ', 'Tanzania'),
('c0000000-0000-0000-0000-000000000002', 'MW', 'Malawi')
ON CONFLICT (id) DO NOTHING;

UPDATE profiles SET role = 'super_admin' WHERE id = '11111111-1111-1111-1111-111111111111';
UPDATE profiles SET role = 'admin', assigned_countries = ARRAY['c0000000-0000-0000-0000-000000000001'::uuid] WHERE id = '22222222-2222-2222-2222-222222222222';
UPDATE profiles SET role = 'coordinator', assigned_countries = ARRAY['c0000000-0000-0000-0000-000000000002'::uuid] WHERE id = '33333333-3333-3333-3333-333333333333';
UPDATE profiles SET role = 'field_user' WHERE id IN ('44444444-4444-4444-4444-444444444444', '55555555-5555-5555-5555-555555555555');

INSERT INTO core_areas (id, code, name_en) VALUES 
('ca000000-0000-0000-0000-000000000001', 'AGRO', 'Agroforestry'),
('ca000000-0000-0000-0000-000000000002', 'REFOR', 'Reforestation'),
('ca000000-0000-0000-0000-000000000003', 'CONS', 'Conservation')
ON CONFLICT (id) DO NOTHING;

INSERT INTO activities (id, core_area_id, name_en) VALUES 
('ac000000-0000-0000-0000-000000000001', 'ca000000-0000-0000-0000-000000000001', 'Tree Planting'),
('ac000000-0000-0000-0000-000000000002', 'ca000000-0000-0000-0000-000000000001', 'Site Survey')
ON CONFLICT (id) DO NOTHING;

INSERT INTO tree_species (id, scientific_name, common_name_en) VALUES 
('f5000000-0000-0000-0000-000000000001', 'Mangifera indica', 'Mango'),
('f5000000-0000-0000-0000-000000000002', 'Persea americana', 'Avocado')
ON CONFLICT (id) DO NOTHING;

INSERT INTO visits (id, client_uuid, country_id, core_area_id, activity_id, status, created_by) VALUES
('ee000000-0000-0000-0000-000000000001', 'ee000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'ca000000-0000-0000-0000-000000000001', 'ac000000-0000-0000-0000-000000000001', 'completed', '44444444-4444-4444-4444-444444444444')
ON CONFLICT (id) DO NOTHING;

INSERT INTO visit_trees (visit_id, tree_species_id, count) VALUES
('ee000000-0000-0000-0000-000000000001', 'f5000000-0000-0000-0000-000000000001', 50),
('ee000000-0000-0000-0000-000000000001', 'f5000000-0000-0000-0000-000000000002', 20)
ON CONFLICT (id) DO NOTHING;
"""

with open(os.path.join(base_dir, "seed.sql"), "w") as f:
    f.write(seed_content.strip() + "\n")
