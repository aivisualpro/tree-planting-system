import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Firebase is currently disabled (incompatible with Xcode 26).
// This is a stub that provides the same interface so the rest of the app compiles.

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  Future<void> initialize() async {
    debugPrint('NotificationService.initialize() — Firebase disabled');
  }

  Future<void> registerToken() async {
    debugPrint('NotificationService.registerToken() — Firebase disabled');
  }

  Future<void> revokeToken() async {
    debugPrint('NotificationService.revokeToken() — Firebase disabled');
  }

  void setupInteractedMessage(GoRouter router) {
    debugPrint('NotificationService.setupInteractedMessage() — Firebase disabled');
  }
}
