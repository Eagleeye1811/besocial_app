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
      if (instance.paletteOverride case final value?) 'palette_override': value,
      if (instance.toneOverride case final value?) 'tone_override': value,
      if (instance.matchStylePostId case final value?)
        'match_style_post_id': value,
      if (instance.assetId case final value?) 'asset_id': value,
      if (instance.editedSlideTexts case final value?)
        'edited_slide_texts': value,
    };

const _$Mode2StyleSourceEnumMap = {
  Mode2StyleSource.defaultStyle: 'default',
  Mode2StyleSource.override: 'override',
  Mode2StyleSource.matchOwnPost: 'match_own_post',
  Mode2StyleSource.replicateSource: 'replicate_source',
};
