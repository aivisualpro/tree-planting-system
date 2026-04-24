import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mutex/mutex.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'sync_state.dart';
import 'outbox_processor.dart';
import 'media_uploader.dart';
import 'delta_puller.dart';

class SyncEngine {
  final Connectivity connectivity;
  final OutboxProcessor outboxProcessor;
  final MediaUploader mediaUploader;
  final DeltaPuller deltaPuller;
  final bool isTrainingMode;

  final _stateController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get status => _stateController.stream;
  final Mutex _mutex = Mutex();

  SyncEngine({
    required this.connectivity,
    required this.outboxProcessor,
    required this.mediaUploader,
    required this.deltaPuller,
    this.isTrainingMode = false,
  }) {
    _stateController.add(const SyncStatus(state: SyncState.idle));
  }

  void _emit({
    required SyncState state,
    int? pending,
    int? failed,
    DateTime? lastRunAt,
    String? lastError,
  }) {
    _stateController.add(SyncStatus(
      state: state,
      pending: pending ?? 0,
      failed: failed ?? 0,
      lastRunAt: lastRunAt,
      lastError: lastError,
    ));
  }

  Future<void> runSync() async {
    if (isTrainingMode) return;
    
    await _mutex.protect(() async {
      try {
        final connectivityResult = await connectivity.checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          _emit(state: SyncState.idle);
          return;
        }

        _emit(state: SyncState.running);
        
        await outboxProcessor.run();
        await mediaUploader.run();
        await deltaPuller.pullAll();

        _emit(state: SyncState.idle, lastRunAt: DateTime.now());
      } catch (e, st) {
        Sentry.captureException(e, stackTrace: st);
        _emit(state: SyncState.failed, lastError: e.toString());
      }
    });
  }
}
