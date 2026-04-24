# Disaster Recovery Drill Runbook

**Goal:** Backups are worthless if you've never restored them. This runbook proves the system survives real incidents BEFORE it has to.

## Schedule
**Frequency:** Quarterly (Q1, Q2, Q3, Q4)
**Target RTO (Recovery Time Objective):** 4 hours for full restore.
**Target RPO (Recovery Point Objective):** 1 hour (covered by Supabase PITR on Pro plan).

## Section A — Backup Restoration Drill

1. **Preparation:**
   - Pick a target date/time $T$ (e.g., 2 hours ago).
   - Document the expected state at $T$ from the production database:
     - Total user count
     - Total visit count
     - Total media count

2. **Trigger Point-in-Time Recovery (PITR):**
   - Log into Supabase Dashboard.
   - Navigate to the SANDBOX Supabase project.
   - Trigger a PITR to $T-1h$.

3. **Verification Steps:**
   - [ ] **Counts Match:** Verify that user, visit, and media counts match the expected state at $T-1h$.
   - [ ] **RLS Intact:** Run a test script to ensure Row Level Security policies are actively enforced.
   - [ ] **Auth Check:** Attempt login with a known sample user account.
   - [ ] **Data Integrity:** Fetch a sample visit created right before $T-1h$ and ensure it has the correct photos attached.

4. **Log the Drill:**
   - Time the full restore process end-to-end.
   - Log the results in `shared/docs/dr-drills/YYYY-QN.md`.

## Section B — Media Backup + Restore Drill

1. **Preparation:**
   - Ensure the weekly rclone mirror from Supabase Storage → Cloudflare R2 is active.
   
2. **Execution:**
   - Pick 10 random media files (images/signatures) from the production Supabase Storage.
   - **Delete** them from the primary Supabase Storage.
   
3. **Restoration:**
   - Fetch the corresponding files from the Cloudflare R2 backup bucket.
   - Re-upload them to Supabase Storage.
   
4. **Verification:**
   - Verify integrity by comparing the SHA-256 hashes of the restored files against the originals (or ensuring they load correctly in the UI).
   - Document the completion of this media drill in the quarterly DR drill report.

## Section F — Tabletop Exercise

**Frequency:** Once before go-live, twice a year thereafter.

1. **Setup:**
   - Gather key engineering and product stakeholders.
   - Pick a scenario (e.g., "A user reports their 50 visits disappeared" or "Our SSL certificate expired silently").
2. **Execution:**
   - Walk through the full response without actually touching production.
   - Trace the exact commands you would run, the dashboards you would look at, and the communication you would send.
3. **Output:**
   - Document gaps in tooling, missing dashboards, or runbook deficiencies that emerged.
   - Create Jira/Linear tickets to fix these gaps.

## Section G — Monitoring Alerts Calibrated

Review these alert thresholds quarterly during the DR drill to prevent alert fatigue:

- **Error rate > 1% for 5 min** → PagerDuty (High Urgency)
- **Sync success rate < 95% for 15 min** → Email (Medium Urgency)
- **API p95 > 2s for 10 min** → Email (Medium Urgency)
- **Supabase quota > 80%** → Email weekly (Low Urgency)
- **Storage quota > 80%** → Email weekly (Low Urgency)

**Alert Fatigue Check:** Any alert that fires > 3x/week without pointing to a real actionable issue gets re-tuned immediately.
