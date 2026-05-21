// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscoverPostModel _$DiscoverPostModelFromJson(Map<String, dynamic> json) =>
    DiscoverPostModel(
      postId: json['post_id'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      authorHandle: json['author_handle'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      commentCount: (json['comment_count'] as num).toInt(),
      format: json['format'] as String,
      slideCount: (json['slide_count'] as num).toInt(),
      caption: json['caption'] as String,
      postedAgoLabel: json['posted_ago_label'] as String,
      shortcode: json['shortcode'] as String,
    );

Map<String, dynamic> _$DiscoverPostModelToJson(DiscoverPostModel instance) =>
    <String, dynamic>{
      'post_id': instance.postId,
      'thumbnail_url': instance.thumbnailUrl,
      'images': instance.images,
      'author_handle': instance.authorHandle,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'format': instance.format,
      'slide_count': instance.slideCount,
      'caption': instance.caption,
      'posted_ago_label': instance.postedAgoLabel,
      'shortcode': instance.shortcode,
    };
