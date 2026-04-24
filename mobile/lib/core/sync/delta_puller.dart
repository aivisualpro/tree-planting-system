import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../database/daos/sync_metadata_dao.dart';
import '../database/daos/visits_dao.dart';

class DeltaPuller {
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
    // In future: pull profiles, masters, translations
  }

  Future<void> pullVisits() async {
    final cursor = await syncMetadataDao.get('visits.lastCursor') ?? DateTime(2000);
    var next = cursor;

    while (true) {
      final List<dynamic> rows = await supabase.rpc('pull_visits_since', params: {
        'since': cursor.toIso8601String(),
        'limit_': 500,
      });

      if (rows.isEmpty) break;

      await syncMetadataDao.db.transaction(() async {
        for (final row in rows) {
          final rowMap = row as Map<String, dynamic>;
          final serverId = rowMap['id'] as String;
          final local = await visitsDao.findByServerId(serverId);
          
          if (local == null) {
            await visitsDao.insertFromServer(rowMap);
          } else {
            // Check version or updated_at
            final localUpdatedAt = local.updatedAt;
            final serverUpdatedAt = DateTime.parse(rowMap['updated_at']);
            
            if (localUpdatedAt.isBefore(serverUpdatedAt)) {
              // TODO: if local.status == draft or local has changes, handle conflict (log conflict)
              await visitsDao.upsertFromServer(rowMap);
            }
          }

          final updatedAt = DateTime.parse(rowMap['updated_at']);
          if (updatedAt.isAfter(next)) {
            next = updatedAt;
          }
        }
      });

      await syncMetadataDao.set('visits.lastCursor', next.toIso8601String());

      if (rows.length < 500) break;
    }
  }
}
