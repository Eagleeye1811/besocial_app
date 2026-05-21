import 'package:json_annotation/json_annotation.dart';

import '../../core/network/cursor_pager.dart';
import '../models/discover_post_model.dart';

part 'discover_feed_response_dto.g.dart';

/// Response shape of `GET /api/v1/dashboard/discover/feed`. Carries the
/// usual cursor + total plus two refresh-cadence fields the UI uses to
/// drive the countdown banner.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DiscoverFeedResponseDto {
  final List<DiscoverPostModel> posts;
  final String? nextCursor;
  final int totalInView;
  final int refreshIntervalHours;
  final DateTime? nextRefreshAt;

  const DiscoverFeedResponseDto({
    required this.posts,
    this.nextCursor,
    required this.totalInView,
    required this.refreshIntervalHours,
    this.nextRefreshAt,
  });

  factory DiscoverFeedResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DiscoverFeedResponseDtoFromJson(json);

  /// Project to the generic [CursorPage] consumed by `CursorPager`. The
  /// refresh-cadence fields ride alongside on the controller, not in the
  /// pager itself.
  CursorPage<DiscoverPostModel> toCursorPage() => CursorPage<DiscoverPostModel>(
        items: posts,
        nextCursor: nextCursor,
        totalInView: totalInView,
      );
}
