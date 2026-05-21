import 'package:json_annotation/json_annotation.dart';

part 'niche_data_model.g.dart';

/// Mirrors `NicheData` returned inside `POST /api/v1/onboarding/analyze`.
/// Used to populate the niche-results step and the brand editor's niche
/// section (server stores it on the session and copies it to the user on
/// OAuth promotion).
@JsonSerializable(fieldRename: FieldRename.snake)
class NicheDataModel {
  final String niche;
  final String subNiche;
  final String microNiche;
  final double confidence;
  final List<String> confirmedTopics;
  final List<String> suggestedTopics;
  final List<String> confirmedHashtags;
  final List<String> suggestedHashtags;
  final List<String> contentFormats;
  final List<String> generatableFormats;
  final String dreamNarrative;
  final String engagementProfile;
  final String? dominantLang;
  final bool isLocationSpecific;
  final bool isBusinessAccount;
  final List<String> seedSearchQueries;

  const NicheDataModel({
    required this.niche,
    required this.subNiche,
    required this.microNiche,
    required this.confidence,
    required this.confirmedTopics,
    required this.suggestedTopics,
    required this.confirmedHashtags,
    required this.suggestedHashtags,
    required this.contentFormats,
    required this.generatableFormats,
    required this.dreamNarrative,
    required this.engagementProfile,
    this.dominantLang,
    required this.isLocationSpecific,
    required this.isBusinessAccount,
    required this.seedSearchQueries,
  });

  factory NicheDataModel.fromJson(Map<String, dynamic> json) =>
      _$NicheDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$NicheDataModelToJson(this);
}
