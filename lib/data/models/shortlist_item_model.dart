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

  // The backend's `/dashboard/shortlist` payload can report mid-pipeline
  // statuses (`pending` / `analyzing` / `planning` / `rendering`) in addition
  // to the four terminal-ish ones. The web treats every in-flight stage as
  // "generating" (and resumes polling for it); mapping unknown wire values to
  // `generating` reproduces that and stops `fromJson` throwing on them.
  @HiveField(8)
  @JsonKey(unknownEnumValue: ShortlistGenerationStatus.generating)
  final ShortlistGenerationStatus generationStatus;

  @HiveField(9)
  final String? generationJobId;

  @HiveField(10)
  final DateTime shortlistedAt;

  /// OCR status for the source-post slide text, used by the Mode 2 sheet:
  /// `pending` / `extracting` / `done` / `failed` (or null if never run).
  @HiveField(11)
  final String? extractionStatus;

  /// Per-slide OCR'd text, in slide order. Empty/null until extraction
  /// completes; pre-fills the Mode 2 slide-text editors.
  @HiveField(12)
  final List<String>? extractedSlideTexts;

  /// User-facing failure message captured when a generation fails — drives
  /// the shortlist card's failed-state copy alongside [generationErrorCode].
  @HiveField(13)
  final String? generationError;

  /// Canonical backend error code (e.g. `IP_RESTRICTION`) for the failed
  /// state; mapped to copy + actions by `generation_error_copy.dart`.
  @HiveField(14)
  final String? generationErrorCode;

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
    this.extractionStatus,
    this.extractedSlideTexts,
    this.generationError,
    this.generationErrorCode,
  });

  factory ShortlistItemModel.fromJson(Map<String, dynamic> json) =>
      _$ShortlistItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShortlistItemModelToJson(this);

  /// Field-preserving copy. New fields default to the current value so
  /// status flips (and error capture) never silently drop data.
  ShortlistItemModel copyWith({
    ShortlistGenerationStatus? generationStatus,
    String? generationJobId,
    String? extractionStatus,
    List<String>? extractedSlideTexts,
    String? generationError,
    String? generationErrorCode,
  }) {
    return ShortlistItemModel(
      postId: postId,
      authorHandle: authorHandle,
      thumbnailUrl: thumbnailUrl,
      images: images,
      caption: caption,
      likeCount: likeCount,
      format: format,
      slideCount: slideCount,
      generationStatus: generationStatus ?? this.generationStatus,
      generationJobId: generationJobId ?? this.generationJobId,
      shortlistedAt: shortlistedAt,
      extractionStatus: extractionStatus ?? this.extractionStatus,
      extractedSlideTexts: extractedSlideTexts ?? this.extractedSlideTexts,
      generationError: generationError ?? this.generationError,
      generationErrorCode: generationErrorCode ?? this.generationErrorCode,
    );
  }
}
