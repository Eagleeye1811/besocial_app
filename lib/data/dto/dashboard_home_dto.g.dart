// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_home_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardHomeDto _$DashboardHomeDtoFromJson(Map<String, dynamic> json) =>
    DashboardHomeDto(
      user: HomeUserDto.fromJson(json['user'] as Map<String, dynamic>),
      headline:
          HomeHeadlineDto.fromJson(json['headline'] as Map<String, dynamic>),
      metrics: HomeMetricsDto.fromJson(json['metrics'] as Map<String, dynamic>),
    );

HomeUserDto _$HomeUserDtoFromJson(Map<String, dynamic> json) => HomeUserDto(
      name: json['name'] as String,
      igUsername: json['ig_username'] as String?,
      igConnected: json['ig_connected'] as bool,
    );

HomeHeadlineDto _$HomeHeadlineDtoFromJson(Map<String, dynamic> json) =>
    HomeHeadlineDto(
      engagementDeltaPct: (json['engagement_delta_pct'] as num?)?.toDouble(),
      trendingMatchCount: (json['trending_match_count'] as num?)?.toInt(),
    );

HomeMetricsDto _$HomeMetricsDtoFromJson(Map<String, dynamic> json) =>
    HomeMetricsDto(
      followers: json['followers'] == null
          ? null
          : FollowersMetricDto.fromJson(
              json['followers'] as Map<String, dynamic>),
      postsViaBesocial: json['posts_via_besocial'] == null
          ? null
          : PostsViaGrowgramMetricDto.fromJson(
              json['posts_via_besocial'] as Map<String, dynamic>),
      engagementRate: json['engagement_rate'] == null
          ? null
          : EngagementRateMetricDto.fromJson(
              json['engagement_rate'] as Map<String, dynamic>),
      bestPerformer30d: json['best_performer30d'] == null
          ? null
          : BestPerformerDto.fromJson(
              json['best_performer30d'] as Map<String, dynamic>),
    );

FollowersMetricDto _$FollowersMetricDtoFromJson(Map<String, dynamic> json) =>
    FollowersMetricDto(
      current: (json['current'] as num?)?.toInt(),
      deltaThisWeek: (json['delta_this_week'] as num?)?.toInt(),
    );

PostsViaGrowgramMetricDto _$PostsViaGrowgramMetricDtoFromJson(
        Map<String, dynamic> json) =>
    PostsViaGrowgramMetricDto(
      current: (json['current'] as num?)?.toInt(),
      deltaThisMonth: (json['delta_this_month'] as num?)?.toInt(),
    );

EngagementRateMetricDto _$EngagementRateMetricDtoFromJson(
        Map<String, dynamic> json) =>
    EngagementRateMetricDto(
      currentPct: (json['current_pct'] as num?)?.toDouble(),
      deltaPct: (json['delta_pct'] as num?)?.toDouble(),
      sparkline30d: (json['sparkline30d'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

BestPerformerDto _$BestPerformerDtoFromJson(Map<String, dynamic> json) =>
    BestPerformerDto(
      igPostId: json['ig_post_id'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      captionPreview: json['caption_preview'] as String?,
      engagementCount: (json['engagement_count'] as num?)?.toInt(),
    );
