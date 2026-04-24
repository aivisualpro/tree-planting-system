import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'core/config/env.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/sync/sync_provider.dart';

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
    return Future.value(true);
  });
}

Future<void> bootstrap() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: const SecureLocalStorage(),
    ),
  );

  if (!kIsWeb) {
    try {
      await HttpCertificatePinning.check(
        serverURL: Env.supabaseUrl,
        headerHttp: {},
        sha: SHA.SHA256,
        allowedSHAFingerprints: ['INTERMEDIATE_CERT_SHA256_FINGERPRINT_HERE'],
        timeout: 50,
      );
    } catch (e) {
      // Pinning failed
      debugPrint('Certificate Pinning Failed: $e');
    }
  }

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

class SecureLocalStorage extends LocalStorage {
  const SecureLocalStorage();
  static const _storage = FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> getItem({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> removeItem({required String key}) async {
    await _storage.delete(key: key);
  }
}
