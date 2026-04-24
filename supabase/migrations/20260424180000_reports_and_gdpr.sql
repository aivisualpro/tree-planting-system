-- Section B: Scheduled reports
CREATE TABLE IF NOT EXISTS scheduled_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    report_type TEXT NOT NULL,
    params JSONB DEFAULT '{}'::jsonb,
    schedule TEXT NOT NULL, -- cron expression
    last_run_at TIMESTAMPTZ,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Section F: Data retention policy enforcement
CREATE TABLE IF NOT EXISTS retention_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_name TEXT NOT NULL,
    records_deleted INT,
    status TEXT,
    error_message TEXT,
    run_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add full_name and last_export_at to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_export_at TIMESTAMPTZ;

-- RLS for scheduled_reports
ALTER TABLE scheduled_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own scheduled reports"
    ON scheduled_reports FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own scheduled reports"
    ON scheduled_reports FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all scheduled reports"
    ON scheduled_reports FOR SELECT
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin')));

-- RLS for retention_log
ALTER TABLE retention_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can view retention logs"
    ON retention_log FOR SELECT
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin')));

-- Audit trigger for scheduled_reports
CREATE TRIGGER audit_scheduled_reports AFTER INSERT OR UPDATE OR DELETE ON scheduled_reports FOR EACH ROW EXECUTE PROCEDURE audit_trigger();
