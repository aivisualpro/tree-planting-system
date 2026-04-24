import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final featureFlagsProvider = StateNotifierProvider<FeatureFlagsNotifier, Map<String, bool>>((ref) {
  return FeatureFlagsNotifier(Supabase.instance.client);
});

class FeatureFlagsNotifier extends StateNotifier<Map<String, bool>> {
  final SupabaseClient _client;

  FeatureFlagsNotifier(this._client) : super({}) {
    refreshFlags();
  }

  Future<void> refreshFlags() async {
    try {
      final response = await _client.rpc('get_feature_flags_for_user');
      if (response != null) {
        state = Map<String, bool>.from(response as Map);
      }
    } catch (e) {
      // Keep cached state on error
      print('Failed to load feature flags: $e');
    }
  }

  bool isEnabled(String key) {
    return state[key] ?? false;
  }
}
