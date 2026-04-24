import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mutex/mutex.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'sync_state.dart';
import 'outbox_processor.dart';
import 'media_uploader.dart';
import 'delta_puller.dart';

/// Orchestrates a full sync cycle:
///  1. Upload pending outbox events (batch upserts)
///  2. Upload pending media (4 concurrent)
///  3. Pull server changes (delta)
///
/// §16 benchmark target: 500 visits + 2000 photos < 10 min on 4G
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
    if (!_stateController.isClosed) {
      _stateController.add(SyncStatus(
        state: state,
        pending: pending ?? 0,
        failed: failed ?? 0,
        lastRunAt: lastRunAt,
        lastError: lastError,
      ));
    }
  }

  Future<void> runSync() async {
    if (isTrainingMode) return;

    await _mutex.protect(() async {
      final span = Sentry.startTransaction('sync.runSync', 'task');
      final stopwatch = Stopwatch()..start();

      try {
        final connectivityResult = await connectivity.checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          _emit(state: SyncState.idle);
          return;
        }

        _emit(state: SyncState.running);

        // Trace each sub-phase for observability (§19)
        final outboxSpan = span.startChild('sync.outbox');
        await outboxProcessor.run();
        await outboxSpan.finish();

        final mediaSpan = span.startChild('sync.media');
        await mediaUploader.run();
        await mediaSpan.finish();

        final pullSpan = span.startChild('sync.delta_pull');
        await deltaPuller.pullAll();
        await pullSpan.finish();

        final durationMs = stopwatch.elapsedMilliseconds;
        span.setTag('duration_ms', durationMs.toString());
        await span.finish(status: const SpanStatus.ok());

        _emit(state: SyncState.idle, lastRunAt: DateTime.now());
      } catch (e, st) {
        await Sentry.captureException(e, stackTrace: st,
            withScope: (scope) => scope.setTag('sync_phase', 'runSync'));
        await span.finish(status: SpanStatus.internalError());
        _emit(state: SyncState.failed, lastError: e.toString());
      } finally {
        stopwatch.stop();
      }
    });
  }

  void dispose() {
    _stateController.close();
  }
}
