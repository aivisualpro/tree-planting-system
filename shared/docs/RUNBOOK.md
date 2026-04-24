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

## 6. Staged Rollout (Mobile)

We utilize a staged rollout process for mobile applications to minimize the blast radius of critical bugs.

### Android (Play Console)
- **Day 1**: 10% rollout. Monitor Sentry for new crashes or ANRs.
- **Day 2**: 50% rollout. Monitor backend error rates and database load.
- **Day 3**: 100% rollout. 
- **Halt Condition**: If the Sentry crash-free-users rate dips below 99.5%, immediately halt the rollout.

### iOS (App Store Connect)
- **Phased Release**: We use Apple's built-in 7-day phased release mechanism.
- **Halt Condition**: Similar to Android, pause the phased release if crash-free sessions dip below 99.5%.

## 7. Rollback Playbook

### Web Application (Nuxt / Vercel)
Vercel supports instant rollbacks.
1. Navigate to the Vercel Dashboard -> Project -> Deployments.
2. Find the last known good deployment.
3. Click "Promote to Production" (or "Rollback" via the CLI: `vercel rollback`).

### Mobile Application (Flutter)
**Important**: Store releases cannot be rolled back; you can only roll forward.
Emergency plan sequence:
1. **Feature Flags**: If the issue is isolated to a new feature, immediately toggle the feature flag off via the Admin UI or Database (`< 5 min`).
2. **Schema Issue**: If the bug is caused by a missing column or incorrect schema, deploy a compensating forward migration to production (`< 30 min`).
3. **Hard Crash (No Flag)**: If the app crashes on startup and cannot be flagged off:
   - Prepare a hotfix release.
   - Deploy immediately to 10% of users.
   - Ramp to 100% within 4 hours if metrics remain stable.
   - Optionally use the Force Update Mechanism to block older, crashing versions.

### Database (Supabase)
Migrations in Supabase are forward-only by default. 
1. Do **NOT** try to revert migrations manually by deleting tracking rows.
2. Instead, run the corresponding `down.sql` companion file using `psql` or the Supabase CLI, OR write a new migration that reverses the changes of the bad migration.
3. Every migration must have an accompanying `down.sql` to facilitate this process.

## 8. Hotfix Process

A hotfix is required for P0 issues in production.

1. **Branching**: Branch off `main` to create a `hotfix/description` branch.
2. **Staging Deploy**: Deploy the fix to the staging environment (`staging` branch / project).
3. **Smoke Test**: Perform a rapid manual smoke test of the critical path.
4. **Production Deploy**: Merge to `main`. Deploy to 10% production rollout (for mobile) or direct deploy for web.
5. **Monitor**: Monitor Sentry and logs closely for 2 hours.
6. **Ramp**: Ramp up to 100% after the monitoring window.

### User Communication Template
Use this template for major incidents (Email + In-App Banner):
> **Subject**: Issue regarding [Feature Name]
> 
> We are currently experiencing an issue that may affect your ability to use [Feature/App]. Our engineering team is actively investigating and working on a resolution. We will provide another update within [Timeframe]. We apologize for the inconvenience.

## 9. Environment Promotion

We maintain strict environment isolation:

- **Local**: Development environment on your machine.
- **Staging**: Mirrors the production schema exactly. All migrations MUST be tested here first.
- **Production**: The live environment.

### Data Synchronization
- The data in the Staging database is an anonymized snapshot of Production data.
- This snapshot is automatically refreshed weekly via a scheduled GitHub Action or Supabase Edge Function to ensure staging tests are run against realistic data volumes.
