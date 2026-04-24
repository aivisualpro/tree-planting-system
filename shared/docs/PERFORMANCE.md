# Performance Budget

> **Owner**: Engineering Lead  
> **Review cadence**: Weekly (Monday 09:00 UTC – automated Slack reminder)  
> **CI enforcement**: Budgets below are hard-gated in `.github/workflows/perf-budget.yml`  
> **Last updated**: 2026-04-24

---

## Quick Reference – Budget Table

| Metric | Target | Enforcement |
|---|---|---|
| Flutter cold start (Pixel 4a) | **< 2 s** | Firebase Performance trace `app_cold_start` |
| Flutter list scroll (100 rows) | **60 fps** | Flutter DevTools Performance tab |
| APK size per ABI | **< 30 MB** | CI `perf-budget.yml` hard-fails |
| In-memory image cache | **≤ 50 MB** | `ImageCacheManager.configure()` |
| Dashboard API p95 | **< 500 ms** | Axiom latency heatmap |
| Visits list API p95 | **< 300 ms** | Axiom latency heatmap |
| Sync pull (500 rows) p95 | **< 60 s** | Mobile Sentry traces |
| Full initial sync (500V + 2000P) | **< 10 min on 4G / < 45 min on 2G** | Integration benchmark |
| Lighthouse Performance | **≥ 90** | LHCI hard-fails on PR |
| LCP (Fast 3G) | **< 2.5 s** | LHCI hard-fails |
| CLS | **< 0.1** | LHCI hard-fails |
| TTI | **< 3 s** | LHCI hard-fails |
| Initial JS (gzipped) | **< 200 KB** | CI `perf-budget.yml` |
| `index.html` (gzipped) | **< 50 KB** | CI `perf-budget.yml` |

---

## Section A – Flutter Mobile Performance

### A1 · App Startup (§1)

**Target**: Cold start < 2 s on Pixel 4a (profile mode).

#### Two-Phase Initialisation

| Phase | What runs | Timing |
|---|---|---|
| **CRITICAL** | Supabase auth state restore (SecureStorage), Drift DB warm-up | Before first frame |
| **DEFERRED** | Firebase/FCM init, FMTC tile cache, certificate pinning, WorkManager registration | `addPostFrameCallback` – user already sees UI |

All deferred tasks run in `Future.wait([...])` so they parallelise.

#### Measurement

```bash
# Profile cold start
flutter run --profile --trace-startup
flutter drive --profile --driver=test_driver/perf_driver.dart --target=integration_test/startup_test.dart

# Firebase Performance: automatic trace 'app_cold_start'
# Check in Firebase Console → Performance → Traces
```

#### Sentry Trace

```dart
final span = Sentry.startTransaction('app.cold_start', 'ui.load');
// ... after home screen renders:
await span.finish(status: const SpanStatus.ok());
```

---

### A2 · List Rendering (§2)

**Target**: 60 fps on a 100-row visits list on low-end device.

#### Guidelines

- Use **`ListView.builder`** with `itemExtent` for fixed-height rows (avoids layout recalculation).
- Use **`sliver_tools`** (`MultiSliver`, `SliverStack`) for complex nested scroll views.
- Keep `build()` methods pure and free of heavy computation.
- Extract heavy widgets into `const` constructors wherever possible.

```dart
ListView.builder(
  itemCount: visits.length,
  itemExtent: 88.0,   // fixed row height – unlocks fast scroll path
  itemBuilder: (context, i) => VisitListTile(visit: visits[i]),
)
```

#### Measurement

```
Flutter DevTools → Performance → Record → scroll → stop
Target: 0 jank frames (frame time < 16.7 ms at 60 fps)
```

---

### A3 · Image Performance (§3)

**Target**: Thumbnails on list (≤ 300 px), full-res on detail. No UI jank from image decoding.

