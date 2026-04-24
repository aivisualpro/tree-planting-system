-- Section F: Data retention policy enforcement

-- 1. Weekly job to clean up old logs
SELECT cron.schedule(
    'weekly-cleanup-logs',
    '0 0 * * 0', -- Every Sunday at midnight
    $$
    DO $$
    DECLARE
        v_sync_count INT;
        v_audit_count INT;
    BEGIN
        -- Hard-delete sync_log entries older than 1 year
        DELETE FROM sync_log WHERE created_at < now() - interval '1 year';
        GET DIAGNOSTICS v_sync_count = ROW_COUNT;

        -- Hard-delete audit_log entries older than 2 years
        DELETE FROM audit_log WHERE occurred_at < now() - interval '2 years';
        GET DIAGNOSTICS v_audit_count = ROW_COUNT;

        INSERT INTO retention_log (job_name, records_deleted, status)
        VALUES ('weekly-cleanup-logs', v_sync_count + v_audit_count, 'success');
    EXCEPTION WHEN OTHERS THEN
        INSERT INTO retention_log (job_name, status, error_message)
        VALUES ('weekly-cleanup-logs', 'failed', SQLERRM);
    END $$;
    $$
);

-- 2. Daily job to delete media for soft-deleted visits > 30 days ago
SELECT cron.schedule(
    'cleanup-deleted-media',
    '0 0 * * *', -- Every day at midnight
    $$
    DO $$
    DECLARE
        v_media_count INT;
    BEGIN
        -- Hard-delete media for visits soft-deleted > 30 days ago
        WITH target_visits AS (
            SELECT id FROM visits WHERE deleted_at IS NOT NULL AND deleted_at < now() - interval '30 days'
        )
        DELETE FROM visit_media WHERE visit_id IN (SELECT id FROM target_visits);
        GET DIAGNOSTICS v_media_count = ROW_COUNT;

        INSERT INTO retention_log (job_name, records_deleted, status)
        VALUES ('cleanup-deleted-media', v_media_count, 'success');
    EXCEPTION WHEN OTHERS THEN
        INSERT INTO retention_log (job_name, status, error_message)
        VALUES ('cleanup-deleted-media', 'failed', SQLERRM);
    END $$;
    $$
);
