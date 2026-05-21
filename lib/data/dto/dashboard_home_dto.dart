import 'package:json_annotation/json_annotation.dart';

part 'dashboard_home_dto.g.dart';

/// Typed Dart mirror of `GET /api/v1/dashboard/home`. The backend route
/// returns a plain dict (no Pydantic model) — see
/// `src/services/dashboard/home.py:104` — so this DTO is the spec on the
/// client side. Keep field names in lockstep with the service.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DashboardHomeDto {
  final HomeUserDto user;
  final HomeHeadlineDto headline;
  final HomeMetricsDto metrics;

  const DashboardHomeDto({
    required this.user,
    required this.headline,
    required this.metrics,
  });

  factory DashboardHomeDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardHomeDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class HomeUserDto {
  final String name;
  final String? igUsername;
  final bool igConnected;

  const HomeUserDto({
    required this.name,
    this.igUsername,
    required this.igConnected,
  });

  factory HomeUserDto.fromJson(Map<String, dynamic> json) =>
      _$HomeUserDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class HomeHeadlineDto {
  /// Signed delta — positive means "engagement up by N% this week."
  final double? engagementDeltaPct;
  final int? trendingMatchCount;

  const HomeHeadlineDto({this.engagementDeltaPct, this.trendingMatchCount});

  factory HomeHeadlineDto.fromJson(Map<String, dynamic> json) =>
      _$HomeHeadlineDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class HomeMetricsDto {
  final FollowersMetricDto? followers;
  final PostsViaGrowgramMetricDto? postsViaBesocial;
  final EngagementRateMetricDto? engagementRate;
  final BestPerformerDto? bestPerformer30d;

  const HomeMetricsDto({
    this.followers,
    this.postsViaBesocial,
    this.engagementRate,
    this.bestPerformer30d,
  });

  factory HomeMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$HomeMetricsDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class FollowersMetricDto {
  final int? current;
  final int? deltaThisWeek;

  const FollowersMetricDto({this.current, this.deltaThisWeek});

  factory FollowersMetricDto.fromJson(Map<String, dynamic> json) =>
      _$FollowersMetricDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PostsViaGrowgramMetricDto {
  final int? current;
  final int? deltaThisMonth;

  const PostsViaGrowgramMetricDto({this.current, this.deltaThisMonth});

  factory PostsViaGrowgramMetricDto.fromJson(Map<String, dynamic> json) =>
      _$PostsViaGrowgramMetricDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class EngagementRateMetricDto {
  final double? currentPct;
  final double? deltaPct;
  final List<double>? sparkline30d;

  const EngagementRateMetricDto({
    this.currentPct,
    this.deltaPct,
    this.sparkline30d,
  });

  factory EngagementRateMetricDto.fromJson(Map<String, dynamic> json) =>
      _$EngagementRateMetricDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BestPerformerDto {
  final String? igPostId;
  final String? thumbnailUrl;
  final String? captionPreview;
  final int? engagementCount;

  const BestPerformerDto({
    this.igPostId,
    this.thumbnailUrl,
    this.captionPreview,
    this.engagementCount,
  });

  factory BestPerformerDto.fromJson(Map<String, dynamic> json) =>
      _$BestPerformerDtoFromJson(json);
}
