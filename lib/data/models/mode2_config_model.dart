import 'package:json_annotation/json_annotation.dart';

part 'mode2_config_model.g.dart';

/// Mode-2 style discriminator. The backend's `Mode2Config`
/// (`src/models/mode2_config.py`) enforces mutual-exclusivity rules per
/// variant — UI controls should gate construction so a PATCH never round-trips
/// an inconsistent shape:
///
///   - [defaultStyle]   → no overrides allowed
///   - [override]       → requires `paletteOverride` + `toneOverride`
///   - [matchOwnPost]   → requires `matchStylePostId`, forbids overrides
///   - [replicateSource]→ no overrides allowed
///
/// `default` is a Dart reserved word; we keep the wire value via `@JsonValue`.
enum Mode2StyleSource {
  @JsonValue('default')
  defaultStyle,
  @JsonValue('override')
  override,
  @JsonValue('match_own_post')
  matchOwnPost,
  @JsonValue('replicate_source')
  replicateSource,
}

/// Body for `PATCH /api/v1/dashboard/shortlist/{post_id}/config` and result of
/// the matching GET. The PATCH is a wholesale replace, so we serialize every
/// field (including explicit `null`s) — matching the web `buildPayload`, which
/// always sends `palette_override` / `tone_override` / `match_style_post_id` /
/// `asset_id` / `edited_slide_texts` even when null. All keys are declared on
/// the backend's `Mode2ConfigPatchRequest`, so `extra="forbid"` is satisfied.
@JsonSerializable(fieldRename: FieldRename.snake)
class Mode2ConfigModel {
  final Mode2StyleSource styleSource;
  final String? paletteOverride;
  final String? toneOverride;
  final String? matchStylePostId;
  final String? assetId;

  /// Per-slide caption edits — `null` entries mean "keep generated text".
  final List<String?>? editedSlideTexts;

  const Mode2ConfigModel({
    required this.styleSource,
    this.paletteOverride,
    this.toneOverride,
    this.matchStylePostId,
    this.assetId,
    this.editedSlideTexts,
  });

  factory Mode2ConfigModel.fromJson(Map<String, dynamic> json) =>
      _$Mode2ConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$Mode2ConfigModelToJson(this);
}
