CREATE TYPE user_role AS ENUM ('super_admin', 'admin', 'coordinator', 'field_user', 'viewer');
CREATE TYPE visit_status AS ENUM ('draft', 'scheduled', 'completed', 'cancelled');
CREATE TYPE sync_status AS ENUM ('draft', 'pending', 'syncing', 'synced', 'failed');
CREATE TYPE media_kind AS ENUM ('group_photo', 'activity_photo', 'signature');
CREATE TYPE media_upload_status AS ENUM ('pending', 'uploading', 'completed', 'failed');
CREATE TYPE translation_entity_type AS ENUM ('country', 'tree_species', 'activity', 'core_area');
CREATE TYPE audit_operation AS ENUM ('INSERT', 'UPDATE', 'DELETE');
