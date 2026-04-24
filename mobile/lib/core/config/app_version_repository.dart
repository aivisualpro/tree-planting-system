import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Represents the version status
enum VersionStatus {
  ok,
  updateAvailable,
  updateRequired,
}

class AppVersionState {
  final VersionStatus status;
  final String? releaseNotes;
  final String currentVersion;
  final String latestVersion;

  AppVersionState({
    this.status = VersionStatus.ok,
    this.releaseNotes,
    this.currentVersion = '',
    this.latestVersion = '',
  });
}

final appVersionProvider = StateNotifierProvider<AppVersionNotifier, AppVersionState>((ref) {
  return AppVersionNotifier(Supabase.instance.client);
});

class AppVersionNotifier extends StateNotifier<AppVersionState> {
  final SupabaseClient _client;

  AppVersionNotifier(this._client) : super(AppVersionState());

  Future<void> checkVersion() async {
    try {
      final String platform = Platform.isIOS ? 'ios' : 'android';
      final response = await _client.rpc('get_app_version_info', params: {'p_platform': platform});
      
      if (response == null) return;
      
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final minSupported = response['min_supported_version'] as String;
      final latest = response['latest_version'] as String;
      final releaseNotesObj = response['release_notes'] as Map<String, dynamic>?;
      
      // Get localization or default
      final releaseNotesStr = releaseNotesObj?['en'] as String? ?? 'A new version is available.';

      // Version comparison logic
      final isBelowMin = _compareVersions(currentVersion, minSupported) < 0;
      final isBelowLatest = _compareVersions(currentVersion, latest) < 0;

      if (isBelowMin) {
        state = AppVersionState(
          status: VersionStatus.updateRequired,
          releaseNotes: releaseNotesStr,
          currentVersion: currentVersion,
          latestVersion: latest,
        );
      } else if (isBelowLatest) {
        state = AppVersionState(
          status: VersionStatus.updateAvailable,
          releaseNotes: releaseNotesStr,
          currentVersion: currentVersion,
          latestVersion: latest,
        );
      } else {
        state = AppVersionState(
          status: VersionStatus.ok,
          currentVersion: currentVersion,
          latestVersion: latest,
        );
      }
    } catch (e) {
      print('Failed to check app version: $e');
    }
  }

  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < v1Parts.length ? v1Parts[i] : 0;
      final p2 = i < v2Parts.length ? v2Parts[i] : 0;
      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0;
  }
}

class VersionOverlay extends ConsumerWidget {
  final Widget child;

  const VersionOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionState = ref.watch(appVersionProvider);

    if (versionState.status == VersionStatus.updateRequired) {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.system_update, size: 64, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  'Update Required',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your current version (${versionState.currentVersion}) is no longer supported. Please update to continue using the app.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (versionState.releaseNotes != null)
                  Text(
                    'What\\'s new:\\n${versionState.releaseNotes}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _openStore,
                  child: const Text('Update Now'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (versionState.status == VersionStatus.updateAvailable) {
      // Show soft prompt overlay or just allow child with a banner.
      // For simplicity, we just return child, and typically we'd show a Snackbar
      // or a dismissible banner here. Let's wrap child in a banner if we want.
    }

    return child;
  }

  void _openStore() async {
    final url = Platform.isIOS 
      ? 'https://apps.apple.com/app/idYOUR_APP_ID' 
      : 'https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
