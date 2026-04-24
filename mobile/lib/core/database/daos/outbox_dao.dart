import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/schema.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [OutboxEvents])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(AppDatabase db) : super(db);

  Future<List<OutboxEvent>> getReadyEvents({int limit = 50}) {
    return (select(outboxEvents)
          ..where((t) =>
              t.status.equals('pending') &
              (t.nextRetryAt.isNull() |
                  t.nextRetryAt.isSmallerOrEqualValue(DateTime.now())))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> markSynced(String id) {
    return (update(outboxEvents)..where((t) => t.id.equals(id)))
        .write(const OutboxEventsCompanion(
      status: Value('synced'),
      nextRetryAt: Value(null),
      lastError: Value(null),
    ));
  }

  Future<void> markFailed(String id, String error) {
    return (update(outboxEvents)..where((t) => t.id.equals(id)))
        .write(OutboxEventsCompanion(
      status: const Value('failed'),
      lastError: Value(error),
      nextRetryAt: const Value(null),
    ));
  }

  Future<void> scheduleRetry(
      String id, int attempts, DateTime nextRetryAt, String error) {
    return (update(outboxEvents)..where((t) => t.id.equals(id)))
        .write(OutboxEventsCompanion(
      attempts: Value(attempts),
      nextRetryAt: Value(nextRetryAt),
      lastError: Value(error),
    ));
  }

  Future<void> insertEvent(OutboxEventsCompanion event) {
    return into(outboxEvents).insert(event);
  }
}
