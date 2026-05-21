import 'package:json_annotation/json_annotation.dart';

import '../../core/network/cursor_pager.dart';
import '../models/draft_model.dart';

part 'drafts_feed_response_dto.g.dart';

/// Response shape of `GET /api/v1/dashboard/drafts`. Cursor-paginated;
/// drafts ordered by `updated_at desc, job_id asc`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DraftsFeedResponseDto {
  final List<DraftModel> drafts;
  final String? nextCursor;
  final int totalInView;

  const DraftsFeedResponseDto({
    required this.drafts,
    this.nextCursor,
    required this.totalInView,
  });

  factory DraftsFeedResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DraftsFeedResponseDtoFromJson(json);

  CursorPage<DraftModel> toCursorPage() => CursorPage<DraftModel>(
        items: drafts,
        nextCursor: nextCursor,
        totalInView: totalInView,
      );
}
