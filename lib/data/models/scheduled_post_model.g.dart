// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduledPostModel _$ScheduledPostModelFromJson(Map<String, dynamic> json) =>
    ScheduledPostModel(
      scheduledPostId: json['scheduled_post_id'] as String,
      jobId: json['job_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      status: $enumDecode(_$ScheduledPostStatusEnumMap, json['status'],
          unknownValue: ScheduledPostStatus.scheduled),
      thumbnailUrl: json['thumbnail_url'] as String?,
      caption: json['caption'] as String,
      slideCount: (json['slide_count'] as num).toInt(),
      igPostId: json['ig_post_id'] as String?,
      permalink: json['permalink'] as String?,
      errorMessage: json['error_message'] as String?,
    );

const _$ScheduledPostStatusEnumMap = {
  ScheduledPostStatus.scheduled: 'scheduled',
  ScheduledPostStatus.publishing: 'publishing',
  ScheduledPostStatus.published: 'published',
  ScheduledPostStatus.failed: 'failed',
};
