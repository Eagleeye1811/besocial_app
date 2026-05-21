import 'package:json_annotation/json_annotation.dart';

part 'dashboard_trending_dto.g.dart';

/// One row from `GET /api/v1/dashboard/trending`. Distinct from
/// `TrendingPostModel` (onboarding `/feed` shape) — dashboard trending
/// drops the tier/score/comment_count fields and adds `format` + `shortcode`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DashboardTrendingPostDto {
  final String postId;
  final String thumbnailUrl;
  final String authorHandle;
  final int likeCount;
  final String format;
  final String shortcode;

  const DashboardTrendingPostDto({
    required this.postId,
    required this.thumbnailUrl,
    required this.authorHandle,
    required this.likeCount,
    required this.format,
    required this.shortcode,
  });

  factory DashboardTrendingPostDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardTrendingPostDtoFromJson(json);
}
