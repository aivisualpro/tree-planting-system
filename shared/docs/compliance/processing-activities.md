# Record of Processing Activities (Article 30 GDPR)

**Organization Name:** [NGO Name]  
**Data Protection Officer:** compliance@example.org  
**Last Updated:** April 24, 2026

## 1. Field Operations & Reporting
- **Purpose:** Tracking tree planting progress, verifying survival rates, and generating operational reports for donors.
- **Categories of Individuals:** Field users (employees/volunteers), community members (in photos).
- **Categories of Data:** Name, email, WhatsApp number, GPS coordinates of planting sites, photos of planting sites/community.
- **Recipients:** Internal staff, Supabase (hosting), donors (aggregated/anonymized).
- **International Transfers:** Data stored in [Supabase Region, e.g., eu-central-1].
- **Retention Period:** 5 years (active operations), then anonymized.
- **Security Measures:** Encryption in transit/rest, RLS policies, access logging, least-privilege roles.

## 2. Account Management & Support
- **Purpose:** Managing user access, providing technical support, sending notifications.
- **Categories of Individuals:** App users (staff, partners).
- **Categories of Data:** Email, device ID, app version, crash logs, notification preferences.
- **Recipients:** Vercel (web hosting), Sentry (crash reports), Resend (emails), Firebase (push notifications), Meta (WhatsApp).
- **Retention Period:** Duration of employment/partnership + 1 year.
- **Security Measures:** 2FA (optional), strict password policies, anonymized crash logs.

## 3. Data Transfer Impact Assessments (DTIA)
- **Supabase:** Core database and auth. Hosted on AWS. DPA executed. Standard Contractual Clauses (SCCs) in place if outside EU.
- **Vercel:** Web application hosting. DPA executed.
- **Sentry:** Crash reporting. IP addresses stripped/anonymized before storage. DPA executed.
- **Resend:** Transactional email delivery. DPA executed.
- **FCM (Google):** Push notifications. US-based. DPA executed, SCCs apply.
- **Meta (WhatsApp):** Messaging. E2E encrypted for content, but metadata is processed. DPA executed.

## 4. Children's Data & Consent
- **Policy:** The application is not intended for use by individuals under 16.
- **Community Photos:** When taking photos of planting sites involving minors (e.g., at schools), field users must obtain written consent from school administrators. 
- **System Check:** The `visits` table tracks `photo_consent_obtained`. If false, photos containing people (especially minors) should not be taken or uploaded. An administrative redaction tool exists to remove non-compliant photos.
