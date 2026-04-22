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
