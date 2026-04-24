import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileState extends _$ProfileState {
  @override
  Future<Map<String, dynamic>?> build() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
        
    return response;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> completeTutorial() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client
        .from('profiles')
        .update({
          'tutorial_completed': true,
          'force_tutorial': false,
        })
        .eq('id', user.id);
        
    await refresh();
  }
}
