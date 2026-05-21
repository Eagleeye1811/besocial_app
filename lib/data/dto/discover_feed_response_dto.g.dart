// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_feed_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscoverFeedResponseDto _$DiscoverFeedResponseDtoFromJson(
        Map<String, dynamic> json) =>
    DiscoverFeedResponseDto(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => DiscoverPostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
      totalInView: (json['total_in_view'] as num).toInt(),
      refreshIntervalHours: (json['refresh_interval_hours'] as num).toInt(),
      nextRefreshAt: json['next_refresh_at'] == null
          ? null
          : DateTime.parse(json['next_refresh_at'] as String),
    );
