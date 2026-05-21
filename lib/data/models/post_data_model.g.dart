// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDataModel _$PostDataModelFromJson(Map<String, dynamic> json) =>
    PostDataModel(
      postId: json['post_id'] as String,
      shortcode: json['shortcode'] as String,
      url: json['url'] as String,
      caption: json['caption'] as String,
      hashtags:
          (json['hashtags'] as List<dynamic>).map((e) => e as String).toList(),
      mediaType: json['media_type'] as String,
      displayUrl: json['display_url'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      likeCount: (json['like_count'] as num).toInt(),
      commentCount: (json['comment_count'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPinned: json['is_pinned'] as bool,
      isCommentsDisabled: json['is_comments_disabled'] as bool,
      dimensionsWidth: (json['dimensions_width'] as num?)?.toInt(),
      dimensionsHeight: (json['dimensions_height'] as num?)?.toInt(),
      ownerUsername: json['owner_username'] as String,
      ownerFullName: json['owner_full_name'] as String?,
    );

Map<String, dynamic> _$PostDataModelToJson(PostDataModel instance) =>
    <String, dynamic>{
      'post_id': instance.postId,
      'shortcode': instance.shortcode,
      'url': instance.url,
      'caption': instance.caption,
      'hashtags': instance.hashtags,
      'media_type': instance.mediaType,
      'display_url': instance.displayUrl,
      'images': instance.images,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'timestamp': instance.timestamp.toIso8601String(),
      'is_pinned': instance.isPinned,
      'is_comments_disabled': instance.isCommentsDisabled,
      'dimensions_width': instance.dimensionsWidth,
      'dimensions_height': instance.dimensionsHeight,
      'owner_username': instance.ownerUsername,
      'owner_full_name': instance.ownerFullName,
    };
