import 'package:json_annotation/json_annotation.dart';

import '../models/scheduled_post_model.dart';

part 'scheduled_posts_response_dto.g.dart';

/// Response shape of `GET /api/v1/dashboard/scheduled-posts?start=&end=`.
/// The day window is bounded server-side; this just unwraps the `posts` list.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ScheduledPostsResponseDto {
  final List<ScheduledPostModel> posts;

  const ScheduledPostsResponseDto({required this.posts});

  factory ScheduledPostsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduledPostsResponseDtoFromJson(json);
}
