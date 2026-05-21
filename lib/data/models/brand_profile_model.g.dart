// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandAssetsSummaryModel _$BrandAssetsSummaryModelFromJson(
        Map<String, dynamic> json) =>
    BrandAssetsSummaryModel(
      total: (json['total'] as num).toInt(),
      byType: Map<String, int>.from(json['by_type'] as Map),
      primaryByType: Map<String, String>.from(json['primary_by_type'] as Map),
    );

Map<String, dynamic> _$BrandAssetsSummaryModelToJson(
        BrandAssetsSummaryModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'by_type': instance.byType,
      'primary_by_type': instance.primaryByType,
    };

BrandProfileModel _$BrandProfileModelFromJson(Map<String, dynamic> json) =>
    BrandProfileModel(
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      businessType: json['business_type'] as String?,
      instagramUsername: json['instagram_username'] as String?,
      niche: json['niche'] as Map<String, dynamic>?,
      personalization: json['personalization'] as Map<String, dynamic>?,
      selectedStyles: (json['selected_styles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      assetsSummary: BrandAssetsSummaryModel.fromJson(
          json['assets_summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BrandProfileModelToJson(BrandProfileModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'business_type': instance.businessType,
      'instagram_username': instance.instagramUsername,
      'niche': instance.niche,
      'personalization': instance.personalization,
      'selected_styles': instance.selectedStyles,
      'assets_summary': instance.assetsSummary,
    };
