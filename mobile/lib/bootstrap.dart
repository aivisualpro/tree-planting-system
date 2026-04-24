import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http_certificate_pinning/http_certificate_pinning.dart';
// import 'package:firebase_core/firebase_core.dart'; // Disabled: incompatible with Xcode 26
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'core/config/env.dart';
// import 'core/notifications/notification_service.dart'; // Disabled: requires Firebase
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/sync/sync_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WorkManager callback – runs in a separate isolate
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: const SecureLocalStorage(),
      ),
    );
    final container = ProviderContainer();
    final syncEngine = container.read(syncEngineProvider);
    await syncEngine.runSync();
    container.dispose();
    return true;
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 1 – CRITICAL (blocks first frame)
// Target: complete in < 400 ms so total cold-start stays < 2 s on Pixel 4a
// ─────────────────────────────────────────────────────────────────────────────
Future<void> bootstrapCritical() async {
  // 1. Supabase init (auth state restore from SecureStorage)
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: const SecureLocalStorage(),
    ),
  );

  // 2. Drift database open (critical – home screen needs local data)
  //    AppDatabase is a singleton; accessing it here ensures WAL checkpoint
  //    is done before the first query from UI.
  //    (Database is lazily initialised via Riverpod; touching the provider
  //     here warms it up.)

  // 3. Schedule deferred work AFTER first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _bootstrapDeferred();
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 2 – DEFERRED (runs after first frame – user already sees UI)
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _bootstrapDeferred() async {
  // Run deferred tasks in parallel to save time
  await Future.wait([
    // _initFirebase(), // Disabled: Firebase incompatible with Xcode 26
    _initOfflineMaps(),
    // _initCertPinning(),
    _registerWorkManager(),
  ]);
}

Future<void> _initFirebase() async {
  // Firebase disabled — incompatible with Xcode 26
  // Re-enable when upgrading to firebase_core ^3.x
  debugPrint('Firebase init skipped (disabled)');
}

Future<void> _initOfflineMaps() async {
  if (kIsWeb) return;
  try {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore('offline_maps').manage.create();
  } catch (e) {
    debugPrint('FMTC init failure: $e');
  }
}

/*
Future<void> _initCertPinning() async {
  if (kIsWeb) return;
  try {
    await HttpCertificatePinning.check(
      serverURL: Env.supabaseUrl,
      headerHttp: {},
      sha: SHA.SHA256,
      allowedSHAFingerprints: [Env.certFingerprint],
      timeout: 50,
    );
  } catch (e) {
    debugPrint('Certificate pinning failed: $e');
  }
}
*/

Future<void> _registerWorkManager() async {
  if (kIsWeb) return;
  try {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // §4 battery constraints: not while charging required, but battery must not be low
    await Workmanager().registerPeriodicTask(
      'sync-task',
      'syncTask',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true, // §4 – preserve battery on low-end devices
        requiresCharging: false,     // §4 – don't require charger
      ),
    );
  } catch (e) {
    debugPrint('WorkManager registration failure: $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SecureLocalStorage – Supabase auth token persistence
// ─────────────────────────────────────────────────────────────────────────────
class SecureLocalStorage extends LocalStorage {
  const SecureLocalStorage();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _sessionKey = 'supabase_session';

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> getItem({required String key}) =>
      _storage.read(key: key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> removeItem({required String key}) =>
      _storage.delete(key: key);

  @override
  Future<bool> hasAccessToken() async {
    final token = await _storage.read(key: _sessionKey);
    return token != null;
  }

  @override
  Future<String?> accessToken() async {
    return _storage.read(key: _sessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(key: _sessionKey, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: _sessionKey);
  }
}
