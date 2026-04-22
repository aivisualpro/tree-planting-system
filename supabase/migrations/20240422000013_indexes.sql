CREATE INDEX idx_visits_country_date ON visits (country_id, scheduled_date DESC);
CREATE INDEX idx_visits_created_by_status ON visits (created_by, status);
CREATE INDEX idx_visits_updated_at ON visits (updated_at DESC);
CREATE INDEX idx_visit_media_visit ON visit_media (visit_id);
CREATE INDEX idx_audit_log_row ON audit_log (table_name, row_id);
