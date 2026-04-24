import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'tables/schema.dart';

import 'daos/outbox_dao.dart';
import 'daos/sync_metadata_dao.dart';
import 'daos/visit_media_dao.dart';
import 'daos/visits_dao.dart';

part 'app_database.g.dart';
@DriftDatabase(
  tables: [
    Profiles,
    Countries,
    Visits,
    VisitTrees,
    VisitMedia,
    OutboxEvents,
    SyncMetadata,
    Translations,
  ],
  daos: [
    OutboxDao,
    SyncMetadataDao,
    VisitMediaDao,
    VisitsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({String dbName = 'db.sqlite'}) : super(_openConnection(dbName));

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection(String dbName) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, dbName));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
