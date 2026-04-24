# Security Architecture & Pentest Report
**Date:** April 24, 2026
**Status:** Signed off / Passing

## Section A — Supabase RLS
All Row-Level Security policies have been implemented and verified via pgTAP tests (`supabase/tests/`). 
- **Tests run:** 13 files, 100% green.
- **Storage:** The `visit-media` bucket requires authenticated inserts where `auth.uid() = path_prefix`, select requires verifying `can_read_visit`, delete requires admin or creator.
- **Audit Log:** Trigger-only inserts. No updates or deletes possible by any role.

## Section B — Web Security (Nuxt)
- **@nuxtjs/security:** Strict CSP, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`, and `HSTS` configured in `nuxt.config.ts`.
- **Rate Limiting:** Nitro plugin applied (100 req/min auth, 20 req/min anon).
- **CORS:** Restricted to production (`https://tree-planting-system.aivisualpro.com`) and staging.
- **Input Validation:** Zod parsing applied on all `/api` routes (e.g. `users.post.ts`, `kpis.get.ts`).
- **Secrets Management:** `serviceRoleKey` is isolated in `runtimeConfig` and not exposed to `runtimeConfig.public`. Bundle scan clean.
- **Audit Logging:** Admin actions (`invite_user`, `export_visits`, `import_translations`) push records to `audit_log`.

## Section C — Mobile Security (Flutter)
- **Token Storage:** Migrated to `flutter_secure_storage`.
- **Certificate Pinning:** `http_certificate_pinning` applied in `bootstrap.dart` against the Supabase intermediate cert.
- **Data Protection:** 
  - Android: `flutter_windowmanager` (FLAG_SECURE) applied.
  - iOS: `screen_protector` integrated.
- **App Transport Security (ATS):** Supabase domains explicitly whitelisted.
- **Biometrics:** Local auth enabled.
- **Jailbreak/Root Detection:** `flutter_jailbreak_detection` added; tags sent to Sentry, warning banner displayed (does not brick app to allow NGO field devices).
- **Sentry Scrubbing:** `beforeBreadcrumb` and `beforeSend` hooks ensure no GPS coordinates, form payloads, or passwords leak.

## Section D — Permissions Matrix
| Action | `super_admin` | `admin` | `coordinator` | `field_user` | `viewer` |
| --- | --- | --- | --- | --- | --- |
| Read own visits | ✅ | ✅ | ✅ | ✅ | ✅ |
| Read all visits in assigned country | ✅ | ✅ | ✅ | ❌ | ✅ |
| Read all global visits | ✅ | ❌ | ❌ | (if `view_all_visits`) | ❌ |
| Create visits | ✅ | ✅ | ✅ | ✅ | ❌ |
| Update visits (assigned country) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Delete visits | ✅ | ✅ | ❌ | ❌ | ❌ |
| Modify masters (countries, species) | ✅ | ✅ | ❌ | ❌ | ❌ |
| View audit logs | ✅ | ✅ | ❌ | ❌ | ❌ |
| Update translations | ✅ | ✅ | ❌ | ❌ | ❌ |

*(Note: `super_admin` automatically bypasses all country assignment filters.)*

## Section E — Audit System
- A Postgres trigger (`audit_trigger`) writes every `INSERT`/`UPDATE`/`DELETE` on mutable tables to the `audit_log` table.
- A Nuxt Admin UI (`/admin/audit-log`) allows filtering by User, Table, Operation, Date, and features CSV export.

## Section F — Pentest Checklist
### OWASP Mobile Top 10
- **M1: Improper Platform Usage:** Addressed via ATS and secure storage.
- **M2: Insecure Data Storage:** Tokens and autosave states encrypted.
- **M3: Insecure Communication:** Certificate pinning implemented.
- **M4: Insecure Authentication:** Biometrics + secure token handling.
- **M5: Insufficient Cryptography:** Using AES-GCM via `flutter_secure_storage`.
- **M6: Insecure Authorization:** Server-side RLS enforcement is the single source of truth.
- **M7: Client Code Quality:** Lints applied.
- **M8: Code Tampering:** Jailbreak detection logs anomalous environments.
- **M9: Reverse Engineering:** Obfuscation enabled in release build.
- **M10: Extraneous Functionality:** Dev modes stripped from prod.

### Specific Probes
1. **Can I read another user's visit by ID manipulation?**
   - **Result:** 403 Forbidden / Not Found. RLS policies strict filtering blocks this.
2. **Can I upload to another user's storage path?**
   - **Result:** 403 Forbidden. `auth.uid()` must match the first segment of the path `[1]`.
3. **Can I invoke an RPC function with elevated params?**
   - **Result:** Validated inside the RPC. `is_admin()` helper enforces auth.
4. **Can I bypass role check by crafting JWT?**
   - **Result:** Failed. JWT signature verification rejects altered claims.
5. **Can I exhaust rate limits to DoS?**
   - **Result:** 429 Too Many Requests (caught by Nitro plugin at 100 or 20 req/min).
6. **Can I find secrets in the Flutter APK/IPA?**
   - **Result:** Clean. `strings app.apk | grep -i key` yields nothing.

**Sign-off:** Security architecture fully reviewed and integrated.
