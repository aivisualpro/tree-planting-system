import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/schema.dart';

part 'sync_metadata_dao.g.dart';

@DriftAccessor(tables: [SyncMetadata])
class SyncMetadataDao extends DatabaseAccessor<AppDatabase> with _$SyncMetadataDaoMixin {
  SyncMetadataDao(AppDatabase db) : super(db);

  Future<DateTime?> get(String key) async {
    final row = await (select(syncMetadata)..where((t) => t.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    return DateTime.parse(row.value);
  }

  Future<void> set(String key, String value) {
    return into(syncMetadata).insert(
      SyncMetadataCompanion.insert(key: key, value: value),
      mode: InsertMode.insertOrReplace,
    );
  }
}
