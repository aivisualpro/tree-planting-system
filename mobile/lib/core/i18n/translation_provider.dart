import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import 'translation_repository.dart';

part 'translation_provider.g.dart';

@Riverpod(keepAlive: true)
TranslationRepository translationRepository(Ref ref) {
  // Provided in bootstrap or via override
  throw UnimplementedError('Provide dependencies in bootstrap');
}

@riverpod
class CurrentLocale extends _$CurrentLocale {
  @override
  String build() {
    return 'en';
  }

  void setLocale(String locale) {
    state = locale;
  }
}

@riverpod
Future<String> entityTranslation(
  Ref ref, {
  required String entityType,
  required String entityId,
  required String field,
}) async {
  final repo = ref.watch(translationRepositoryProvider);
  final locale = ref.watch(currentLocaleProvider);
  
  final translation = await repo.getTranslation(entityType, entityId, field, locale);
  if (translation != null) return translation;

  if (locale != 'en') {
    final enTranslation = await repo.getTranslation(entityType, entityId, field, 'en');
    if (enTranslation != null) return enTranslation;
  }

  return field;
}

class TrText extends ConsumerWidget {
  final String entityType;
  final String entityId;
  final String field;
  final TextStyle? style;

  const TrText({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.field,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVal = ref.watch(entityTranslationProvider(
      entityType: entityType,
      entityId: entityId,
      field: field,
    ));

    return asyncVal.when(
      data: (text) => Text(text, style: style),
      loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => Text(field, style: style),
    );
  }
}
