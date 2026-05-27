import 'package:json_annotation/json_annotation.dart';

part 'brand_patch_dto.g.dart';

/// Body for `PATCH /api/v1/brand`. The backend declares
/// `extra="forbid"` so only known keys are allowed; everything is
/// optional, `includeIfNull: false` means a per-section save only sends
/// the slice that section owns.
///
/// Note: niche updates are *flat aliases* (`niche_primary` etc.), not a
/// nested `niche` object — the GET response *does* nest, but the PATCH
/// shape is what the backend accepts.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class BrandPatchDto {
  // Identity
  final String? name;
  final String? businessType;
  final List<String>? selectedStyles;

  // Niche (flat aliases on the wire)
  @JsonKey(name: 'niche_primary')
  final String? nichePrimary;
  @JsonKey(name: 'niche_sub')
  final String? nicheSub;
  @JsonKey(name: 'niche_micro')
  final String? nicheMicro;

  // Voice & visual / aesthetic
  final String? colorPaletteId;
  final String? voiceToneId;
  final String? aestheticTheme;

  // Content preferences
  final String? facePreference;

  /// Free-form note on face usage (backend `face_in_content: Optional[str]`).
  /// Sent only when [facePreference] == 'appears_in_content'.
  final String? faceInContent;
  final List<String>? contentPillars;
  final bool? hasProduct;

  const BrandPatchDto({
    this.name,
    this.businessType,
    this.selectedStyles,
    this.nichePrimary,
    this.nicheSub,
    this.nicheMicro,
    this.colorPaletteId,
    this.voiceToneId,
    this.aestheticTheme,
    this.facePreference,
    this.faceInContent,
    this.contentPillars,
    this.hasProduct,
  });

  factory BrandPatchDto.fromJson(Map<String, dynamic> json) =>
      _$BrandPatchDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BrandPatchDtoToJson(this);
}
