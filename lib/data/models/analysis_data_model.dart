import 'package:json_annotation/json_annotation.dart';

part 'analysis_data_model.g.dart';

/// Engagement summary computed during `POST /api/v1/onboarding/analyze`.
/// Drives the "analyzing posts" and "detected style" copy.
@JsonSerializable(fieldRename: FieldRename.snake)
class AnalysisDataModel {
  final double engagementRate;
  final String engagementLabel;
  final double postsPerWeek;
  final String bestFormat;
  final double? carouselEngagement;
  final double? imageEngagement;
  final double avgCaptionLength;
  final double avgHashtagCount;
  final double consistencyScore;
  final double profileScore;
  final String growthStage;
  final int totalPostsAnalyzed;

  const AnalysisDataModel({
    required this.engagementRate,
    required this.engagementLabel,
    required this.postsPerWeek,
    required this.bestFormat,
    this.carouselEngagement,
    this.imageEngagement,
    required this.avgCaptionLength,
    required this.avgHashtagCount,
    required this.consistencyScore,
    required this.profileScore,
    required this.growthStage,
    required this.totalPostsAnalyzed,
  });

  factory AnalysisDataModel.fromJson(Map<String, dynamic> json) =>
      _$AnalysisDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisDataModelToJson(this);
}
