import 'package:json_annotation/json_annotation.dart';

part 'onboarding_dto.g.dart';

/// `EditedNiche` block inside [OnboardingPatchDto]. Both topic and hashtag
/// fields are optional — the backend treats missing as "no change."
@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class EditedNicheDto {
  final List<String>? confirmedTopics;
  final List<String>? suggestedTopics;
  final List<String>? confirmedHashtags;
  final List<String>? suggestedHashtags;

  const EditedNicheDto({
    this.confirmedTopics,
    this.suggestedTopics,
    this.confirmedHashtags,
    this.suggestedHashtags,
  });

  factory EditedNicheDto.fromJson(Map<String, dynamic> json) =>
      _$EditedNicheDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EditedNicheDtoToJson(this);
}

/// Body for `PATCH /api/v1/onboarding/session`. Every field is optional; the
/// backend updates only the fields that are present, so we set
/// `includeIfNull: false` and the controller composes per-step patches.
@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class OnboardingPatchDto {
  final String? businessType;
  final EditedNicheDto? editedNiche;
  final String? pickedPostId;
  final List<String>? selectedStyles;
  final String? colorPaletteId;
  final String? voiceToneId;

  const OnboardingPatchDto({
    this.businessType,
    this.editedNiche,
    this.pickedPostId,
    this.selectedStyles,
    this.colorPaletteId,
    this.voiceToneId,
  });

  factory OnboardingPatchDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingPatchDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingPatchDtoToJson(this);
}
