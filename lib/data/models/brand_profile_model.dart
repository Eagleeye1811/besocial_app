import 'package:json_annotation/json_annotation.dart';

part 'brand_profile_model.g.dart';

/// Aggregate summary nested inside [BrandProfileModel].
@JsonSerializable(fieldRename: FieldRename.snake)
class BrandAssetsSummaryModel {
  final int total;
  final Map<String, int> byType;
  final Map<String, String> primaryByType;

  const BrandAssetsSummaryModel({
    required this.total,
    required this.byType,
    required this.primaryByType,
  });

  factory BrandAssetsSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$BrandAssetsSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$BrandAssetsSummaryModelToJson(this);
}

/// Mirrors `BrandProfileResponse` from `GET /api/v1/brand`.
///
/// `niche` and `personalization` are typed as loose maps on the backend; we
/// keep them as `Map<String, dynamic>?` here. Tighten in a later phase only
/// if a UI surface needs typed access (the brand editor reads keys directly).
@JsonSerializable(fieldRename: FieldRename.snake)
class BrandProfileModel {
  final String userId;
  final String? name;
  final String? businessType;
  final String? instagramUsername;
  final Map<String, dynamic>? niche;
  final Map<String, dynamic>? personalization;
  final List<String> selectedStyles;
  final BrandAssetsSummaryModel assetsSummary;

  const BrandProfileModel({
    required this.userId,
    this.name,
    this.businessType,
    this.instagramUsername,
    this.niche,
    this.personalization,
    required this.selectedStyles,
    required this.assetsSummary,
  });

  factory BrandProfileModel.fromJson(Map<String, dynamic> json) =>
      _$BrandProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$BrandProfileModelToJson(this);
}
