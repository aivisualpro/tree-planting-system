import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/schema.dart';

part 'visits_dao.g.dart';

@DriftAccessor(tables: [Visits])
class VisitsDao extends DatabaseAccessor<AppDatabase> with _$VisitsDaoMixin {
  VisitsDao(AppDatabase db) : super(db);

  Future<Visit?> findByServerId(String id) {
    return (select(visits)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Visit?> findByClientUuid(String clientUuid) {
    return (select(visits)..where((t) => t.clientUuid.equals(clientUuid))).getSingleOrNull();
  }

  Future<void> insertFromServer(Map<String, dynamic> row) {
    return into(visits).insert(
      VisitsCompanion.insert(
        id: row['id'],
        clientUuid: row['client_uuid'],
        countryId: row['country_id'],
        coreAreaId: row['core_area_id'],
        activityId: row['activity_id'],
        status: const Value('synced'),
        createdBy: Value(row['created_by']),
        createdAt: Value(DateTime.parse(row['created_at'])),
        updatedAt: Value(DateTime.parse(row['updated_at'])),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> upsertFromServer(Map<String, dynamic> row) {
    return insertFromServer(row);
  }

  Future<void> upsertDraft(VisitsCompanion draft) {
    return into(visits).insert(draft, mode: InsertMode.insertOrReplace);
  }

  Stream<List<Visit>> watchAllVisits() {
    return (select(visits)
      ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)])
    ).watch();
  }
}
