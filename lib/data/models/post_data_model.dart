import 'package:json_annotation/json_annotation.dart';

part 'post_data_model.g.dart';

/// The Instagram post DTO used across the backend — returned by
/// `POST /api/v1/onboarding/analyze` (inside `posts: [PostData…]`) and
/// `GET /api/v1/users/me/instagram-posts`. Carries everything the UI needs
/// to render a post card or feed thumbnail.
@JsonSerializable(fieldRename: FieldRename.snake)
class PostDataModel {
  final String postId;
  final String shortcode;
  final String url;
  final String caption;
  final List<String> hashtags;
  final String mediaType;
  final String displayUrl;
  final List<String> images;
  final int likeCount;
  final int commentCount;
  final DateTime timestamp;
  final bool isPinned;
  final bool isCommentsDisabled;
  final int? dimensionsWidth;
  final int? dimensionsHeight;
  final String ownerUsername;
  final String? ownerFullName;

  const PostDataModel({
    required this.postId,
    required this.shortcode,
    required this.url,
    required this.caption,
    required this.hashtags,
    required this.mediaType,
    required this.displayUrl,
    required this.images,
    required this.likeCount,
    required this.commentCount,
    required this.timestamp,
    required this.isPinned,
    required this.isCommentsDisabled,
    this.dimensionsWidth,
    this.dimensionsHeight,
    required this.ownerUsername,
    this.ownerFullName,
  });

  factory PostDataModel.fromJson(Map<String, dynamic> json) =>
      _$PostDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostDataModelToJson(this);
}
