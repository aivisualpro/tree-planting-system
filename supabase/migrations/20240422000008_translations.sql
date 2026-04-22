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
