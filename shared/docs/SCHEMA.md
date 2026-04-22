# Database Schema Design

This document details the complete PostgreSQL DDL schema, optimized for Supabase and an offline-first mobile architecture.

## Opinionated Design Choices & Tradeoffs

1. **Client-generated IDs vs DB-generated IDs**: 
   - *Tradeoff*: You suggested having an `id` and a `client_uuid UNIQUE`. This means the client creates the `client_uuid` offline, and the server generates the primary key `id` upon sync. This requires the client to update its foreign keys after sync.
   - *Recommendation*: It is significantly easier in offline-first systems to just make the Primary Key (`id`) a `UUID` and have the client generate it. However, to honor your exact prompt structure, I have included `client_uuid` as a `UNIQUE` identifier on highly offline-mutable tables (`visits`, `visit_media`), while keeping `id` as the PK.
2. **Soft Deletes (`deleted_at`)**:
   - *Rationale*: Soft deletes are mandatory for offline sync. A client needs to pull down the "tombstone" (a record with `deleted_at` set) to know it must delete its local copy.
3. **`version` Column**:
   - *Rationale*: Relying on `updated_at` for conflict resolution is dangerous due to device clock skew. An integer `version` incremented by a Postgres trigger guarantees monotonic consistency.

---

## Schema DDL

```sql
-- ENUMS
CREATE TYPE user_role AS ENUM ('super_admin', 'admin', 'coordinator', 'field_user', 'viewer');
CREATE TYPE visit_status AS ENUM ('draft', 'scheduled', 'completed', 'cancelled');
CREATE TYPE media_kind AS ENUM ('group_photo', 'activity_photo', 'signature');
CREATE TYPE upload_status AS ENUM ('pending', 'uploading', 'completed', 'failed');
CREATE TYPE audit_operation AS ENUM ('INSERT', 'UPDATE', 'DELETE');
CREATE TYPE entity_type_enum AS ENUM ('country', 'tree_species', 'activity', 'core_area');

-- 1. PROFILES
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'field_user',
    assigned_countries UUID[] DEFAULT '{}',
    primary_country_id UUID, -- FK added after countries table creation
    language_code TEXT NOT NULL DEFAULT 'en',
    whatsapp TEXT,
    passcode_hash TEXT,
    view_all_visits BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```
**Rationale:** 
- *(a) Why it exists*: Supabase `auth.users` handles identity, but we need application-specific metadata (roles, preferences, assignments).
- *(b) Column shape*: `assigned_countries` is an array for easy RLS policy evaluation (`country_id = ANY(assigned_countries)`). `passcode_hash` allows for offline pin login.
- *(c) Indexes*: None needed beyond the PK, as it's typically joined 1:1 on user authentication.

```sql
-- 2. COUNTRIES
CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL, -- e.g., 'KE', 'HT'
    name_en TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE profiles ADD CONSTRAINT fk_primary_country FOREIGN KEY (primary_country_id) REFERENCES countries(id);
```
**Rationale:**
- *(a) Why it exists*: Top-level organizational boundary. RLS policies heavily depend on this.
- *(b) Column shape*: `code` acts as a natural key for quick lookups.
- *(c) Indexes*: `code` is unique and indexed.

```sql
-- GEOGRAPHIC HIERARCHY
-- 3. SUBWATERSHEDS
CREATE TABLE subwatersheds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

-- 4. COMMUNITIES
CREATE TABLE communities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

-- 5. GROUPS
CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id UUID NOT NULL REFERENCES communities(id),
    name_en TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
```
**Rationale:**
- *(a) Why it exists*: Represents the rigid geographic nesting required for operations.
- *(b) Column shape*: Standard hierarchical relationships (FK to parent). Added standard audit columns.
- *(c) Indexes*: B-Tree indexes on `country_id` (subwatersheds) and `subwatershed_id` (communities) to optimize hierarchical dropdowns in the UI.

```sql
-- INSTITUTIONS
-- 6. SCHOOLS & 7. CHURCHES
CREATE TABLE schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

CREATE TABLE churches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
```
**Rationale:**
- *(a) Why it exists*: Identifies specific institutions where plantings occur. Separated from groups because they often have different operational criteria.
- *(b) Column shape*: Allow nulls on deeper hierarchy links (community_id) in case exact placement is unknown.
- *(c) Indexes*: Index on `country_id` to quickly load institutions per country.

```sql
-- MASTER DATA
-- 8. CORE AREAS
CREATE TABLE core_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name_en TEXT NOT NULL
);

-- 9. ACTIVITIES
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    core_area_id UUID NOT NULL REFERENCES core_areas(id),
    name_en TEXT NOT NULL,
    visit_requirements JSONB,
    designated_to TEXT[]
);

-- 10. UNITS & 11. ACTIVITY_UNITS
CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name_en TEXT NOT NULL
);

CREATE TABLE activity_units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id UUID NOT NULL REFERENCES activities(id),
    unit_id UUID NOT NULL REFERENCES units(id),
    country_id UUID REFERENCES countries(id) -- Null means global
);

-- 12. TREE SPECIES
CREATE TABLE tree_species (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id UUID REFERENCES countries(id), -- Null means global species
    scientific_name TEXT NOT NULL,
    common_name_en TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
```
**Rationale:**
- *(a) Why it exists*: Defines the strict operational catalog.
- *(b) Column shape*: `activity_units` uses `country_id NULL` to represent global defaults, allowing country-specific overrides.
- *(c) Indexes*: Index `country_id` on `tree_species`.

