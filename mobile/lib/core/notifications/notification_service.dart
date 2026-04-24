import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    if (kIsWeb) return;

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        // Here we could show an in-app banner or toast
      }
    });
  }

  Future<void> registerToken() async {
    if (kIsWeb) return;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final token = await _messaging.getToken();
      if (token != null) {
        await _supabase.from('device_tokens').upsert({
          'user_id': user.id,
          'platform': defaultTargetPlatform.name.toLowerCase(),
          'fcm_token': token,
          'last_seen_at': DateTime.now().toIso8601String(),
        });
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        await _supabase.from('device_tokens').upsert({
          'user_id': user.id,
          'platform': defaultTargetPlatform.name.toLowerCase(),
          'fcm_token': newToken,
          'last_seen_at': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  Future<void> revokeToken() async {
    if (kIsWeb) return;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      final token = await _messaging.getToken();
      if (token != null) {
        await _supabase.from('device_tokens').delete().match({
          'fcm_token': token,
          'user_id': user.id,
        });
      }
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Failed to revoke FCM token: $e');
    }
  }

  void setupInteractedMessage(GoRouter router) async {
    if (kIsWeb) return;

    // Get any messages which caused the application to open from a terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage, router);
    }

    // Also handle any interaction when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message, router);
    });
  }

  void _handleMessage(RemoteMessage message, GoRouter router) {
    // Example: navigate to visit detail if visit_id is in payload
    if (message.data.containsKey('visit_id')) {
      final visitId = message.data['visit_id'];
      router.go('/visits/$visitId');
    }
  }
}
