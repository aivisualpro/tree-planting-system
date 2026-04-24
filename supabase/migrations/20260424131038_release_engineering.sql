-- App Versions for force update
CREATE TYPE app_platform AS ENUM ('android', 'ios', 'web');

CREATE TABLE app_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform app_platform NOT NULL,
    min_supported_version TEXT NOT NULL,
    latest_version TEXT NOT NULL,
    release_notes JSONB DEFAULT '{}'::jsonb,
    released_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(platform)
);

ALTER TABLE app_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "App versions are viewable by everyone" ON app_versions FOR SELECT USING (true);
CREATE POLICY "App versions are manageable by admins" ON app_versions FOR ALL USING (
    EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND (raw_app_meta_data->>'role' = 'admin' OR raw_user_meta_data->>'role' = 'admin'))
);

CREATE OR REPLACE FUNCTION get_app_version_info(p_platform text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result json;
BEGIN
    SELECT json_build_object(
        'min_supported_version', min_supported_version,
        'latest_version', latest_version,
        'release_notes', release_notes,
        'released_at', released_at
    ) INTO v_result
    FROM app_versions
    WHERE platform = p_platform::app_platform;
    
    RETURN v_result;
END;
$$;

-- Feature Flags
CREATE TABLE feature_flags (
    key TEXT PRIMARY KEY,
    description TEXT,
    default_value BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Feature flags are viewable by everyone" ON feature_flags FOR SELECT USING (true);
CREATE POLICY "Feature flags are manageable by admins" ON feature_flags FOR ALL USING (
    EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND (raw_app_meta_data->>'role' = 'admin' OR raw_user_meta_data->>'role' = 'admin'))
);

-- Feature Flag Overrides
CREATE TABLE feature_flag_overrides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_key TEXT REFERENCES feature_flags(key) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    country_id UUID REFERENCES countries(id) ON DELETE CASCADE,
    role TEXT,
    value BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE NULLS NOT DISTINCT (flag_key, user_id, country_id, role)
);

ALTER TABLE feature_flag_overrides ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Overrides are viewable by everyone" ON feature_flag_overrides FOR SELECT USING (true);
CREATE POLICY "Overrides are manageable by admins" ON feature_flag_overrides FOR ALL USING (
    EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND (raw_app_meta_data->>'role' = 'admin' OR raw_user_meta_data->>'role' = 'admin'))
);

-- RPC for feature flags
CREATE OR REPLACE FUNCTION get_feature_flags_for_user()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result json;
    v_user_id uuid := auth.uid();
    v_user_role text;
    v_country_id uuid;
BEGIN
    -- Get user metadata
    IF v_user_id IS NOT NULL THEN
        SELECT raw_user_meta_data->>'role', (raw_user_meta_data->>'country_id')::uuid
        INTO v_user_role, v_country_id
        FROM auth.users
        WHERE id = v_user_id;
    END IF;

    WITH resolved_flags AS (
        SELECT 
            f.key,
            COALESCE(
                (SELECT value FROM feature_flag_overrides o WHERE o.flag_key = f.key AND o.user_id = v_user_id LIMIT 1),
                (SELECT value FROM feature_flag_overrides o WHERE o.flag_key = f.key AND o.role = v_user_role AND o.user_id IS NULL AND o.country_id IS NULL LIMIT 1),
                (SELECT value FROM feature_flag_overrides o WHERE o.flag_key = f.key AND o.country_id = v_country_id AND o.user_id IS NULL AND o.role IS NULL LIMIT 1),
                f.default_value
            ) as is_enabled
        FROM feature_flags f
    )
    SELECT json_object_agg(key, is_enabled)
    INTO v_result
    FROM resolved_flags;

    RETURN COALESCE(v_result, '{}'::json);
END;
$$;

-- Seed initial values
INSERT INTO app_versions (platform, min_supported_version, latest_version) VALUES 
('android', '1.0.0', '1.0.0'),
('ios', '1.0.0', '1.0.0'),
('web', '1.0.0', '1.0.0')
ON CONFLICT DO NOTHING;

INSERT INTO feature_flags (key, description, default_value) VALUES
('enable_whatsapp_notifications', 'Enables WhatsApp notifications', false),
('enable_offline_maps', 'Enables offline maps caching and usage', false),
('enable_impersonation', 'Allows admins to impersonate other users', false),
('enable_new_dashboard_v2', 'Toggles the new V2 dashboard', false)
ON CONFLICT (key) DO NOTHING;
