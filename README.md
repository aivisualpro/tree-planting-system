# 🌳 Tree-Planting Field Operations System

A production-grade field operations platform for an international tree-planting NGO, replacing a legacy AppSheet deployment with a modern, offline-first, multi-language solution built for 300+ field users across multiple countries.

---

## What It Does

Field workers use a **mobile app** (Android + iOS) to record tree plantings, site surveys, photo evidence, and GPS coordinates — even in areas with **zero internet connectivity**. Data syncs automatically when a connection becomes available. Back-office staff manage operations, reporting, and user administration through a **web dashboard**.

### Key Capabilities

- **Offline-first mobile app** — full CRUD operations with no network required
- **Automatic sync** — conflict-free bidirectional data sync via Supabase Realtime
- **Multi-language UI** — English, Spanish, French, Amharic, Swahili, Chichewa, Thai, Haitian Creole (new languages added without code changes)
- **Role-based access** — field workers, supervisors, regional managers, admins
- **Photo & GPS capture** — geotagged evidence attached to planting records
- **Real-time dashboards** — live operational metrics for back-office teams

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile** | Flutter (Dart) | Android + iOS from a single codebase |
| **Web** | Nuxt 4.2 (Vue 3) | Admin dashboard & reporting |
| **Backend** | Supabase | Postgres, Auth, Storage, Realtime, Edge Functions |
| **Database** | PostgreSQL 15+ | Primary data store with Row Level Security |
| **Deployment** | Vercel (web), Supabase Cloud (backend), App Store + Play Store (mobile) |

---

## Repository Structure

```
tree-planting/
├── web/                        # Nuxt 4.2 app (template dropped in later)
├── mobile/                     # Flutter app (scaffolded later)
├── supabase/                   # Supabase project
│   ├── migrations/             # Ordered SQL migration files
│   ├── functions/              # Deno-based Edge Functions
│   ├── tests/                  # pgTAP database tests
│   ├── seed.sql                # Development seed data
│   └── config.toml             # Supabase local dev config
├── shared/
│   ├── i18n/                   # Translation JSON files (source of truth)
│   │   ├── en.json             # English
│   │   ├── es.json             # Español
│   │   ├── fr.json             # Français
│   │   ├── am.json             # አማርኛ (Amharic)
│   │   ├── sw.json             # Kiswahili
│   │   ├── ny.json             # Chichewa
│   │   ├── th.json             # ไทย (Thai)
│   │   └── ht.json             # Kreyòl Ayisyen (Haitian Creole)
│   ├── types/                  # Auto-generated TypeScript types from DB schema
│   ├── scripts/                # Migration runners, codegen, utilities
│   └── docs/                   # Architecture, schema, sync, security docs
├── .github/workflows/          # CI/CD pipelines (GitHub Actions)
├── .gitignore
├── .editorconfig
├── README.md                   # ← You are here
└── CONTRIBUTING.md             # Dev workflow & conventions
```

---

## Local Development

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | 20+ LTS | [nodejs.org](https://nodejs.org) |
| pnpm | 9+ | `npm i -g pnpm` |
| Flutter | 3.24+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Supabase CLI | 1.200+ | `brew install supabase/tap/supabase` |
| Docker | 24+ | [docker.com](https://www.docker.com/get-started) (required by Supabase local) |

### 1. Start the Backend (Supabase Local)

```bash
cd supabase
supabase start
```

This spins up a local Postgres database, Auth server, Storage server, and Realtime engine via Docker. On first run it will pull the required images (~2 min).

After startup you'll see local credentials printed to the terminal:
- **API URL**: `http://localhost:54321`
- **anon key**: used by frontend clients
- **service_role key**: used by Edge Functions (server-side only)
- **Studio**: `http://localhost:54323` (visual DB browser)

### 2. Start the Web Dashboard

```bash
cd web
pnpm install   # first time only
pnpm dev
```

Opens at `http://localhost:3000` by default.

### 3. Start the Mobile App

```bash
cd mobile
flutter pub get   # first time only
flutter run
```

Targets a connected device or emulator. Use `flutter run -d chrome` for quick web preview during development.

### 4. Run Database Migrations

```bash
cd supabase
supabase db reset   # drops, recreates, runs all migrations + seed.sql
```

### 5. Generate TypeScript Types

```bash
cd supabase
supabase gen types typescript --local > ../shared/types/database.ts
```

---

## Environment Variables

Create `.env` files as needed (never commit them):

| File | Purpose |
|------|---------|
| `supabase/.env` | Edge Function secrets |
| `web/.env` | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| `mobile/.env` | Same Supabase credentials for Flutter |

---

## Adding a New Language

1. Create `shared/i18n/<code>.json` with `{"_locale": "<code>", "_name": "<Native Name>"}`
2. Add translation keys matching the existing locale files
3. Register the locale in both `web` and `mobile` i18n config
4. No code changes required — the apps discover locales dynamically

---

## License

Private — all rights reserved. This software is proprietary to the client organization.

---

*Built by [Adeel Jabbar](https://github.com/adeeljabbar) — solo freelance developer*
