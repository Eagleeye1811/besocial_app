// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditedNicheDto _$EditedNicheDtoFromJson(Map<String, dynamic> json) =>
    EditedNicheDto(
      confirmedTopics: (json['confirmed_topics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      suggestedTopics: (json['suggested_topics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      confirmedHashtags: (json['confirmed_hashtags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      suggestedHashtags: (json['suggested_hashtags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$EditedNicheDtoToJson(EditedNicheDto instance) =>
    <String, dynamic>{
      if (instance.confirmedTopics case final value?) 'confirmed_topics': value,
      if (instance.suggestedTopics case final value?) 'suggested_topics': value,
      if (instance.confirmedHashtags case final value?)
        'confirmed_hashtags': value,
      if (instance.suggestedHashtags case final value?)
        'suggested_hashtags': value,
    };

OnboardingPatchDto _$OnboardingPatchDtoFromJson(Map<String, dynamic> json) =>
    OnboardingPatchDto(
      businessType: json['business_type'] as String?,
      editedNiche: json['edited_niche'] == null
          ? null
          : EditedNicheDto.fromJson(
              json['edited_niche'] as Map<String, dynamic>),
      pickedPostId: json['picked_post_id'] as String?,
      selectedStyles: (json['selected_styles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      colorPaletteId: json['color_palette_id'] as String?,
      voiceToneId: json['voice_tone_id'] as String?,
    );

Map<String, dynamic> _$OnboardingPatchDtoToJson(OnboardingPatchDto instance) =>
    <String, dynamic>{
      if (instance.businessType case final value?) 'business_type': value,
      if (instance.editedNiche case final value?) 'edited_niche': value,
      if (instance.pickedPostId case final value?) 'picked_post_id': value,
      if (instance.selectedStyles case final value?) 'selected_styles': value,
      if (instance.colorPaletteId case final value?) 'color_palette_id': value,
      if (instance.voiceToneId case final value?) 'voice_tone_id': value,
    };