| Context | Provider | Size |
|---|---|---|
| Visit list thumbnail | `ImageCacheManager.thumbnail(url, maxWidth: 300)` | 300 px WebP |
| Visit detail full image | `ImageCacheManager.full(url)` | original |
| Local files (not yet uploaded) | `FileImage(File(path))` | original |

Thumbnail URL is auto-generated via **Supabase Storage image transformations** (`/render/image/public/...?width=300&format=webp&quality=80`).

For large local images, decode on a background isolate:

```dart
final bytes = await File(path).readAsBytes();
final codec  = await ui.instantiateImageCodec(bytes, targetWidth: 300);
final frame  = await codec.getNextFrame();
final image  = frame.image;
```

---

### A4 · Battery (§4)

| Concern | Approach |
|---|---|
| WorkManager constraints | `requiresBatteryNotLow: true`, `requiresCharging: false` |
| Foreground service | Android: only during active sync. Stopped when sync completes. |
| GPS accuracy | `LocationAccuracy.medium` by default; `LocationAccuracy.high` only if user explicitly enables it |
| WakeLocks | Disabled. Sync runs via WorkManager constraints – no manual wakelock. |

---

### A5 · APK / IPA Size (§5)

**Target**: < 30 MB download per ABI on Play Store.

```bash
# Split per ABI (ARM64, ARM32, x86_64) – ~15 MB each
flutter build apk --release --split-per-abi

# App Bundle for Play Store (dynamic delivery)
flutter build appbundle --release

# Analyse size
flutter build apk --analyze-size --target-platform android-arm64
```

#### ProGuard / R8 Rules

```
# keep.pro – do NOT strip:
-keep class io.supabase.**  { *; }
-keep class com.tekartik.sqflite.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
```

#### Asset Compression

PNG assets compressed with `pngquant` in CI pre-build step:

```bash
find assets -name "*.png" -exec pngquant --force --quality=65-80 --ext .png {} \;
```

#### Unused Asset Audit

Run before each release:

```bash
dart run remove_from_pubspec  # or manual review
flutter pub deps | grep -v sdk
```

---

### A6 · Memory (§6)

**Target**: < 50 MB image cache; app must not be killed on 2 GB RAM Android with 10 concurrent photos open.

```dart
// In bootstrapCritical() or deferred phase:
ImageCacheManager.configure(); // sets 50 MB cap

// In memory-pressure scenarios:
ImageCacheManager.evictAll();
```

**Dispose audit**: All `AnimationController`, `ScrollController`, `TextEditingController`, `StreamSubscription` must be disposed in `dispose()`. Enforced by `flutter_lints` + `avoid_leaking_state` custom lint rule.

---

## Section B – Nuxt Web Performance

### B7 · Bundle Size (§7)

**Target**: `index.html` gzipped < 50 KB, initial JS < 200 KB gzipped.

#### Chunk Splitting (nuxt.config.ts)

