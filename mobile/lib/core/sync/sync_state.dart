import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

enum SyncState { idle, running, failed }

@freezed
class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    @Default(SyncState.idle) SyncState state,
    @Default(0) int pending,
    @Default(0) int failed,
    DateTime? lastRunAt,
    String? lastError,
  }) = _SyncStatus;
}
