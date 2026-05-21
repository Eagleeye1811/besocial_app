import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/dash_shell.dart';
import '../../../controllers/home_controller/home_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/dto/dashboard_home_dto.dart';
import '../widgets/metric_card.dart';
import '../widgets/recent_post_card.dart';
import '../widgets/sparkline.dart';
import '../widgets/trending_card.dart';

/// Mirrors `frontend/src/features/dashboard/pages/HomePage.jsx`. Greeting +
/// engagement subline, 2×2 metric grid (web is 4-up; mobile collapses),
/// "Your recent posts" carousel, "Trending in your niche" carousel.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashShell(
      currentTab: DashTab.home,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: controller.refreshAll,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              _Greeting(),
              const SizedBox(height: 20),
              _MetricsGrid(),
              const SizedBox(height: 28),
              _SectionHead(title: 'Your recent posts'),
              const SizedBox(height: 12),
              _RecentRow(),
              const SizedBox(height: 28),
              _SectionHead(title: 'Trending in your niche'),
              const SizedBox(height: 12),
              _TrendingRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final home = controller.home.value;
      final loading = controller.isLoadingHome.value && home == null;
      final greeting = loading
          ? 'Loading…'
          : 'Hey${home?.user.name != null ? ', ${home!.user.name.split(' ').first}' : ''}.';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.6,
              height: 1.1,
              color: AppColors.ink,
            ),
          ),
          if (home?.headline != null) ...[
            const SizedBox(height: 8),
            Text(
              _composeSubline(home!.headline),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.ink3,
                height: 1.5,
              ),
            ),
          ],
          Obx(() {
            final err = controller.homeError.value;
            if (err == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _ErrorPill(message: err, onRetry: controller.refreshAll),
            );
          }),
        ],
      );
    });
  }

  static String _composeSubline(HomeHeadlineDto h) {
    final parts = <String>[];
    final delta = h.engagementDeltaPct;
    if (delta != null) {
      final sign = delta >= 0 ? '↑' : '↓';
      parts.add('Engagement $sign ${delta.abs().toStringAsFixed(1)}% this week');
    }
    final n = h.trendingMatchCount ?? 0;
    if (n > 0) {
      parts.add('$n trending ${n == 1 ? 'post matches' : 'posts match'} your style');
    }
    return parts.join(' · ');
  }
}

class _MetricsGrid extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final home = controller.home.value;
      if (home == null) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: List.generate(
            4,
            (_) => Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }
      final m = home.metrics;
      final cards = <MetricCard>[
        MetricCard(
          eyebrow: 'Followers',
          value: _formatNumber(m.followers?.current),
          delta: _plusDelta(m.followers?.deltaThisWeek, 'this week'),
          deltaTone: MetricDeltaTone.good,
        ),
        MetricCard(
          eyebrow: 'Posts via Growgram',
          value: _formatNumber(m.postsViaBesocial?.current),
          delta: _plusDelta(m.postsViaBesocial?.deltaThisMonth, 'this month'),
          deltaTone: MetricDeltaTone.good,
        ),
        MetricCard(
          eyebrow: 'Engagement rate',
          value: m.engagementRate?.currentPct != null
              ? '${m.engagementRate!.currentPct!.toStringAsFixed(1)}%'
              : '—',
          delta: _pctDelta(m.engagementRate?.deltaPct, '30-day trend'),
          deltaTone: (m.engagementRate?.deltaPct ?? 0) >= 0
              ? MetricDeltaTone.good
              : MetricDeltaTone.neutral,
          trailing: (m.engagementRate?.sparkline30d?.isNotEmpty ?? false)
              ? Sparkline(values: m.engagementRate!.sparkline30d!)
              : null,
        ),
        MetricCard(
          eyebrow: 'Best performer · 30d',
          value: m.bestPerformer30d?.engagementCount != null
              ? _formatNumber(m.bestPerformer30d!.engagementCount)
              : null,
          trailing: m.bestPerformer30d?.captionPreview != null
              ? Text(
                  m.bestPerformer30d!.captionPreview!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.ink3),
                )
              : Text(
                  'No data yet',
                  style: TextStyle(fontSize: 12, color: AppColors.ink3),
                ),
        ),
      ];
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
        children: cards,
      );
    });
  }

  static String _formatNumber(int? n) {
    if (n == null) return '—';
    if (n < 1000) return '$n';
    if (n < 10000) return '${(n / 1000).toStringAsFixed(1)}k';
    if (n < 1000000) return '${(n / 1000).round()}k';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }

  static String? _plusDelta(int? delta, String suffix) {
    if (delta == null) return null;
    final sign = delta >= 0 ? '+' : '';
    return '$sign$delta $suffix';
  }

  static String? _pctDelta(double? delta, String suffix) {
    if (delta == null) return null;
    final sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)}% · $suffix';
  }
}

class _SectionHead extends StatelessWidget {
  final String title;
  const _SectionHead({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'View all',
          style: TextStyle(fontSize: 13, color: AppColors.accentInk),
        ),
      ],
    );
  }
}

class _RecentRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Obx(() {
        if (controller.isLoadingRecent.value &&
            controller.recentPosts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final err = controller.recentError.value;
        if (err != null && controller.recentPosts.isEmpty) {
          return _ErrorPill(message: err, onRetry: controller.refreshAll);
        }
        if (controller.recentPosts.isEmpty) {
          return _EmptyHint(text: 'No posts yet. Generate your first carousel.');
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.recentPosts.length,
          itemBuilder: (_, i) =>
              RecentPostCard(post: controller.recentPosts[i]),
        );
      }),
    );
  }
}

class _TrendingRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Obx(() {
        if (controller.isLoadingTrending.value && controller.trending.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final err = controller.trendingError.value;
        if (err != null && controller.trending.isEmpty) {
          return _ErrorPill(message: err, onRetry: controller.refreshAll);
        }
        if (controller.trending.isEmpty) {
          return _EmptyHint(text: "We'll surface trending posts here once we "
              'know your niche.');
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.trending.length,
          itemBuilder: (_, i) => TrendingCard(post: controller.trending[i]),
        );
      }),
    );
  }
}

class _ErrorPill extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPill({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              size: 16, color: Color(0xFFDC2626)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: AppColors.ink2),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.ink3),
        ),
      ),
    );
  }
}
