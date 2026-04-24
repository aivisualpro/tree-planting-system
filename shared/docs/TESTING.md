# Comprehensive Testing Strategy

## Overview
This document outlines the testing strategy across the web, mobile, and backend platforms for the Tree-Planting System. Our goal is a green CI pipeline that blocks every merge, ensuring a manual test session before release takes under 2 hours.

## Coverage Targets & CI Gates
- **Backend pgTAP**: 100% of tables have RLS tests, 100% of RPCs have function tests.
- **Web Vitest**: 70% line coverage, 90% on composables/stores/utils.
- **Flutter**: 80% line coverage, 100% on core/sync.

CI Pipeline:
- **On PR**: unit + component + pgTAP + lighthouse + a11y + integration (fast path ~12 min).
- **On Merge to Main**: All above + E2E + mobile integration on Firebase Test Lab (full ~25 min).
- **Nightly**: k6 load + chaos + visual regression + cross-device Flutter.

## Section A: Backend (Supabase)
Tests are located in `supabase/tests/`.
1. **pgTAP Test Coverage Audit**: Every table has RLS tests for every role + every operation.
2. **RPC Function Tests**: Tests for every function covering happy path, auth failures, and edge inputs.
3. **Migration Reversibility Test**: Ensure `supabase db reset` matches schema.
4. **Seed Data Integrity Test**: Asserts FK resolutions and no orphan rows after `seed.sql`.

## Section B: Nuxt Web Tests
Tests are located in `web/test/` and `web/tests/e2e/`.
1. **Unit Tests (Vitest)**: Composables, utils (100% coverage), Pinia stores.
2. **Component Tests (@vue/test-utils + Vitest)**: Forms, DataTables, ResourceTables.
3. **E2E Tests (Playwright)**: `login`, `dashboard`, `visits-crud`, `masters-crud`, `translations`, `rbac`.
4. **Visual Regression**: Playwright screenshot compares on dashboard/visits/charts.
5. **Accessibility**: `@axe-core/playwright` for zero violations (AA level).
6. **Lighthouse CI**: Performance ≥ 90, accessibility ≥ 95, best-practices ≥ 95, SEO ≥ 90.

## Section C: Flutter Mobile Tests
Tests are located in `mobile/test/`, `mobile/integration_test/`, and `mobile/benchmark/`.
1. **Unit Tests**: Repositories, Riverpod providers, Sync engine (100% branch), formatters.
2. **Widget Tests**: Screen states, Golden tests, form autosave.
3. **Integration Tests (Patrol)**: Login flow, offline visit creation, sync reconnect, conflict resolution, media upload, etc.
4. **Native Interactions**: Permission flows.
5. **Benchmarks**: App cold start, jank metrics, sync performance on throttled networks.

## Section D: Contract Tests
1. Generate types from staging Supabase nightly.
2. Dart types generated to match `database.ts`.
3. Contract tests for RPC functions returning shape assertions.

## Section E: Load & Chaos Tests
Located in `shared/scripts/perf/` and `shared/scripts/chaos/`.
1. **k6 Scripts**: Dashboard reads, sync pushing, storage uploads.
2. **Chaos Tests**: Kill connections, throttle network, corrupt local SQLite, delete media.
