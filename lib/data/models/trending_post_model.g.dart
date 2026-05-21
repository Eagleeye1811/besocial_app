// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trending_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrendingPostModel _$TrendingPostModelFromJson(Map<String, dynamic> json) =>
    TrendingPostModel(
      postId: json['post_id'] as String,
      shortcode: json['shortcode'] as String,
      imageUrl: json['image_url'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      caption: json['caption'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      commentCount: (json['comment_count'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
      tier: $enumDecode(_$DiscoveryTierEnumMap, json['tier']),
      ownerUsername: json['owner_username'] as String,
      mediaType: json['media_type'] as String,
      isCarousel: json['is_carousel'] as bool,
    );

Map<String, dynamic> _$TrendingPostModelToJson(TrendingPostModel instance) =>
    <String, dynamic>{
      'post_id': instance.postId,
      'shortcode': instance.shortcode,
      'image_url': instance.imageUrl,
      'images': instance.images,
      'caption': instance.caption,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'score': instance.score,
      'tier': _$DiscoveryTierEnumMap[instance.tier]!,
      'owner_username': instance.ownerUsername,
      'media_type': instance.mediaType,
      'is_carousel': instance.isCarousel,
    };

const _$DiscoveryTierEnumMap = {
  DiscoveryTier.a: 'A',
  DiscoveryTier.b: 'B',
  DiscoveryTier.c: 'C',
};
