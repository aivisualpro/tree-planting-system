import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../database/daos/sync_metadata_dao.dart';
import '../database/daos/visits_dao.dart';

/// Pulls server-side changes in batches of 100 rows.
/// §17 – batch upserts (100 rows per request)
/// §16 – target: 500 visits sync < 10 min on 4G
class DeltaPuller {
  static const int _batchSize = 100; // §17 batch upserts

  final SyncMetadataDao syncMetadataDao;
  final VisitsDao visitsDao;
  final SupabaseClient supabase;

  DeltaPuller({
    required this.syncMetadataDao,
    required this.visitsDao,
    required this.supabase,
  });

  Future<void> pullAll() async {
    await pullVisits();
    // Future: pullProfiles(), pullMasters(), pullTranslations()
  }

  Future<void> pullVisits() async {
    final cursor =
        await syncMetadataDao.get('visits.lastCursor') ?? DateTime(2000);
    var next = cursor;

    while (true) {
      // §17 – request exactly _batchSize rows
      final List<dynamic> rows = await supabase.rpc('pull_visits_since', params: {
        'since': cursor.toIso8601String(),
        'limit_': _batchSize,
      });

      if (rows.isEmpty) break;

      // Batch upsert the entire page in a single DB transaction (§17)
      await visitsDao.attachedDatabase.transaction(() async {
        for (final row in rows) {
          final rowMap = row as Map<String, dynamic>;
          final serverId = rowMap['id'] as String;
          final local = await visitsDao.findByServerId(serverId);

          if (local == null) {
            await visitsDao.insertFromServer(rowMap);
          } else {
            final serverUpdatedAt = DateTime.parse(rowMap['updated_at']);
            if (local.updatedAt.isBefore(serverUpdatedAt)) {
              await visitsDao.upsertFromServer(rowMap);
            }
          }

          final updatedAt = DateTime.parse(rowMap['updated_at']);
          if (updatedAt.isAfter(next)) next = updatedAt;
        }
      });

      await syncMetadataDao.set('visits.lastCursor', next.toIso8601String());
      if (rows.length < _batchSize) break;
    }
  }

  /// Optionally compress a JSON payload with gzip if > 10 KB (§17).
  static List<int> compressIfLarge(Map<String, dynamic> payload) {
    final raw = utf8.encode(jsonEncode(payload));
    if (raw.length > 10 * 1024) {
      return gzip.encode(raw);
    }
    return raw;
  }
}
