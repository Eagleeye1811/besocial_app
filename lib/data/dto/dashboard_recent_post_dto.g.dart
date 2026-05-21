// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_recent_post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardRecentPostDto _$DashboardRecentPostDtoFromJson(
        Map<String, dynamic> json) =>
    DashboardRecentPostDto(
      igPostId: json['ig_post_id'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      captionPreview: json['caption_preview'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      publishedAgoLabel: json['published_ago_label'] as String,
      likeCount: (json['like_count'] as num).toInt(),
    );
