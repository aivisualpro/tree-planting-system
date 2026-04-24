import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../database/tables/schema.dart';

class TranslationRepository {
  final AppDatabase _db;
  final SupabaseClient _supabase;
  
  TranslationRepository(this._db, this._supabase);

  Future<String?> getTranslation(String entityType, String entityId, String field, String locale) async {
    final cached = await (_db.select(_db.translations)
          ..where((t) => t.entityType.equals(entityType))
          ..where((t) => t.entityId.equals(entityId))
          ..where((t) => t.field.equals(field))
          ..where((t) => t.locale.equals(locale)))
        .getSingleOrNull();

    if (cached != null && cached.value != null) {
      return cached.value;
    }

    // Network fetch fallback
    try {
      final response = await _supabase
          .from('translations')
          .select('id, value, updated_at')
          .eq('entity_type', entityType)
          .eq('entity_id', entityId)
          .eq('field', field)
          .eq('locale', locale)
          .maybeSingle();

      if (response != null && response['value'] != null) {
        await _db.into(_db.translations).insertOnConflictUpdate(
              TranslationsCompanion.insert(
                id: response['id'] as String,
                entityType: entityType,
                entityId: entityId,
                field: field,
                locale: locale,
                value: Value(response['value'] as String?),
                updatedAt: Value(DateTime.parse(response['updated_at'] as String)),
              ),
            );
        return response['value'] as String;
      }
    } catch (e) {
      // Offline or error, return null to fallback
    }

    return null;
  }

  Future<void> syncTranslationsForLocale(String locale) async {
    try {
      // Find latest updated_at for this locale
      final latest = await (_db.select(_db.translations)
            ..where((t) => t.locale.equals(locale))
            ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)])
            ..limit(1))
          .getSingleOrNull();

      var query = _supabase.from('translations').select('*').eq('locale', locale);
      if (latest != null) {
        query = query.gt('updated_at', latest.updatedAt.toIso8601String());
      }

      final results = await query;
      for (final row in results) {
        await _db.into(_db.translations).insertOnConflictUpdate(
              TranslationsCompanion.insert(
                id: row['id'] as String,
                entityType: row['entity_type'] as String,
                entityId: row['entity_id'] as String,
                field: row['field'] as String,
                locale: row['locale'] as String,
                value: Value(row['value'] as String?),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
              ),
            );
      }
    } catch (e) {
      // Error syncing
    }
  }

  RealtimeChannel subscribeToChanges(String locale) {
    return _supabase
        .channel('public:translations')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'translations',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'locale', value: locale),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord != null && newRecord.isNotEmpty) {
              _db.into(_db.translations).insertOnConflictUpdate(
                    TranslationsCompanion.insert(
                      id: newRecord['id'] as String,
                      entityType: newRecord['entity_type'] as String,
                      entityId: newRecord['entity_id'] as String,
                      field: newRecord['field'] as String,
                      locale: newRecord['locale'] as String,
                      value: Value(newRecord['value'] as String?),
                      updatedAt: Value(DateTime.parse(newRecord['updated_at'] as String)),
                    ),
                  );
            }
          },
        )
        ..subscribe();
  }
}
