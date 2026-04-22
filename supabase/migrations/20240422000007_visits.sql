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
