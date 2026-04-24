# Incident Response Playbook

This playbook outlines the steps to take in the event of a security incident or data breach.

## 1. Detection and Identification
- **Alert Sources:** Sentry anomaly alerts, Supabase audit logs, user reports, automated security scans.
- **Initial Triage:** The on-call engineer assesses the alert to determine if it is a false positive or a legitimate incident.
- **Classification:** Categorize the incident (e.g., Unauthorized Access, Data Exfiltration, Denial of Service).

## 2. Containment
- **Immediate Actions:**
  - Revoke compromised credentials or API keys.
  - Disable affected user accounts via Supabase Admin.
  - Apply emergency firewall rules or rate limits.
  - If a specific endpoint/feature is exploited, temporarily disable it.
- **Short-Term Containment:** Isolate the affected systems from the rest of the network without destroying evidence.

## 3. Eradication
- **Root Cause Analysis:** Identify the vulnerability that was exploited.
- **Remediation:** Patch the vulnerability, update dependencies, fix configuration errors, or improve input validation.
- **Clean Up:** Remove any malicious artifacts, backdoors, or unauthorized accounts created by the attacker.

## 4. Recovery
- **Restoration:** Restore services from clean backups if data was corrupted or destroyed (using Supabase PITR).
- **Validation:** Test the affected systems to ensure the vulnerability is fully remediated and services are functioning normally.
- **Monitoring:** Implement enhanced monitoring on the affected systems for the next 48-72 hours.

## 5. Notification (Under GDPR & DPA)
- **Authorities:** If the breach poses a risk to individuals' rights and freedoms, notify the relevant supervisory authority (e.g., Information Commissioner's Office, Tanzania PDPC) within **72 hours** of becoming aware of the breach.
- **Individuals:** If the breach is likely to result in a *high risk* to individuals, notify the affected individuals without undue delay.
- **Communication:** Draft a clear, concise statement explaining what happened, what data was involved, what we are doing, and what users should do.

## 6. Lessons Learned
- **Post-Mortem:** Conduct a blameless post-mortem meeting within 1 week of the incident.
- **Documentation:** Document the timeline of events, what went wrong, what went right, and action items to prevent recurrence.
- **Process Improvement:** Update this playbook and relevant security documentation based on findings.
