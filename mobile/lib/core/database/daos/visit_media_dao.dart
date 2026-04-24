import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/schema.dart';

part 'visit_media_dao.g.dart';

@DriftAccessor(tables: [VisitMedia])
class VisitMediaDao extends DatabaseAccessor<AppDatabase> with _$VisitMediaDaoMixin {
  VisitMediaDao(AppDatabase db) : super(db);

  Future<List<VisitMediaData>> getPendingMedia() {
    return (select(visitMedia)..where((t) => t.uploadStatus.equals('pending'))).get();
  }

  Future<void> markUploaded(String id, String storagePath) {
    return (update(visitMedia)..where((t) => t.id.equals(id))).write(VisitMediaCompanion(
      uploadStatus: const Value('synced'),
      storagePath: Value(storagePath),
    ));
  }

  Future<void> markFailed(String id) {
    return (update(visitMedia)..where((t) => t.id.equals(id))).write(const VisitMediaCompanion(
      uploadStatus: Value('failed_permanently'),
    ));
  }
}
