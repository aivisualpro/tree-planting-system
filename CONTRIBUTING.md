# Contributing Guide

This document defines the development workflow, conventions, and quality standards for the Tree-Planting Field Operations System.

---

## Schema-First Workflow

**The database schema is the single source of truth.** Every data model change follows this strict sequence:

```
1. Write SQL migration  →  2. Apply & test locally  →  3. Regenerate types  →  4. Update app code
```

### Step-by-Step

1. **Create a migration file**
   ```bash
   cd supabase
   supabase migration new <descriptive_name>
   # e.g., supabase migration new add_planting_sites_table
   ```
   This generates a timestamped file in `supabase/migrations/`.

2. **Write your SQL** in the new migration file. Include:
   - Table/column changes
   - Row Level Security (RLS) policies
   - Indexes for query patterns you know will exist
   - Comments on columns for documentation

3. **Apply and verify locally**
   ```bash
   supabase db reset   # full reset: drop → migrate → seed
   ```

4. **Regenerate TypeScript types**
   ```bash
   supabase gen types typescript --local > ../shared/types/database.ts
   ```

5. **Update application code** in `web/` and/or `mobile/` to use the new types and schema.

6. **Commit the migration, generated types, and app changes together** in a single PR.

> ⚠️ **Never** modify a migration that has already been applied to staging or production. Always create a new migration to alter existing tables.

---

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/) to keep history readable and enable automated changelogs.

### Format

```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

### Types

| Type | When to Use |
|------|------------|
| `feat` | A new feature or capability |
| `fix` | A bug fix |
| `chore` | Maintenance (deps, configs, CI) |
| `docs` | Documentation only |
| `refactor` | Code restructuring without behavior change |
| `test` | Adding or updating tests |
| `perf` | Performance improvement |
| `style` | Formatting, whitespace (no logic change) |

### Scopes

Use the top-level folder as scope: `web`, `mobile`, `supabase`, `shared`, `ci`.

### Examples

```
feat(supabase): add planting_sites table with RLS policies
fix(mobile): resolve offline sync conflict on planting records
chore(web): bump Nuxt to 4.2.1
docs(shared): add sync architecture diagram
refactor(supabase): extract common RLS helper into shared function
test(supabase): add pgTAP tests for planting_records policies
```

---

## Branch Strategy

```
main ─────────────────────────────────── production (always deployable)
  │
  ├── feat/add-planting-sites ────────── feature branch
  ├── fix/offline-sync-conflict ──────── bugfix branch
  └── chore/update-deps ─────────────── maintenance branch
```

### Rules

- **`main`** is the production branch. It must always be in a deployable state.
- **Feature branches** are created from `main` and merged back via Pull Request.
- Branch naming: `<type>/<short-kebab-description>` (e.g., `feat/photo-upload`, `fix/login-redirect`).
- **Rebase** feature branches onto `main` before merging to keep a linear history.
- **Delete** feature branches after merge.

---

## Code Review Checklist

Every PR must pass this checklist before merge. The author checks these before requesting review; the reviewer verifies.

### Database (supabase/)

- [ ] Migration file is idempotent where possible (use `IF NOT EXISTS`)
- [ ] RLS policies are defined for every new table
- [ ] RLS policies follow the principle of least privilege
- [ ] Indexes exist for columns used in `WHERE`, `JOIN`, and `ORDER BY`
- [ ] Column comments document the purpose and constraints
- [ ] `seed.sql` is updated if the migration adds required reference data
- [ ] pgTAP tests cover the new/changed policies

### Mobile (mobile/)

- [ ] Works fully offline — no network calls in the critical path
- [ ] Sync logic handles conflicts (last-write-wins or merge strategy documented)
- [ ] New strings are added to `shared/i18n/en.json` (source locale)
- [ ] No hardcoded strings in UI — all text goes through the i18n system
- [ ] Tested on both Android and iOS (or documented as platform-specific)
- [ ] GPS/camera permissions are requested gracefully with fallback

### Web (web/)

- [ ] Pages are server-side rendered where appropriate
- [ ] No sensitive keys in client-side code
- [ ] New strings use the i18n system
- [ ] Responsive design verified at mobile, tablet, and desktop breakpoints
- [ ] Loading and error states are handled for every async operation

### General

- [ ] TypeScript types are regenerated if schema changed
- [ ] No `.env` values committed
- [ ] No `console.log` / `print()` debugging left in code
- [ ] Commit messages follow Conventional Commits format
- [ ] PR description explains **what** and **why**, not just **how**

---

## i18n Workflow

1. **Source of truth**: `shared/i18n/en.json` — all new keys go here first.
2. **Other locales**: Add the same keys to every locale file in `shared/i18n/`.
3. **Missing keys**: The app falls back to `en.json` if a key is missing in the active locale.
4. **Key naming**: Use dot-separated namespaces: `planting.form.title`, `auth.login.button`.
5. **No code changes needed** to add a new language — just add the JSON file and register the locale code.

---

## Edge Function Guidelines

- Edge Functions live in `supabase/functions/<function-name>/index.ts`.
- Each function gets its own directory.
- Use Deno; do not use Node.js APIs.
- Always validate input with a schema (e.g., Zod).
- Return proper HTTP status codes and JSON error bodies.
- Secrets go in `.env` (never hardcoded).

---

## Testing

| Layer | Framework | Location |
|-------|----------|----------|
| Database | pgTAP | `supabase/tests/` |
| Edge Functions | Deno test | `supabase/functions/*/tests/` |
| Web | Vitest + Vue Test Utils | `web/tests/` |
| Mobile | Flutter test | `mobile/test/` |

Run database tests:
```bash
cd supabase
supabase test db
```

---

## Questions?

Open an issue or reach out to the project maintainer.
