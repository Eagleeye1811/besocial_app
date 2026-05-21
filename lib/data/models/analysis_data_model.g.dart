// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisDataModel _$AnalysisDataModelFromJson(Map<String, dynamic> json) =>
    AnalysisDataModel(
      engagementRate: (json['engagement_rate'] as num).toDouble(),
      engagementLabel: json['engagement_label'] as String,
      postsPerWeek: (json['posts_per_week'] as num).toDouble(),
      bestFormat: json['best_format'] as String,
      carouselEngagement: (json['carousel_engagement'] as num?)?.toDouble(),
      imageEngagement: (json['image_engagement'] as num?)?.toDouble(),
      avgCaptionLength: (json['avg_caption_length'] as num).toDouble(),
      avgHashtagCount: (json['avg_hashtag_count'] as num).toDouble(),
      consistencyScore: (json['consistency_score'] as num).toDouble(),
      profileScore: (json['profile_score'] as num).toDouble(),
      growthStage: json['growth_stage'] as String,
      totalPostsAnalyzed: (json['total_posts_analyzed'] as num).toInt(),
    );

Map<String, dynamic> _$AnalysisDataModelToJson(AnalysisDataModel instance) =>
    <String, dynamic>{
      'engagement_rate': instance.engagementRate,
      'engagement_label': instance.engagementLabel,
      'posts_per_week': instance.postsPerWeek,
      'best_format': instance.bestFormat,
      'carousel_engagement': instance.carouselEngagement,
      'image_engagement': instance.imageEngagement,
      'avg_caption_length': instance.avgCaptionLength,
      'avg_hashtag_count': instance.avgHashtagCount,
      'consistency_score': instance.consistencyScore,
      'profile_score': instance.profileScore,
      'growth_stage': instance.growthStage,
      'total_posts_analyzed': instance.totalPostsAnalyzed,
    };
