# Operational Runbook

This runbook covers common operational tasks, incident response procedures, and escalation paths for the Tree Planting System.

## 1. System Architecture Overview
- **Web App**: Nuxt.js hosted on Vercel.
- **Mobile App**: Flutter (iOS & Android) with Drift offline DB.
- **Database & Auth**: Supabase (PostgreSQL).
- **Storage**: Supabase Storage for media.

## 2. Contact & Escalation Plan
- **Tier 1 (Basic Support):** Client Internal Coordinator
- **Tier 2 (Technical Support):** Lead Developer (support@treeplanting.com) - *30-day hypercare period*
- **Tier 3 (Infrastructure):** Vercel / Supabase Support

## 3. Common Issues & Resolutions

### Issue 1: "User cannot log in on mobile app"
- **Cause:** Incorrect credentials, network issue, or account suspended.
- **Fix:**
  1. Verify the user exists in Supabase Auth.
  2. Reset password via the Supabase Dashboard if necessary.
  3. Ensure the user's mobile device has network connectivity for the initial login token generation.

### Issue 2: "Visits are not syncing from the field"
- **Cause:** Large media queue, poor connection, or database schema mismatch.
- **Fix:**
  1. Check Sentry logs for `SyncTimeoutException` or `PostgrestError`.
  2. Ask the user to keep the app open in the foreground while connected to Wi-Fi.
  3. Verify Supabase Realtime/REST API is operational via `status.supabase.com`.

### Issue 3: "Web Dashboard is slow to load"
- **Cause:** Unoptimized queries or excessive data volume.
- **Fix:**
  1. Check Vercel logs for slow API responses.
  2. Ensure Supabase indexes (e.g., on `created_at`, `user_id`) are active.
  3. Inform Tier 2 to run `pg_stat_statements` on Supabase to isolate the slow query.

## 4. Routine Maintenance

### Weekly
- Review Sentry for emerging errors.
- Review "Feedback Reports" table for unhandled user complaints.

### Monthly
- Review Vercel bandwidth usage (Alert threshold: 80%).
- Review Supabase database size and storage limits (Alert threshold: $50/mo overages).
- Rotate API keys if staff turnover occurs.

## 5. Incident Response: Supabase Outage
1. **Detection:** Vercel logs spike in 500 errors; mobile apps show persistent offline state.
2. **Action:**
   - Verify outage on `status.supabase.com`.
   - Send broadcast message (SMS or WhatsApp) to field coordinators: "System is experiencing cloud issues. Please continue to work offline. Your data is safe on your phone."
3. **Recovery:** Once resolved, instruct field workers to open the app while connected to Wi-Fi to process the sync backlog.
