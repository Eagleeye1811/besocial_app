import 'package:json_annotation/json_annotation.dart';

part 'discover_post_model.g.dart';

/// Format filter on `GET /api/v1/dashboard/discover/feed?format=…`.
/// `all` is the default and means no filter.
enum DiscoverFormat {
  all,
  carousel,
  single,
  video,
}

/// Mirrors a single item in the dashboard discover feed
/// (`GET /api/v1/dashboard/discover/feed`).
@JsonSerializable(fieldRename: FieldRename.snake)
class DiscoverPostModel {
  final String postId;
  final String thumbnailUrl;
  final List<String> images;
  final String authorHandle;
  final int likeCount;
  final int commentCount;
  final String format;
  final int slideCount;
  final String caption;
  final String postedAgoLabel;
  final String shortcode;

  const DiscoverPostModel({
    required this.postId,
    required this.thumbnailUrl,
    required this.images,
    required this.authorHandle,
    required this.likeCount,
    required this.commentCount,
    required this.format,
    required this.slideCount,
    required this.caption,
    required this.postedAgoLabel,
    required this.shortcode,
  });

  factory DiscoverPostModel.fromJson(Map<String, dynamic> json) =>
      _$DiscoverPostModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiscoverPostModelToJson(this);
}
