import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_provider.g.dart';

@Riverpod(keepAlive: true)
class DeviceStorage extends _$DeviceStorage {
  @override
  double build() {
    // Mock: Returns percentage used (0.0 to 1.0)
    // To test the 95% threshold block, we can set this to 0.96
    return 0.70; // 70% full by default
  }

  void simulateFullStorage() {
    state = 0.96;
  }

  void simulateWarningStorage() {
    state = 0.85;
  }
  
  void simulateNormalStorage() {
    state = 0.50;
  }
}
