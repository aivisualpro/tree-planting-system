# On-Call Playbook

This document serves as the single source of truth for on-call operations and emergency response for the Tree-Planting System.

## General Response Guidelines
1. **Acknowledge**: Respond to the alert immediately to indicate someone is investigating.
2. **Triage**: Assess severity (P0 vs P1). 
3. **Communicate**: Post an update in the appropriate communication channels (e.g., Slack, Email to stakeholders).
4. **Mitigate**: Apply temporary fixes or revert the offending changes as quickly as possible.
5. **Resolve**: Develop and deploy a permanent fix once the situation is stable.
6. **Post-Mortem**: Document what happened, why, and how to prevent it.

## Common Alerts and First-Response

### Alert: High API Error Rate (> 5%)
- **Symptoms**: Sentry reports a spike in 5xx errors from Nuxt or Supabase. Mobile app users see "Sync Failed" messages.
- **First Response**:
  1. Check Vercel logs for Nuxt deployments. Rollback to the previous deployment if a recent release correlates with the errors.
  2. Check Supabase Dashboard -> Database Health. Look for CPU/Memory spikes.
  3. Inspect recent database migrations.

### Alert: Database Connection Limits Reached
- **Symptoms**: Log errors indicating `max_connections` or `connection pool full`.
- **First Response**:
  1. Verify Supavisor (connection pooler) is active.
  2. Increase connection limits temporarily via Supabase settings.
  3. Identify rogue queries using `pg_stat_activity` and kill them if necessary.

### Alert: Mobile App Crash Rate (< 99.5% Crash-Free Users)
- **Symptoms**: Sentry shows an influx of unhandled exceptions from Android/iOS.
- **First Response**:
  1. Halt the staged rollout in Play Console / App Store Connect immediately.
  2. Use Feature Flags to disable the crashing feature if gated.
  3. Prepare a hotfix release.

## Escalation Path

As the solo maintainer, the escalation path primarily involves client stakeholders when service objectives cannot be met.

1. **Initial Investigation**: 0 - 2 hours.
2. **Client Update**: If the issue is not mitigated within 2 hours, notify the primary client contact via Email and WhatsApp/SMS.
3. **Escalation**: If unreachable or offline for > 4h during a known P0 incident, an automated notification to stakeholders should be triggered.

## Service Level Objectives (SLOs)

### Recovery Time Objectives (RTO)
- **P0 (Critical - Complete Outage or Data Loss)**: 4 hours
- **P1 (High - Degraded performance or broken core feature)**: 24 hours

### Recovery Point Objectives (RPO)
- **RPO**: 1 hour. This is covered by Supabase Point-In-Time Recovery (PITR), which allows restoring the database to any minute within the retention window.
