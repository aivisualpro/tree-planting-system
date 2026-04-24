-- Legal & Compliance Updates

-- Add columns to profiles for terms acceptance tracking
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS accepted_terms_version VARCHAR(50),
ADD COLUMN IF NOT EXISTS accepted_terms_timestamp TIMESTAMPTZ;

-- Add column to visits for explicit photo consent
ALTER TABLE visits 
ADD COLUMN IF NOT EXISTS photo_consent_obtained BOOLEAN DEFAULT false;

-- Track photo redaction requests
ALTER TABLE visits
ADD COLUMN IF NOT EXISTS photo_redaction_requested BOOLEAN DEFAULT false;

-- Audit triggers will automatically pick up changes to visits and profiles, but we can also add a function to easily apply redaction
CREATE OR REPLACE FUNCTION redact_visit_photo(p_visit_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE visits 
    SET photos = array_remove(photos, p_photo_url), -- or clear all, depending on implementation
        photo_redaction_requested = true
    WHERE id = p_visit_id;
END;
$$;
