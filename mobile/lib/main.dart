import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'bootstrap.dart';
import 'app.dart';
import 'core/config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await bootstrap();

  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.tracesSampleRate = 1.0;
      options.beforeBreadcrumb = (breadcrumb, hint) {
        if (breadcrumb == null) return null;
        final message = breadcrumb.message?.toLowerCase() ?? '';
        final dataStr = breadcrumb.data?.toString().toLowerCase() ?? '';
        if (message.contains('password') || message.contains('gps') || message.contains('lat') || message.contains('lng') || message.contains('path') || message.contains('form') ||
            dataStr.contains('gps') || dataStr.contains('lat') || dataStr.contains('lng')) {
          return null; // Drop sensitive breadcrumb
        }
        return breadcrumb;
      };
      options.beforeSend = (event, hint) {
        final Map<String, dynamic> scrubbedContexts = Map.from(event.contexts.toJson());
        scrubbedContexts.removeWhere((key, value) => key.toLowerCase().contains('gps') || key.toLowerCase().contains('location') || key.toLowerCase().contains('form') || key.toLowerCase().contains('path'));
        
        return event.copyWith(
          request: event.request?.copyWith(data: '[Scrubbed Form Payload]'),
          contexts: SentryContexts.fromJson(scrubbedContexts),
        );
      };
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: App(),
      ),
    ),
  );
}
