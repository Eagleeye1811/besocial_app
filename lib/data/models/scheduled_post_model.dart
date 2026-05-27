import 'package:json_annotation/json_annotation.dart';

part 'scheduled_post_model.g.dart';

/// Publish lifecycle of a scheduled post, mirroring the web client's
/// `ScheduledPostStatus` values. Only `published` and `failed` are terminal.
/// JSON values are the lowercase enum names, matching the backend payload.
enum ScheduledPostStatus {
  scheduled,
  publishing,
  published,
  failed,
}

/// One item in `GET /api/v1/dashboard/scheduled-posts?start=&end=`. The
/// backend auto-schedules each completed generation into the next free
/// two-hour slot, and a worker publishes it to Instagram when its time comes.
///
/// Not Hive-cached — the calendar always fetches the live day window so the
/// publish status reflects reality on open.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ScheduledPostModel {
  final String scheduledPostId;
  final String jobId;
  final DateTime scheduledAt;

  /// Falls back to [ScheduledPostStatus.scheduled] for any unknown value the
  /// backend might add later (mirrors the web card's `|| STATUS_STYLE.scheduled`).
  @JsonKey(unknownEnumValue: ScheduledPostStatus.scheduled)
  final ScheduledPostStatus status;

  final String? thumbnailUrl;
  final String caption;
  final int slideCount;
  final String? igPostId;
  final String? permalink;
  final String? errorMessage;

  const ScheduledPostModel({
    required this.scheduledPostId,
    required this.jobId,
    required this.scheduledAt,
    required this.status,
    this.thumbnailUrl,
    required this.caption,
    required this.slideCount,
    this.igPostId,
    this.permalink,
    this.errorMessage,
  });

  /// In-place clone for optimistic caption edits (the controller updates the
  /// open list entry without a refetch).
  ScheduledPostModel copyWith({String? caption}) => ScheduledPostModel(
        scheduledPostId: scheduledPostId,
        jobId: jobId,
        scheduledAt: scheduledAt,
        status: status,
        thumbnailUrl: thumbnailUrl,
        caption: caption ?? this.caption,
        slideCount: slideCount,
        igPostId: igPostId,
        permalink: permalink,
        errorMessage: errorMessage,
      );

  factory ScheduledPostModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduledPostModelFromJson(json);
}
