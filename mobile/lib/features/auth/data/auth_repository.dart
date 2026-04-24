import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/notifications/notification_service.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(
    ref.watch(supabaseClientProvider), 
    ref.watch(notificationServiceProvider)
  );
}

class AuthRepository {
  final SupabaseClient _client;
  final NotificationService _notificationService;

  AuthRepository(this._client, this._notificationService);

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    await _notificationService.registerToken();
  }

  Future<void> signOut() async {
    await _notificationService.revokeToken();
    await _client.auth.signOut();
  }
}
