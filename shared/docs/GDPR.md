# GDPR Compliance and Data Portability Policy

## Overview
The Tree-Planting System is committed to protecting user privacy and ensuring compliance with the General Data Protection Regulation (GDPR). This document outlines our data retention, portability, and erasure policies.

## 1. Data Portability (Right to Access)
Users have the right to download a copy of their personal data in a structured, commonly used, and machine-readable format.
- **Access**: Available at `/settings/privacy` via the "Download My Data" button.
- **Format**: ZIP archive containing `profile.json`, `visits.json`, `audit_log_self.json`, and associated media metadata.
- **Frequency**: Restricted to once per 24-hour period to prevent server abuse.

## 2. Right to Erasure (Right to Be Forgotten)
Users can request the anonymization of their account. 
- **Process**: Users must confirm their email at `/settings/privacy` to trigger the "Anonymize My Account" flow.
- **Anonymization**: We do not perform a hard-delete of visit records, as they are required for NGO reporting obligations (often 5–10 years). Instead:
  - `profiles.full_name` is replaced with "REDACTED_USER".
  - `profiles.whatsapp` is cleared.
  - `device_tokens` and `notification_events` are permanently deleted.
  - All audit logs for the user are updated to reflect the anonymization event.
- **Sentinel Profile**: The user's ID remains in the database to maintain referential integrity with historical visits, but all PII is removed from the associated record.

## 3. Data Retention Policy
To ensure system performance and minimize data footprint, the following automated cleanup jobs are enforced:
- **Sync Logs**: Entries older than **1 year** are hard-deleted weekly.
- **Audit Logs**: Entries older than **2 years** are hard-deleted weekly (after potential archival to cold storage).
- **Soft-Deleted Media**: Media associated with visits marked as deleted for more than **30 days** are hard-deleted daily.

## 4. Administrative Oversight
Admins have the capability to:
- Export data on behalf of a user for compliance requests.
- Manually trigger anonymization for users who have requested it via offline channels.
- Review `retention_log` to verify automated cleanup jobs are running successfully.

## 5. Contact
For any data-related queries, please contact the Data Protection Officer at dpo@plantwithpurpose.org.
