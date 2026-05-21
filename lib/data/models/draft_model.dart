import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/constants/app_keys.dart';

part 'draft_model.g.dart';

/// One item in `GET /api/v1/dashboard/drafts` (cursor-paginated). Hive-cached
/// so the drafts list opens instantly on cold start.
@HiveType(typeId: HiveTypeIds.draft)
@JsonSerializable(fieldRename: FieldRename.snake)
class DraftModel extends HiveObject {
  @HiveField(0)
  final String jobId;

  @HiveField(1)
  final String thumbnailUrl;

  @HiveField(2)
  final String captionPreview;

  @HiveField(3)
  final int slideCount;

  @HiveField(4)
  final DateTime generatedAt;

  @HiveField(5)
  final String generatedAgoLabel;

  @HiveField(6)
  final String? sourcePostId;

  @HiveField(7)
  final String sourceAuthorHandle;

  DraftModel({
    required this.jobId,
    required this.thumbnailUrl,
    required this.captionPreview,
    required this.slideCount,
    required this.generatedAt,
    required this.generatedAgoLabel,
    this.sourcePostId,
    required this.sourceAuthorHandle,
  });

  factory DraftModel.fromJson(Map<String, dynamic> json) =>
      _$DraftModelFromJson(json);

  Map<String, dynamic> toJson() => _$DraftModelToJson(this);
}
