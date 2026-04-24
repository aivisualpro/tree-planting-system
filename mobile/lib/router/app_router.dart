import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/terms_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/visits/screens/visit_list_screen.dart';
import '../features/visits/screens/create_visit_screen.dart';
import '../features/visits/screens/visit_detail_screen.dart';
import '../features/visits/screens/drafts_screen.dart';
import '../features/sync/screens/sync_log_screen.dart';
import '../features/sync/screens/preload_data_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/notifications_screen.dart';
import '../features/settings/offline_maps_screen.dart';
import '../features/settings/storage_screen.dart';
import '../features/settings/help_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/preload',
        builder: (context, state) => const PreloadDataScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/visits',
        builder: (context, state) => const VisitListScreen(),
      ),
      GoRoute(
        path: '/visits/create',
        builder: (context, state) => const CreateVisitScreen(),
      ),
      GoRoute(
        path: '/visits/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VisitDetailScreen(visitId: id);
        },
      ),
      GoRoute(
        path: '/drafts',
        builder: (context, state) => const DraftsScreen(),
      ),
      GoRoute(
        path: '/sync-log',
        builder: (context, state) => const SyncLogScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Profile'))),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'offline-maps',
            builder: (context, state) => const OfflineMapsScreen(),
          ),
          GoRoute(
            path: 'storage',
            builder: (context, state) => const StorageScreen(),
          ),
          GoRoute(
            path: 'help',
            builder: (context, state) => const HelpScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // Implement auth check redirect here later
      return null;
    },
  );
}
