// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_asset_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandAssetMetadataModel _$BrandAssetMetadataModelFromJson(
        Map<String, dynamic> json) =>
    BrandAssetMetadataModel(
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      colorDominant: json['color_dominant'] as String?,
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt(),
      mimeType: json['mime_type'] as String?,
    );

Map<String, dynamic> _$BrandAssetMetadataModelToJson(
        BrandAssetMetadataModel instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'color_dominant': instance.colorDominant,
      'file_size_bytes': instance.fileSizeBytes,
      'mime_type': instance.mimeType,
    };

BrandAssetModel _$BrandAssetModelFromJson(Map<String, dynamic> json) =>
    BrandAssetModel(
      assetId: json['asset_id'] as String,
      type: $enumDecode(_$BrandAssetTypeEnumMap, json['type']),
      label: json['label'] as String,
      filePath: json['file_path'] as String,
      isPrimary: json['is_primary'] as bool,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      metadata: BrandAssetMetadataModel.fromJson(
          json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BrandAssetModelToJson(BrandAssetModel instance) =>
    <String, dynamic>{
      'asset_id': instance.assetId,
      'type': _$BrandAssetTypeEnumMap[instance.type]!,
      'label': instance.label,
      'file_path': instance.filePath,
      'is_primary': instance.isPrimary,
      'uploaded_at': instance.uploadedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$BrandAssetTypeEnumMap = {
  BrandAssetType.face: 'face',
  BrandAssetType.product: 'product',
  BrandAssetType.logo: 'logo',
  BrandAssetType.background: 'background',
  BrandAssetType.custom: 'custom',
};
