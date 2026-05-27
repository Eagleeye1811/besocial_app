// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_posts_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduledPostsResponseDto _$ScheduledPostsResponseDtoFromJson(
        Map<String, dynamic> json) =>
    ScheduledPostsResponseDto(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => ScheduledPostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