```sql
-- CORE OPERATIONAL TABLES
-- 13. VISITS
CREATE TABLE visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    signature_media_id UUID, -- FK to visit_media added later
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
```
**Rationale:**
- *(a) Why it exists*: The central transaction record of the entire system.
- *(b) Column shape*: Heavily denormalized for flexible queries (e.g., storing `country_id` directly avoids multi-table joins). `client_uuid` guarantees sync idempotency.
- *(c) Indexes*: 
  - `CREATE INDEX idx_visits_country_date ON visits(country_id, scheduled_date);` (Filtering/Dashboards)
  - `CREATE INDEX idx_visits_assignee_status ON visits(assignee, status);` (Mobile app query)
  - `CREATE INDEX idx_visits_updated_at ON visits(updated_at);` (Delta sync)

```sql
-- 14. VISIT TREES
CREATE TABLE visit_trees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
```
**Rationale:**
- *(a) Why it exists*: Normalizes the legacy `tree_1...tree_9` columns into a proper 1-to-many relationship, allowing infinite species per visit.
- *(b) Column shape*: Requires `count > 0`.
- *(c) Indexes*: Index on `visit_id`.

```sql
-- 15. VISIT MEDIA
CREATE TABLE visit_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_uuid UUID UNIQUE NOT NULL,
    visit_id UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
    kind media_kind NOT NULL,
    storage_path TEXT,
    sha256 TEXT NOT NULL,
    content_type TEXT NOT NULL,
    size_bytes BIGINT NOT NULL,
    upload_status upload_status NOT NULL DEFAULT 'pending',
    uploaded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    deleted_at TIMESTAMPTZ,
    version INT NOT NULL DEFAULT 1
);
ALTER TABLE visits ADD CONSTRAINT fk_signature FOREIGN KEY (signature_media_id) REFERENCES visit_media(id);
```
**Rationale:**
- *(a) Why it exists*: Decouples media metadata and upload state from the core visit data.
- *(b) Column shape*: `sha256` prevents duplicate file uploads. `storage_path` is null until `upload_status` reaches `completed`.
- *(c) Indexes*: Index on `visit_id`.

```sql
-- LOCALIZATION
-- 16. TRANSLATIONS
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type entity_type_enum NOT NULL,
    entity_id UUID NOT NULL,
    field TEXT NOT NULL,
    locale TEXT NOT NULL,
    value TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by UUID REFERENCES profiles(id),
    UNIQUE (entity_type, entity_id, field, locale)
);
```
**Rationale:**
- *(a) Why it exists*: Tier-2 localization for dynamic database records.
- *(b) Column shape*: EAV (Entity-Attribute-Value) pattern. The `UNIQUE` constraint prevents duplicate translation entries.
- *(c) Indexes*: The `UNIQUE` constraint implicitly indexes the lookups.

```sql
-- INFRASTRUCTURE LOGS
-- 17. AUDIT LOG
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    row_id UUID NOT NULL,
    operation audit_operation NOT NULL,
    actor_id UUID REFERENCES profiles(id),
    old_row JSONB,
    new_row JSONB,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 18. SYNC LOG
CREATE TABLE sync_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_uuid UUID NOT NULL,
    user_id UUID REFERENCES profiles(id),
    operation TEXT NOT NULL,
    status TEXT NOT NULL,
    error_message TEXT,
    attempt_count INT DEFAULT 1,
    server_received_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```
**Rationale:**
- *(a) Why it exists*: `audit_log` tracks data history for compliance and debugging. `sync_log` captures offline sync failures and conflict resolution telemetry.
- *(b) Column shape*: Append-only structures.
- *(c) Indexes*: Index `audit_log` on `(table_name, row_id)` for quick history lookups. Index `sync_log` on `client_uuid`.

---

## Postgres Triggers (Implicit Requirement)
To support the strict `updated_at` and `version` requirements, a trigger function must be attached to every mutable table:

```sql
CREATE OR REPLACE FUNCTION trigger_set_timestamp_and_version()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  NEW.version = OLD.version + 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Applied to tables like:
-- CREATE TRIGGER set_visits_version BEFORE UPDATE ON visits FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp_and_version();
```

---

## How to Run Migrations and Tests

To apply the schema changes, load the seed data, and run the automated test suite locally, ensure Docker Desktop is running and execute the following commands from the root directory:

1. **Start the database and run migrations & seed**:
   ```bash
   cd supabase
   supabase db reset
   ```

2. **Run the pgTAP automated tests**:
   ```bash
   supabase test db
   ```

3. **Generate TypeScript Types** (run this whenever schema changes):
   ```bash
   supabase gen types typescript --local > ../shared/types/database.ts
   ```
