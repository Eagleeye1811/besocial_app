// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'niche_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NicheDataModel _$NicheDataModelFromJson(Map<String, dynamic> json) =>
    NicheDataModel(
      niche: json['niche'] as String,
      subNiche: json['sub_niche'] as String,
      microNiche: json['micro_niche'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      confirmedTopics: (json['confirmed_topics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suggestedTopics: (json['suggested_topics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      confirmedHashtags: (json['confirmed_hashtags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suggestedHashtags: (json['suggested_hashtags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contentFormats: (json['content_formats'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      generatableFormats: (json['generatable_formats'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dreamNarrative: json['dream_narrative'] as String,
      engagementProfile: json['engagement_profile'] as String,
      dominantLang: json['dominant_lang'] as String?,
      isLocationSpecific: json['is_location_specific'] as bool,
      isBusinessAccount: json['is_business_account'] as bool,
      seedSearchQueries: (json['seed_search_queries'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$NicheDataModelToJson(NicheDataModel instance) =>
    <String, dynamic>{
      'niche': instance.niche,
      'sub_niche': instance.subNiche,
      'micro_niche': instance.microNiche,
      'confidence': instance.confidence,
      'confirmed_topics': instance.confirmedTopics,
      'suggested_topics': instance.suggestedTopics,
      'confirmed_hashtags': instance.confirmedHashtags,
      'suggested_hashtags': instance.suggestedHashtags,
      'content_formats': instance.contentFormats,
      'generatable_formats': instance.generatableFormats,
      'dream_narrative': instance.dreamNarrative,
      'engagement_profile': instance.engagementProfile,
      'dominant_lang': instance.dominantLang,
      'is_location_specific': instance.isLocationSpecific,
      'is_business_account': instance.isBusinessAccount,
      'seed_search_queries': instance.seedSearchQueries,
    };
