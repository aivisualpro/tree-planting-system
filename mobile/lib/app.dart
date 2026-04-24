import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';

import 'core/sync/sync_provider.dart';
import 'features/settings/training_mode_provider.dart';
import 'core/config/feature_flags_repository.dart';
import 'features/profile/profile_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(appRouterProvider);
      ref.read(notificationServiceProvider).setupInteractedMessage(router);
      ref.read(appVersionProvider.notifier).checkVersion();
      ref.read(featureFlagsProvider.notifier).refreshFlags();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncEngineProvider).runSync();
      ref.read(appVersionProvider.notifier).checkVersion();
      ref.read(featureFlagsProvider.notifier).refreshFlags();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final isTrainingMode = ref.watch(trainingModeProvider);
    // Placeholder until l10n is generated
    // final locale = ref.watch(localeProvider); 

    return VersionOverlay(
      child: MaterialApp.router(
        title: 'Tree Planting',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
        builder: (context, child) {
          final profileState = ref.watch(profileStateProvider);
          final profile = profileState.value;
          
          final isForcedTraining = profile?['training_required'] == true;
          final isForcedTutorial = profile?['force_tutorial'] == true;
          final hasCompletedTutorial = profile?['tutorial_completed'] == true;
          
          // Force training mode ON if the profile dictates it
          final effectiveTrainingMode = isTrainingMode || isForcedTraining;
          
          if (!effectiveTrainingMode) return child!;
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                Container(
                  height: 40,
                  color: Colors.orange,
                  width: double.infinity,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Text(
                    'TRAINING MODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Expanded(child: child!),
              ],
            ),
          );
        },
        // localizationsDelegates: AppLocalizations.localizationsDelegates,
        // supportedLocales: AppLocalizations.supportedLocales,
        // locale: locale,
      ),
    );
  }
}
