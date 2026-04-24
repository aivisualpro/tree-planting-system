# Deployment & CI/CD Guide

This document outlines the production-ready deployment pipeline for the Tree Planting System, covering environment management, continuous integration, mobile app store preparation, web deployment, and monitoring.

## Section A — Environment Management

### Environments Overview
- **Local:** `supabase start` + `pnpm dev` (web) + `flutter run` (mobile)
- **Staging:** Separate Supabase Cloud project + Vercel preview + TestFlight + Play Internal Testing
- **Production:** Supabase Cloud (Pro plan) + Vercel production + App Store + Play Production

### Environment Variables
**Web (`web/.env`):**
See `web/.env.example` for all required variables:
- `SUPABASE_URL`: Public Supabase API URL.
- `SUPABASE_ANON_KEY`: Public anonymous API key.
- `SUPABASE_SERVICE_ROLE_KEY`: Secret service role key (requires secure handling).
- `SENTRY_DSN`: Sentry Data Source Name for error tracking.

**Mobile (`mobile/env/`):**
We use `--dart-define-from-file` for environment configuration.
- `local.example.json` (committed) serves as the template.
- `local.json`, `staging.json`, and `production.json` are generated and kept out of version control (`.gitignore`).

### Secret Management
- **Local Development:** 1Password CLI is recommended to securely inject secrets during local setup.
- **CI/CD:** GitHub encrypted secrets are utilized within GitHub Actions workflows.
- **Web:** Vercel Environment Variables dashboard is used to inject production and staging secrets securely.
- **Mobile:** App Store Connect and Google Play Console are used for mobile store metadata and secret configuration.

## Section B — CI/CD (.github/workflows/)

Our CI/CD pipelines automate building, testing, and deployment across web, mobile, and backend services.

- **`web.yml`:** 
  - On PR: Executes linting, type checking, unit tests, and the build process.
  - On push to `main`: Deploys to Vercel production and triggers a Slack notification.
  - On PR / feature branch: Deploys to Vercel preview environments.
- **`supabase.yml`:** 
  - On PR: Spins up a test PostgreSQL instance in services, applies migrations, and runs pgTAP tests.
  - On push to `main`: Automatically applies migrations to staging. Manual approval is required for deploying to production. Post a Slack notification on every deploy.
- **`mobile.yml`:**
  - On PR: Runs `flutter analyze`, `flutter test`, and builds unsigned APK & IPA.
  - On tag `mobile-v*`: Builds signed APK & IPA, and uploads them to Play Internal Testing and TestFlight via Fastlane.
- **`types-check.yml`:**
  - On every PR: Regenerates types from the staging environment and fails the build if `shared/types/database.ts` is out of sync.

## Section C — Mobile Store Preparation

### iOS (App Store)
- **Fastlane:** Configuration located in `mobile/ios/fastlane/` (`Fastfile`, `Appfile`, `Matchfile` for signing certs via a private match repository).
  - `fastlane beta` deploys to TestFlight.
  - `fastlane release` submits to the App Store.
- **App Store Connect Metadata:** Includes proper descriptions, exactly 6 real-field scenario screenshots (no stock photos), privacy policy URL, and support URL.
- **Privacy Manifest:** `PrivacyInfo.xcprivacy` explicitly declares all collected data types: Location, User Content (Photos), and Identifiers (Device ID).
- **Push Notifications:** Deferred unless explicitly required. Not enabled by default.

### Android (Google Play)
- **Fastlane:** Equivalent configuration located in `mobile/android/fastlane/`.
  - `fastlane beta` deploys to Play Internal Testing.
  - `fastlane release` performs a staged rollout to Play Production (10% → 50% → 100% over 72 hours).
- **SDK Requirements:** `targetSdk` is 34+, and `minSdk` is 23.
- **Play Store Listing:** Utilizes the same 6 real-field scenario screenshots.
- **Data Safety:** Form filled out to match actual data collection, aligning exactly with the iOS privacy manifest.

## Section D — Web Deployment (Vercel)

- **`vercel.json` Configuration:**
  - **Framework:** Nuxt
  - **Build Command:** `pnpm build`
  - **Output Directory:** `.output/public`
  - **Regions:** Closest to the user base (`iad1` and `cdg1` for optimal Africa/Europe coverage).
- **Vercel Dashboard:** Environment variables are strictly managed through the Vercel dashboard and not committed to the repository.
- **GitHub Integration:** Vercel is connected to GitHub for automatic production deployments on `main` pushes and preview deployments for PRs.
- **Domain:** Custom domain configured with enforced HTTPS.

## Section E — Supabase Deployment

- **Infrastructure:** Separate projects on Supabase Cloud for staging and production. The production project utilizes the Pro plan ($25/mo).
- **Point-in-Time Recovery (PITR):** Enabled on the production environment (Pro feature) for granular data restoration capabilities.
- **Backups:**
  - Daily automatic backups by Supabase.
  - Additional weekly `pg_dump` to an S3-compatible cold storage (via scheduled GitHub Actions cron job).
- **Media Bucket Backup:** Weekly `rclone` mirror operation syncing the Supabase Storage media bucket to Cloudflare R2 (~$0.015/GB/mo storage).

## Section F — Monitoring & Observability

- **Sentry:** One organization with three dedicated projects (web, mobile, supabase-functions). Source maps are uploaded in CI via `sentry-cli`. Releases are tagged on every deploy.
- **Uptime Monitoring:** BetterStack or UptimeRobot pings `/api/health` every minute. PagerDuty/email alerts are triggered on outages exceeding 2 minutes.
- **Logs:** Axiom or Grafana Cloud ingests logs from Nuxt and Supabase. The dashboard visualizes:
  - Error rates
  - API p95 latency
  - Synchronization success rate
  - Active users
  - Failed media uploads
- **Cost Monitoring:** Supabase billing alert configured at 80% of budget. Vercel usage alerts are enabled.
