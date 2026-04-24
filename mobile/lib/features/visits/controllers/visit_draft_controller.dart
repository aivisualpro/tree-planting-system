import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/visit_draft.dart';
import '../../../core/database/app_database.dart';
import '../../../bootstrap.dart'; // Assume providers are here or accessible
import 'dart:convert';
import 'dart:async';

part 'visit_draft_controller.g.dart';

@riverpod
class VisitDraftController extends _$VisitDraftController {
  Timer? _debounce;

  @override
  VisitDraft build(String clientUuid) {
    // Attempt to load from database if exists
    _loadFromDb();
    return VisitDraft(clientUuid: clientUuid);
  }

  Future<void> _loadFromDb() async {
    // This would actually be a future provider or handled differently in Riverpod,
    // but for simplicity in this synchronous init, we just fetch and update state.
    // e.g. final db = ref.read(dbProvider);
    // final draft = await db.visitsDao.findByClientUuid(clientUuid);
    // if (draft != null && draft.status == 'draft') {
    //   state = VisitDraft.fromJson(jsonDecode(draft.payload)); // assuming payload column or mapping
    // }
  }

  void updateDraft(VisitDraft Function(VisitDraft) updater) {
    state = updater(state);
    _debouncedSave();
  }

  void _debouncedSave() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _saveToDb();
    });
  }

  Future<void> _saveToDb() async {
    // Save draft to Drift
    // final db = ref.read(dbProvider);
    // await db.visitsDao.upsertDraft(VisitsCompanion(...));
  }

  Future<void> submit() async {
    // Validation
    if (state.countryId == null || state.activityId == null || state.groupPhotoPath == null || state.signaturePath == null) {
      throw Exception('Missing required fields');
    }

    bool hasPlanting = state.trees.isNotEmpty && state.trees.any((t) => t.count > 0);
    // If activity involves planting, verify tree. For simplicity, assume all need at least one if trees is not empty.

    // 1. Mark as pending in Visits
    // 2. Insert into OutboxEvent
    // 3. Process media
    // 4. Trigger sync
  }
}
