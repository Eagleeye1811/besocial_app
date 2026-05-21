import 'package:json_annotation/json_annotation.dart';

part 'trending_post_model.g.dart';

/// Tier bucket assigned by the backend's discovery scorer. Pinned to the
/// wire format (`"A"|"B"|"C"`) — note the upper-case `@JsonValue`s.
enum DiscoveryTier {
  @JsonValue('A')
  a,
  @JsonValue('B')
  b,
  @JsonValue('C')
  c,
}

/// Mirrors `TrendingPost` (backend `src/models/discovery.py:73`), returned
/// inside `GET /api/v1/onboarding/feed`.
@JsonSerializable(fieldRename: FieldRename.snake)
class TrendingPostModel {
  final String postId;
  final String shortcode;
  final String imageUrl;
  final List<String> images;
  final String caption;
  final int likeCount;
  final int commentCount;
  final double score;
  final DiscoveryTier tier;
  final String ownerUsername;
  final String mediaType;
  final bool isCarousel;

  const TrendingPostModel({
    required this.postId,
    required this.shortcode,
    required this.imageUrl,
    required this.images,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.score,
    required this.tier,
    required this.ownerUsername,
    required this.mediaType,
    required this.isCarousel,
  });

  factory TrendingPostModel.fromJson(Map<String, dynamic> json) =>
      _$TrendingPostModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrendingPostModelToJson(this);
}
