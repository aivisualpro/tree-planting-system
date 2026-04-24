import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'training_mode_provider.g.dart';

@Riverpod(keepAlive: true)
class TrainingMode extends _$TrainingMode {
  static const _key = 'is_training_mode';
  final _storage = const FlutterSecureStorage();

  @override
  bool build() {
    _init();
    return false; // Default while loading
  }

  Future<void> _init() async {
    final value = await _storage.read(key: _key);
    state = value == 'true';
  }

  Future<void> toggle() async {
    final newValue = !state;
    await _storage.write(key: _key, value: newValue.toString());
    state = newValue;
  }
}
