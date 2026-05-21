import 'package:json_annotation/json_annotation.dart';

part 'dashboard_recent_post_dto.g.dart';

/// One row from `GET /api/v1/dashboard/recent-posts`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DashboardRecentPostDto {
  final String igPostId;
  final String? thumbnailUrl;
  final String captionPreview;
  final DateTime publishedAt;
  final String publishedAgoLabel;
  final int likeCount;

  const DashboardRecentPostDto({
    required this.igPostId,
    this.thumbnailUrl,
    required this.captionPreview,
    required this.publishedAt,
    required this.publishedAgoLabel,
    required this.likeCount,
  });

  factory DashboardRecentPostDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardRecentPostDtoFromJson(json);
}
