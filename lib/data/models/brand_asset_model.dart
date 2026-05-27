import 'package:json_annotation/json_annotation.dart';

part 'brand_asset_model.g.dart';

/// Brand asset category, mirrors the backend `AssetType` literal.
enum BrandAssetType {
  face,
  product,
  logo,
  background,
  custom,
}

/// File metadata returned alongside each brand asset.
@JsonSerializable(fieldRename: FieldRename.snake)
class BrandAssetMetadataModel {
  final int? width;
  final int? height;
  final String? colorDominant;
  final int? fileSizeBytes;
  final String? mimeType;

  const BrandAssetMetadataModel({
    this.width,
    this.height,
    this.colorDominant,
    this.fileSizeBytes,
    this.mimeType,
  });

  factory BrandAssetMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$BrandAssetMetadataModelFromJson(json);

  Map<String, dynamic> toJson() => _$BrandAssetMetadataModelToJson(this);
}

/// Mirrors `BrandAssetResponse` from the brand asset CRUD endpoints
/// under `/api/v1/brand/assets`.
@JsonSerializable(fieldRename: FieldRename.snake)
class BrandAssetModel {
  final String assetId;
  final BrandAssetType type;
  final String label;
  final String filePath;
  final bool isPrimary;
  final DateTime uploadedAt;
  final BrandAssetMetadataModel metadata;

  const BrandAssetModel({
    required this.assetId,
    required this.type,
    required this.label,
    required this.filePath,
    required this.isPrimary,
    required this.uploadedAt,
    required this.metadata,
  });

  factory BrandAssetModel.fromJson(Map<String, dynamic> json) =>
      _$BrandAssetModelFromJson(json);

  Map<String, dynamic> toJson() => _$BrandAssetModelToJson(this);

  /// Immutable copy with selected fields overridden. Used by the controller's
  /// optimistic set-primary flip.
  BrandAssetModel copyWith({bool? isPrimary}) => BrandAssetModel(
        assetId: assetId,
        type: type,
        label: label,
        filePath: filePath,
        isPrimary: isPrimary ?? this.isPrimary,
        uploadedAt: uploadedAt,
        metadata: metadata,
      );
}
