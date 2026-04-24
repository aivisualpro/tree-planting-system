# Notifications Architecture

This document describes the multi-channel notification system (Push, Email, WhatsApp) for the Tree Planting System.

## Architecture Overview

Notifications are managed primarily through the Supabase backend to ensure reliability and unified preference handling.

1.  **Database Layer**:
    *   `notification_events`: The central queue for all outgoing notifications.
    *   `notification_preferences`: Stores user preferences (channels enabled, quiet hours, timezone).
    *   `device_tokens`: Stores Firebase Cloud Messaging (FCM) tokens for devices.
2.  **Dispatch Mechanism**:
    *   Database triggers (e.g., `on_visit_status_changed_notification`) automatically enqueue events into `notification_events` based on domain events.
    *   A Supabase Edge Function (`dispatch-notifications`) is triggered by Database Webhooks on `INSERT` to `notification_events`.
    *   The Edge Function reads user preferences, checks quiet hours, and fans out the notification to the appropriate channels (FCM, Resend, Meta Cloud API).
3.  **Client Layers**:
    *   **Flutter Mobile**: Handles push notifications via `firebase_messaging`. Registers tokens to `device_tokens` on login. Deep-links OS notifications to specific screens. Provides an in-app settings screen to update preferences.
    *   **Nuxt Web**: Provides an interface for configuring notification preferences (`/settings/notifications`). Offers an admin UI for broadcasting emergency messages (`/admin/broadcast`).

## Channels & Providers

### Push Notifications (FCM)
*   Used for instant alerts (e.g., visit assigned, visit approved).
*   Configured via Firebase Cloud Messaging (FCM).
*   Works for both iOS and Android.
*   **iOS APNs Setup**: To support iOS, you must configure APNs in the Apple Developer Console, generate a `.p8` key (with Push Notifications enabled), and upload it to the Firebase Console under **Project Settings > Cloud Messaging > Apple app configuration**. This unifies push delivery for iOS under FCM.

### Email (Resend)
*   Used for non-urgent communication, weekly summaries, and auth emails (welcome, password reset).
*   Sent via Resend REST API within the edge function.

### WhatsApp (Meta Cloud API)
*   Used for weekly summaries and emergency broadcasts.
*   Requires pre-approved message templates for business-initiated messaging.

## WhatsApp Template Registration & Review Process

To send business-initiated messages via WhatsApp, templates must be registered and approved via the Meta Business Manager.

### Required Templates
1.  **`visit_assigned`**
    *   Category: UTILITY
    *   Body: "A new visit has been assigned to you. Please check your Tree Planting App for details."
2.  **`weekly_summary`**
    *   Category: UTILITY
    *   Body: "Here is your weekly country summary for week {{1}}. Please review it in the portal."
3.  **`emergency_broadcast`**
    *   Category: MARKETING / UTILITY (Depending on content, typically UTILITY for alerts)
    *   Body: "Emergency Broadcast: {{1}}"

### Review Process
1.  Navigate to **Meta Business Manager > WhatsApp Manager > Message Templates**.
2.  Create a new template matching the names above.
3.  Submit for review.
4.  **Approval Time**: Template review typically takes 24–48 hours. Wait for approval before using the template in the `dispatch-notifications` Edge Function. Plain text or unapproved templates will result in failed delivery with a Meta API error.

## Notification Events Catalog

| Event Type | Triggered By | Default Channels | Description |
| :--- | :--- | :--- | :--- |
| `visit.assigned` | Application Logic | Push | Sent to field_user when assigned a visit. |
| `visit.submitted` | DB Trigger (`visits` UPDATE) | Push | Sent to the country coordinator when a visit is submitted. |
| `visit.approved` | DB Trigger (`visits` UPDATE) | Push | Sent to creator when a visit is approved. |
| `visit.rejected` | DB Trigger (`visits` UPDATE) | Push | Sent to creator when a visit is rejected. |
| `sync.failed_permanent` | Flutter App / Sync Engine | Push | Sent when background sync permanently fails. |
| `user.invited` | DB Trigger (`auth.users` INSERT) | Email | Welcome email with magic link. |
| `password.reset` | Application Logic | Email | Password reset request. |
| `weekly.country_summary` | pg_cron job | Email, WhatsApp | Weekly summary sent to admins. |
| `emergency.broadcast` | Admin Nuxt UI | Push, Email, WA | Triggered by super_admin via `/admin/broadcast`. |
