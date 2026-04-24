# Mobile Module Documentation

This document explains the responsibilities of the core modules within the Flutter `mobile/` directory.

## Core (`mobile/lib/core/`)
Contains application-wide infrastructure that is agnostic to specific business features.
- `database/`: Drift SQLite setup, schema definitions, and migration logic. Acts as the single source of truth for the UI.
- `network/`: Dio/Supabase client wrappers and connectivity monitoring logic.
- `sync/`: The background synchronization engine. Manages the Outbox, retry logic, exponential backoff, and WorkManager integrations.
- `theme/`: Global Material 3 design tokens, colors, and text styles.
- `utils/`: Error handling, logging (Sentry integrations), and shared helpers.

## Features (`mobile/lib/features/`)
Contains business logic grouped by feature domain. Each feature typically follows a clean architecture structure.
- `auth/`: Login flows, session management, and secure token storage.
- `visits/`: Core planting visit form, list view, and detail view. Handles complex state like photos and GPS.
- `metadata/`: Handling of synced master data (countries, species, activity types) used to populate dropdowns offline.

## Router (`mobile/lib/router/`)
- `router.dart`: GoRouter configuration. Defines route paths, deep linking, and authentication guards (redirecting unauthenticated users to login).

## Localization (`mobile/lib/l10n/` or `mobile/l10n/`)
- Contains ARB files for static app-shell strings (English, French, Swahili). Used by the `flutter_localizations` package.
