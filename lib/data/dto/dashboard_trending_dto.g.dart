// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_trending_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardTrendingPostDto _$DashboardTrendingPostDtoFromJson(
        Map<String, dynamic> json) =>
    DashboardTrendingPostDto(
      postId: json['post_id'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      authorHandle: json['author_handle'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      format: json['format'] as String,
      shortcode: json['shortcode'] as String,
    );
