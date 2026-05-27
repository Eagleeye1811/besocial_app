// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_patch_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandPatchDto _$BrandPatchDtoFromJson(Map<String, dynamic> json) =>
    BrandPatchDto(
      name: json['name'] as String?,
      businessType: json['business_type'] as String?,
      selectedStyles: (json['selected_styles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      nichePrimary: json['niche_primary'] as String?,
      nicheSub: json['niche_sub'] as String?,
      nicheMicro: json['niche_micro'] as String?,
      colorPaletteId: json['color_palette_id'] as String?,
      voiceToneId: json['voice_tone_id'] as String?,
      aestheticTheme: json['aesthetic_theme'] as String?,
      facePreference: json['face_preference'] as String?,
      faceInContent: json['face_in_content'] as String?,
      contentPillars: (json['content_pillars'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      hasProduct: json['has_product'] as bool?,
    );

Map<String, dynamic> _$BrandPatchDtoToJson(BrandPatchDto instance) =>
    <String, dynamic>{
      if (instance.name case final value?) 'name': value,
      if (instance.businessType case final value?) 'business_type': value,
      if (instance.selectedStyles case final value?) 'selected_styles': value,
      if (instance.nichePrimary case final value?) 'niche_primary': value,
      if (instance.nicheSub case final value?) 'niche_sub': value,
      if (instance.nicheMicro case final value?) 'niche_micro': value,
      if (instance.colorPaletteId case final value?) 'color_palette_id': value,
      if (instance.voiceToneId case final value?) 'voice_tone_id': value,
      if (instance.aestheticTheme case final value?) 'aesthetic_theme': value,
      if (instance.facePreference case final value?) 'face_preference': value,
      if (instance.faceInContent case final value?) 'face_in_content': value,
      if (instance.contentPillars case final value?) 'content_pillars': value,
      if (instance.hasProduct case final value?) 'has_product': value,
    };
