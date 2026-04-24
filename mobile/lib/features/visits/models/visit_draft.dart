import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_draft.freezed.dart';
part 'visit_draft.g.dart';

@freezed
class VisitDraft with _$VisitDraft {
  const factory VisitDraft({
    required String clientUuid,
    DateTime? scheduledDate,
    DateTime? startTime,
    DateTime? endTime,
    String? countryId,
    String? subwatershedId,
    String? communityId,
    String? groupId,
    String? visitType,
    String? individualName,
    String? schoolChurch,
    
    String? coreAreaId,
    String? activityId,
    int? unitsTrained,
    String? otherActivity,
    String? designatedTo,
    int? attendance,
    
    @Default([]) List<TreeSpeciesCount> trees,
    DateTime? plantingStartDate,
    DateTime? plantingEndDate,
    
    String? groupPhotoPath,
    @Default([]) List<String> activityPhotoPaths,
    String? signaturePath,
    double? latitude,
    double? longitude,
    String? comments,
    String? feedback,
    int? feedbackScore,
  }) = _VisitDraft;

  factory VisitDraft.fromJson(Map<String, dynamic> json) => _$VisitDraftFromJson(json);
}

@freezed
class TreeSpeciesCount with _$TreeSpeciesCount {
  const factory TreeSpeciesCount({
    required String speciesId,
    @Default(0) int count,
  }) = _TreeSpeciesCount;

  factory TreeSpeciesCount.fromJson(Map<String, dynamic> json) => _$TreeSpeciesCountFromJson(json);
}
