import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../database/daos/outbox_dao.dart';
import 'retry_policy.dart';
import 'dart:convert';

class OutboxProcessor {
  final OutboxDao outboxDao;
  final SupabaseClient supabase;
  final RetryPolicy retryPolicy;

  OutboxProcessor({
    required this.outboxDao,
    required this.supabase,
    required this.retryPolicy,
  });

  Future<void> run() async {
    final events = await outboxDao.getReadyEvents(limit: 50);
    for (final event in events) {
      try {
        await _pushOne(event);
        await outboxDao.markSynced(event.id);
        // Note: we might want to pull the updated entity here, but delta puller will catch it anyway
      } on AuthException {
        await supabase.auth.refreshSession();
        // let the caller or next loop retry this
        rethrow;
      } catch (e) {
        final attempts = event.attempts + 1;
        if (attempts >= RetryPolicy.maxAttempts) {
          await outboxDao.markFailed(event.id, e.toString());
        } else {
          final delay = retryPolicy.nextRetryDelay(attempts);
          await outboxDao.scheduleRetry(
            event.id,
            attempts,
            DateTime.now().add(delay),
            e.toString(),
          );
        }
      }
    }
  }

  Future<void> _pushOne(OutboxEvent event) async {
    final payload = jsonDecode(event.payload) as Map<String, dynamic>;
    if (event.operation == 'upsert') {
      await supabase.from(event.entityType).upsert(payload, onConflict: 'client_uuid');
    } else if (event.operation == 'insert') {
      await supabase.from(event.entityType).insert(payload);
    } else if (event.operation == 'update') {
      await supabase.from(event.entityType).update(payload).eq('client_uuid', event.clientUuid);
    } else if (event.operation == 'delete') {
      await supabase.from(event.entityType).delete().eq('client_uuid', event.clientUuid);
    }
  }
}
