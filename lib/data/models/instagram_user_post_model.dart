import 'package:json_annotation/json_annotation.dart';

part 'instagram_user_post_model.g.dart';

/// One of the user's own Instagram posts, from
/// `GET /api/v1/users/me/instagram-posts`. Backing data for the Mode 2
/// "match style of one of my posts" picker. Mirrors the web shape in
/// `lib/api/brand.js` (`getUserInstagramPosts`).
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class InstagramUserPostModel {
  final String postId;
  final String? caption;
  final String? mediaType;
  final String? imageUrl;
  final String? permalink;
  final String? timestamp;

  const InstagramUserPostModel({
    required this.postId,
    this.caption,
    this.mediaType,
    this.imageUrl,
    this.permalink,
    this.timestamp,
  });

  factory InstagramUserPostModel.fromJson(Map<String, dynamic> json) =>
      _$InstagramUserPostModelFromJson(json);
}
