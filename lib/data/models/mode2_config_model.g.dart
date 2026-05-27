// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mode2_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mode2ConfigModel _$Mode2ConfigModelFromJson(Map<String, dynamic> json) =>
    Mode2ConfigModel(
      styleSource: $enumDecode(_$Mode2StyleSourceEnumMap, json['style_source']),
      paletteOverride: json['palette_override'] as String?,
      toneOverride: json['tone_override'] as String?,
      matchStylePostId: json['match_style_post_id'] as String?,
      assetId: json['asset_id'] as String?,
      editedSlideTexts: (json['edited_slide_texts'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
    );

Map<String, dynamic> _$Mode2ConfigModelToJson(Mode2ConfigModel instance) =>
    <String, dynamic>{
      'style_source': _$Mode2StyleSourceEnumMap[instance.styleSource]!,
      'palette_override': instance.paletteOverride,
      'tone_override': instance.toneOverride,
      'match_style_post_id': instance.matchStylePostId,
      'asset_id': instance.assetId,
      'edited_slide_texts': instance.editedSlideTexts,
    };

const _$Mode2StyleSourceEnumMap = {
  Mode2StyleSource.defaultStyle: 'default',
  Mode2StyleSource.override: 'override',
  Mode2StyleSource.matchOwnPost: 'match_own_post',
  Mode2StyleSource.replicateSource: 'replicate_source',
};
