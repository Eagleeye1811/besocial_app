import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/constants/app_keys.dart';

part 'shortlist_item_model.g.dart';

/// Per-card generation state shown on the shortlist screen.
/// `generating` is the only non-terminal value — the controller polls until
/// the card flips to `ready`/`generated`/`failed`.
///
/// Annotated with `@HiveType` because it appears as a field on the Hive-cached
/// [ShortlistItemModel]; without its own adapter Hive can't serialize the enum.
@HiveType(typeId: HiveTypeIds.shortlistGenerationStatus)
enum ShortlistGenerationStatus {
  @HiveField(0)
  ready,
  @HiveField(1)
  generating,
  @HiveField(2)
  generated,
  @HiveField(3)
  failed,
}

/// One row in `GET /api/v1/dashboard/shortlist`. Mode 2 config is fetched
/// separately via `/shortlist/{post_id}/config`, so this lightweight item
/// is safe to Hive-cache for offline list display.
@HiveType(typeId: HiveTypeIds.shortlistItem)
@JsonSerializable(fieldRename: FieldRename.snake)
class ShortlistItemModel extends HiveObject {
  @HiveField(0)
  final String postId;

  @HiveField(1)
  final String authorHandle;

  @HiveField(2)
  final String? thumbnailUrl;

  @HiveField(3)
  final List<String> images;

  @HiveField(4)
  final String caption;

  @HiveField(5)
  final int likeCount;

  @HiveField(6)
  final String format;

  @HiveField(7)
  final int slideCount;

  @HiveField(8)
  final ShortlistGenerationStatus generationStatus;

  @HiveField(9)
  final String? generationJobId;

  @HiveField(10)
  final DateTime shortlistedAt;

  ShortlistItemModel({
    required this.postId,
    required this.authorHandle,
    this.thumbnailUrl,
    required this.images,
    required this.caption,
    required this.likeCount,
    required this.format,
    required this.slideCount,
    required this.generationStatus,
    this.generationJobId,
    required this.shortlistedAt,
  });

  factory ShortlistItemModel.fromJson(Map<String, dynamic> json) =>
      _$ShortlistItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShortlistItemModelToJson(this);
}
