import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'core/config/env.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/sync/sync_provider.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    
    final container = ProviderContainer();
    final syncEngine = container.read(syncEngineProvider);
    await syncEngine.runSync();
    container.dispose();
    return Future.value(true);
  });
}

Future<void> bootstrap() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  if (!kIsWeb) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    
    await Workmanager().registerPeriodicTask(
      'sync-task',
      'syncTask',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