| Chunk | Contents | Strategy |
|---|---|---|
| `echarts` | echarts + zrender | Async – lazy-loaded via `LazyEChart.vue` |
| `supabase` | @supabase/* | Separate vendor chunk |
| `date-fns` | date-fns | Separate vendor chunk |
| `zod` | zod | Separate vendor chunk |

#### ECharts Lazy Loading

```vue
<!-- Always use the lazy component: -->
<LazyChartsLazyEChart :option="chartOption" height="400px" />
```

#### Lodash Tree-Shaking

```ts
// ✅ import specific functions
import debounce from 'lodash-es/debounce'
import groupBy from 'lodash-es/groupBy'

// ❌ never import the whole library
import _ from 'lodash'
```

#### Analysis

```bash
cd web
pnpm add -D @nuxt/analyze
pnpm exec nuxt analyze  # opens bundle visualiser in browser
```

---

### B8 · Images (§8)

**Setup**: `@nuxt/image` with custom `supabase` provider at `~/providers/supabase-image.ts`.

```vue
<!-- Responsive srcset + WebP + lazy -->
<NuxtImg
  provider="supabase"
  src="visit-media/path/to/image.jpg"
  :width="300"
  format="webp"
  loading="lazy"
  sizes="sm:100vw md:50vw lg:300px"
/>
```

Supabase Storage transformations used: `?width=300&format=webp&quality=80`.

---

### B9 · Data Fetching (§9)

| Pattern | When |
|---|---|
| `useAsyncData({ server: true })` | First page load (SSR hydration) |
| `useVisitFilters` composable | Filter-heavy pages (debounced 300 ms) |
| Module-level cache (30 s staleTime) | Avoid redundant API calls on navigation |

```ts
// In a page component:
const { filters, data, pending, setFilter } = useVisitFilters({ status: 'completed' })
```

---

### B10 · Lighthouse Targets (§10) – CI Enforced

| Metric | Target | Tool |
|---|---|---|
| Performance score | ≥ 90 | LHCI hard-fails |
| LCP | < 2.5 s | LHCI hard-fails |
| CLS | < 0.1 | LHCI hard-fails |
| TTI | < 3 s | LHCI hard-fails |

Config: `web/.lighthouserc.json`

```bash
# Run locally
npx @lhci/cli autorun
```

---

### B11 · Vercel Optimization (§11)

| Setting | Value | Reason |
|---|---|---|
| Regions | `iad1`, `cdg1`, `sin1` | Primary US + Europe + SE Asia / Africa edge |
| `/dashboard` ISR | `revalidate: 60` | Fresh KPIs every 60 s, CDN-cached between |
| `/visits` ISR | `revalidate: 30` | Near-realtime list |
| `/_nuxt/**` cache | `immutable, 1 year` | Content-hashed assets |
| Auth redirect | Edge middleware | Zero cold start, cookie check only |
| Dashboard KPIs fn | 1024 MB | Aggregation-heavy |
| Exports / Reports fn | 1024 MB, 60 s timeout | Puppeteer + ExcelJS |

---

## Section C – Database Performance

### C12 · Indexes & EXPLAIN ANALYZE (§12)

All dashboards and visits queries must show **Index Scan** – no `Seq Scan` over > 1 000 rows.

Key indexes (migration `20260424200000_performance.sql`):

| Index | Table | Covers |
|---|---|---|
| `idx_visits_country_status_date` | `visits` | Dashboard + list filter |
| `idx_visits_updated_at_id` | `visits` | Sync cursor pagination |
| `idx_visit_trees_visit_species` | `visit_trees` | Aggregation join |
| `idx_visit_media_sync_status` | `visit_media` | Pending upload query |
| `idx_profiles_country_role` | `profiles` | RLS helper |
| `idx_notification_events_user_read` | `notification_events` | Unread feed |

Materialized views refreshed every 5 min via `pg_cron`:
- `mv_country_kpis`
- `mv_top_species`
- `mv_user_activity`

**Verify** (run in Supabase SQL editor):

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
  SELECT get_dashboard_kpis(NULL);

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
  SELECT * FROM get_visits_page(NULL, NULL, 25, 0);
```

---

### C13 · Connection Pooling (§13)

| Mode | Use case |
|---|---|
| **Supavisor – transaction mode** | `server/api` routes – short-lived connections |
| **Supavisor – session mode** | Mobile Realtime subscriptions – needs persistent connection |

Set `SUPABASE_DB_URL` in Vercel to the **Supavisor pooler URL** (port 6543), not direct port 5432.

---

### C14 · Query Budget (§14)

| Query | p95 Target |
|---|---|
| Dashboard KPIs (`get_dashboard_kpis`) | < 500 ms |
| Visits list page 1 (`get_visits_page`) | < 300 ms |
| Sync pull 500 rows (`pull_visits_since`) | < 1 s |

Monitor in **Axiom** → API latency heatmap dashboard (§18).

---

### C15 · Slow Query Log (§15)

Enable on Supabase Pro:

```sql
-- In postgresql.conf (Supabase dashboard → Database → Custom Config):
log_min_duration_statement = 1000  -- log queries > 1 s
```

**Weekly review**: Check Supabase Logs → Postgres Logs → filter `duration` > 1000 ms. Add indexes or rewrite as needed. Document in this file.

---

## Section D – Sync Engine Performance

### D16 · Benchmark (§16)

| Scenario | Target |
|---|---|
| 500 visits + 2 000 photos from scratch | < 10 min on good 4G |
| Same on 2G | < 45 min (must still complete) |

Run benchmark:

```bash
# Flutter integration test (profile mode)
flutter drive --profile \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/sync_benchmark_test.dart
```

---

### D17 · Sync Optimizations (§17)

| Optimization | Implementation |
|---|---|
| Batch upserts (100 rows/request) | `DeltaPuller._batchSize = 100` |
| Parallel media uploads (4 concurrent) | `MediaUploader._concurrency = 4` |
| gzip payloads > 10 KB | `DeltaPuller.compressIfLarge()` |
| Cursor-based pagination | `pull_visits_since(since, limit_)` RPC |

---

## Section E – Observability

### E18 · OpenTelemetry → Axiom (§18)

All `server/api/**` routes automatically traced via `server/plugins/otel-tracing.ts`.

Required env vars:

```bash
AXIOM_API_KEY=xait-...
AXIOM_DATASET=tree-planting-prod
```

**Dashboards to build in Axiom**:
- API latency heatmap (p50 / p95 / p99 by route)
- Error rate by route
- Slowest 10 queries (correlate with Supabase logs)

---

### E19 · Flutter Traces (§19)

Key flows instrumented with Sentry transactions:

| Flow | Transaction name |
|---|---|
| Cold start | `app.cold_start` |
| Visit create | `visit.create` |
| Sync run | `sync.runSync` (sub-spans: `sync.outbox`, `sync.media`, `sync.delta_pull`) |

```dart
// Example: visit create flow
final span = Sentry.startTransaction('visit.create', 'db.write');
// ... form submit ...
await span.finish(status: const SpanStatus.ok());
```

---

### E20 · Dashboards & Review (§20)

**Axiom / Grafana dashboards required**:

| Dashboard | Metrics |
|---|---|
| Sync Health | Mobile sync success rate, failure rate by error type |
| Sync Duration | p50 / p95 / p99 per day, segmented by network type |
| API Latency Heatmap | All `/api/**` routes, binned by response time |
| DB Query Budget | Query duration against budget targets |

**Weekly review checklist** (auto-reminded via GitHub Actions `schedule`):

- [ ] Review Lighthouse scores for `/dashboard` and `/visits` – any regressions?
- [ ] Check Axiom API latency heatmap – any route breaching its p95 budget?
- [ ] Review Supabase slow query log (> 1 s) – add indexes if needed
- [ ] Check mobile sync success rate – target > 99%
- [ ] Review APK size on last release – still < 30 MB per ABI?
- [ ] Update this file if any target is changed

---

## Regression Policy

A performance regression is defined as:

1. **CI hard-fail** (PR blocked): Lighthouse < 90, LCP > 2.5 s, CLS > 0.1, TTI > 3 s, JS > 200 KB, APK > 30 MB.
2. **Soft warning** (PR comment): Any metric within 10% of its budget.
3. **Weekly review finding**: A budget breach discovered in weekly review must be fixed within **2 sprints** and documented here with root cause + fix.

---

## Historical Performance Log

| Date | Metric | Measured | Budget | Status | Notes |
|---|---|---|---|---|---|
| 2026-04-24 | — | Budgets established | — | Baseline | Initial PERFORMANCE.md |

---

*See also: [ARCHITECTURE.md](./ARCHITECTURE.md) · [SYNC.md](./SYNC.md) · [TESTING.md](./TESTING.md) · [DEPLOYMENT.md](./DEPLOYMENT.md)*
