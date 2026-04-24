import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import 'sync_engine.dart';
import 'outbox_processor.dart';
import 'media_uploader.dart';
import 'delta_puller.dart';
import 'retry_policy.dart';

part 'sync_provider.g.dart';

import '../../features/settings/training_mode_provider.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final isTrainingMode = ref.watch(trainingModeProvider);
  final dbName = isTrainingMode ? 'demo.db' : 'db.sqlite';
  final db = AppDatabase(dbName: dbName);
  
  ref.onDispose(() {
    db.close();
  });
  
  return db;
}

@Riverpod(keepAlive: true)
SyncEngine syncEngine(SyncEngineRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = Supabase.instance.client;
  final connectivity = Connectivity();

  final retryPolicy = RetryPolicy();

  final outboxProcessor = OutboxProcessor(
    outboxDao: db.outboxDao,
    supabase: supabase,
    retryPolicy: retryPolicy,
  );

  final mediaUploader = MediaUploader(
    visitMediaDao: db.visitMediaDao,
    supabase: supabase,
  );

  final deltaPuller = DeltaPuller(
    syncMetadataDao: db.syncMetadataDao,
    visitsDao: db.visitsDao,
    supabase: supabase,
  );

  return SyncEngine(
    connectivity: connectivity,
    outboxProcessor: outboxProcessor,
    mediaUploader: mediaUploader,
    deltaPuller: deltaPuller,
    isTrainingMode: ref.watch(trainingModeProvider),
  );
}
