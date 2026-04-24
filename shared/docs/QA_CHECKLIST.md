# Manual QA Checklist

## Pre-Release Manual Test Session

Estimated execution time: < 2 hours.

### Role & Login Matrix
- [ ] Login as `admin`: Verify all dashboard panels, user management, and settings are accessible.
- [ ] Login as `coordinator`: Verify access to visits and assignments, but restricted from audit logs/user management.
- [ ] Login as `field_user`: Verify access restricted to assigned visits and offline creation.
- [ ] Attempt login with invalid credentials; verify appropriate error message.
- [ ] Attempt login with an expired session; verify redirect to login screen.

### Mobile Offline & Sync Ops
- [ ] **Offline Create**: Disconnect from network. Create a new visit including photos, signature, and GPS coordinates. Verify autosave locally.
- [ ] **Reconnect Sync**: Reconnect to network. Verify the created visit syncs to the server within 60 seconds without errors.
- [ ] **Force-Kill Recovery**: Start filling out a visit form, force-kill the app mid-submission. Reopen and verify data is retained via Drift autosave.
- [ ] **Concurrent Drafts**: Create 10+ draft visits offline. Reconnect and verify all sync successfully.
- [ ] **Low Battery Behavior**: Put device in battery saver mode; verify background sync is deferred.
- [ ] **Low Storage Behavior**: Test behavior on a device with < 500MB free storage. Verify app handles out-of-storage gracefully without crashing.
- [ ] **Clock Skew**: Set device time forward/backward by 1 hour. Verify sync and JWT validation still function or fail gracefully with clear messaging.

### Web UI & Functionality
- [ ] **Language Switch**: Toggle application language (e.g., English to Arabic). Verify UI changes correctly, including RTL support if applicable.
- [ ] **Dark Mode Toggle**: Toggle theme between Light and Dark mode. Verify all screens, especially tables and charts, render clearly.
- [ ] **CRUD Operations**: Complete full lifecycle (Create, Read, Update, Delete) for a Master entity (e.g., Country, Species).
- [ ] **Filters & Data Tables**: Apply multiple filters on the Visits list. Verify correct data is returned and pagination works.

### Final Verification
- [ ] No visual regressions noted during manual exploration.
- [ ] No unhandled exceptions in the client-side console or mobile crash reporting (Sentry).
