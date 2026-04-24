# Incident Response Runbook

When you're woken up at 3 AM, follow these steps. Do not panic.

## 1. Initial Triage
1. **Acknowledge the alert** in PagerDuty.
2. **Join the incident channel** (e.g., Slack `#incidents`).
3. **Determine impact:** Are users completely blocked? Is data being lost? Or is it just slow?

---

## 2. Scenarios & Mitigation

### A. Supabase Outage (Auth, DB, Storage)
*Supabase services operate independently. Identify which is failing.*

- **Detection:** API latency spikes, high 5xx error rate from Supabase API, Auth token refresh failures.
- **Immediate Mitigation:**
  1. Check [status.supabase.com](https://status.supabase.com).
  2. If DB is maxed on connections, run `shared/scripts/chaos/kill-connections.js` equivalent (if accessible) or restart the instance from the Supabase dashboard.
  3. If storage is down, the mobile app outbox will queue automatically. No manual intervention needed for mobile clients.
- **User Comm Template:** "We are currently experiencing a degraded connection to our main database provider. Field data will continue to save offline on your device and will sync once connection is restored."
- **Post-mortem:** Write up timeline focusing on MTTR and connection pool sizing.

### B. Vercel Outage
- **Detection:** Web admin dashboard returning 502/504 errors. Uptime monitor alerts.
- **Immediate Mitigation:**
  1. Check [vercel-status.com](https://www.vercel-status.com).
  2. If regional outage, trigger a re-deploy with a forced region override if possible, or wait it out. Mobile sync is NOT affected (it hits Supabase directly).
- **User Comm Template:** "The administrative dashboard is currently unavailable. We are working with our hosting provider to restore access. Field app functionality is unaffected."
- **Post-mortem:** Write up impact on back-office operations and evaluate if static fallbacks are needed.

### C. FCM (Firebase Cloud Messaging) Outage
- **Detection:** Delivery failures in Supabase `notification_events` logs.
- **Immediate Mitigation:**
  1. No direct mitigation. Fall back to email/WhatsApp.
  2. The notification edge function has a retry queue.
- **User Comm Template:** Not required unless critical broadcast is missed.
- **Post-mortem:** Review edge function retry queue sizes.

### D. Data Corruption Suspected
- **Detection:** Users reporting missing visits, mismatched photos, or sudden drop in total counts on dashboard.
- **Immediate Mitigation:**
  1. IMMEDIATELY pause the mobile sync endpoint (revoke access to `sync_push` RPC or set a maintenance flag).
  2. Trigger an immediate manual PITR snapshot to preserve current state.
  3. Investigate the timeline. Proceed to DR_DRILL.md (Restore to Sandbox) to verify pre-corruption data.
- **User Comm Template:** "We are performing emergency maintenance on our sync servers to protect your data. Syncing is temporarily paused. Please continue working offline."
- **Post-mortem:** Focus heavily on bug introduction timeline and testing gaps.

### E. Security Breach Suspected
- **Detection:** Unusual spike in data exports, unknown IPs logging into admin accounts.
- **Immediate Mitigation:**
  1. Revoke all active sessions via Supabase Auth dashboard.
  2. Rotate database passwords and service role keys.
  3. Rotate GitHub and Vercel secrets.
  4. Block suspicious IP ranges at the Cloudflare/Supabase WAF level.
- **User Comm Template:** "We have detected unusual activity and have invalidated all active sessions as a precaution. Please log in again."
- **Post-mortem:** Identify attack vector and remediate immediately. Review audit logs.

### F. Payment/Billing Issue Causing Service Suspension
- **Detection:** "Quota Exceeded" alerts or abrupt complete shutdown of Supabase/Vercel.
- **Immediate Mitigation:**
  1. Log into the provider dashboard.
  2. Update the credit card or click "Upgrade/Unpause".
  3. Contact support with "URGENT - PROD DOWN" if account is frozen.
- **User Comm Template:** "We are resolving an infrastructure vendor issue. Services will resume shortly."
- **Post-mortem:** Establish billing alerts at 50% and 80% quotas.

---

## 3. Post-Incident Process
1. Verify system is stable for at least 30 minutes.
2. Resolve PagerDuty alert.
3. Write Post-Mortem within 48 hours using `shared/docs/post-mortems/TEMPLATE.md`.
