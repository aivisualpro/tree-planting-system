import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'supabase_client.g.dart';

@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}

@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
}
