import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'bootstrap.dart';
import 'app.dart';
import 'core/config/env.dart';

/// Two-phase startup:
///  Phase 1 (CRITICAL): run before first frame – blocks the splash
///  Phase 2 (DEFERRED): runs after first frame in background
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Phase 1: CRITICAL init (Drift + Supabase auth) ──────────────────────
  await bootstrapCritical();

  // ── Sentry shell – minimal until deferred phase completes ───────────────
  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      // Low sample rate at cold-start; will be raised in deferred phase
      options.tracesSampleRate = 0.1;
      options.profilesSampleRate = 0.1;
      options.beforeBreadcrumb = (breadcrumb, hint) {
        if (breadcrumb == null) return null;
        final message = breadcrumb.message?.toLowerCase() ?? '';
        final dataStr = breadcrumb.data?.toString().toLowerCase() ?? '';
        const sensitive = ['password', 'gps', 'lat', 'lng', 'path', 'form'];
        if (sensitive.any((s) => message.contains(s) || dataStr.contains(s))) {
          return null;
        }
        return breadcrumb;
      };
      options.beforeSend = (event, hint) {
        return event.copyWith(
          request: event.request?.copyWith(data: '[Scrubbed]'),
        );
      };
    },
    appRunner: () => runApp(
      const ProviderScope(child: App()),
    ),
  );
}
