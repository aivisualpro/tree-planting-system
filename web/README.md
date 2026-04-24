# Web Module Documentation

This document explains the responsibilities of the core modules within the Nuxt `web/` directory.

## App Directories (`web/app/`)
- `components/`: Vue components for the UI. Uses a feature-driven structure (e.g., `components/visits/`, `components/dashboard/`).
- `composables/`: Reusable Vue composables encapsulating business logic (e.g., `useAuth`, `useVisits`).
- `pages/`: File-based routing for the Nuxt application.
- `layouts/`: Application layouts (e.g., standard admin shell with sidebar).
- `stores/`: Pinia state management for global UI state and caching.
- `locales/`: Static UI string translations for Nuxt i18n.
- `middleware/`: Route guards enforcing role-based access control (`admin`, `super_admin`).
- `utils/`: Pure helper functions for formatting, validation, and math.

## Server Directories (`web/server/`)
- `api/`: Nitro API routes serving aggregated data (e.g., Dashboard KPIs) that are too complex for client-side direct PostgREST calls. These securely bypass RLS using the Supabase Service Role key but perform manual auth checks.
- `plugins/`: Server-side Nitro plugins (e.g., rate limiting).
- `utils/`: Server-only helper functions (e.g., DB connections, secure token generation).

## Shared (`web/shared/`)
- Shared types and constants utilized both by the `app/` and `server/` environments.
