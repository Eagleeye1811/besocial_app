import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/dash_shell.dart';
import '../../../controllers/home_controller/home_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/dto/dashboard_home_dto.dart';
import '../widgets/metric_card.dart';
import '../widgets/recent_post_card.dart';
import '../widgets/sparkline.dart';
import '../widgets/trending_card.dart';

/// Mirrors `frontend/src/features/dashboard/pages/HomePage.jsx`. One parallel
/// load gates a single page-level loader / error+retry screen; on success the
/// content shows greeting + engagement subline, the metric grid (web is 4-up;
/// mobile collapses to 2×2), the "Your recent posts" carousel, and the
/// "Trending in your niche" carousel with its shortlist hearts.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashShell(
      currentTab: DashTab.home,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final home = controller.home.value;
          final err = controller.error.value;

          // Web: `if (loading) return <Loading/>`. We only take over the whole
          // screen on the very first load — a pull-to-refresh keeps content.
          if (controller.isLoading.value && home == null) {
            return const _LoadingState();
          }
          // Web: `if (error) return <Error/>`. Same guard: only blow away the
          // screen when there's nothing to show.
          if (err != null && home == null) {
            return _ErrorState(message: err, onRetry: controller.refreshAll);
          }

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: controller.refreshAll,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                _Greeting(home: home),
                const SizedBox(height: 20),
                _MetricsGrid(home: home),
                const SizedBox(height: 28),
                const _SectionHead(title: 'Your recent posts', link: 'View all'),
                const SizedBox(height: 12),
                _RecentRow(),
                const SizedBox(height: 28),
                const _SectionHead(
                  title: 'Trending in your niche',
                  link: 'Explore more',
                  eyebrow: 'DISCOVER',
                ),
                const SizedBox(height: 12),
                _TrendingRow(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final DashboardHomeDto? home;
  const _Greeting({required this.home});

  @override
  Widget build(BuildContext context) {
    final h = home;
    // Web: `userName = home?.user?.name || home?.user?.ig_username`.
    final userName = (h != null && h.user.name.isNotEmpty)
        ? h.user.name
        : (h?.user.igUsername ?? '');
    final greeting =
        userName.isNotEmpty ? 'Welcome back, $userName' : 'Welcome back';
    final subline = h != null ? _composeSubline(h.headline) : '';

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
        if (subline.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subline,
            style: TextStyle(fontSize: 14, color: AppColors.ink3, height: 1.5),
          ),
        ],
      ],
    );
  }

  // Mirrors HomePage.jsx subline assembly: an "up/down N% this week" clause
  // (skipped when the delta is null or exactly 0) joined by " · " with a
  // "N trending post(s) match(es) your style" clause.
  static String _composeSubline(HomeHeadlineDto h) {
    final parts = <String>[];
    final delta = h.engagementDeltaPct;
    if (delta != null && delta != 0) {
      final dir = delta > 0 ? 'up' : 'down';
      parts.add('Engagement $dir ${_trimNum(delta.abs())}% this week');
    }
    final n = h.trendingMatchCount ?? 0;
    if (n > 0) {
      parts.add(
        '$n trending ${n == 1 ? 'post matches' : 'posts match'} your style',
      );
    }
    return parts.join(' · ');
  }

  /// Drop a trailing `.0` so 5.0 prints as "5" but 5.2 stays "5.2" — matches
  /// the web rendering the raw number.
  static String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

class _MetricsGrid extends StatelessWidget {
  final DashboardHomeDto? home;
  const _MetricsGrid({required this.home});

  @override
  Widget build(BuildContext context) {
    final m = home?.metrics;
    final engagement = m?.engagementRate;
    final best = m?.bestPerformer30d;

    final cards = <Widget>[
      MetricCard(
        eyebrow: 'Followers',
        value: formatNumber(m?.followers?.current),
        delta: _plusDelta(m?.followers?.deltaThisWeek, 'this week'),
        deltaTone: MetricDeltaTone.good,
      ),
      MetricCard(
        eyebrow: 'Posts via Growgram',
        value: formatNumber(m?.postsViaBesocial?.current),
        delta: _plusDelta(m?.postsViaBesocial?.deltaThisMonth, 'this month'),
        deltaTone: MetricDeltaTone.good,
      ),
      MetricCard(
        eyebrow: 'Engagement rate',
        value: engagement?.currentPct != null
            ? '${_trimNum(engagement!.currentPct!)}%'
            : '—',
        delta: _pctDelta(engagement?.deltaPct, '30-day trend'),
        deltaTone: (engagement?.deltaPct ?? 0) >= 0
            ? MetricDeltaTone.good
            : MetricDeltaTone.neutral,
        trailing: (engagement?.sparkline30d?.isNotEmpty ?? false)
            ? Sparkline(values: engagement!.sparkline30d!)
            : null,
      ),
      MetricCard(
        eyebrow: 'Best performer · 30d',
        trailing: best != null
            ? _BestPerformerBody(data: best)
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
      // Slightly taller cells on compact phones so the Best Performer card
      // (thumbnail + value + caption) doesn't crowd; default phones keep the
      // designed proportion.
      childAspectRatio: Responsive.isCompact(context) ? 1.0 : 1.18,
      children: cards,
    );
  }

  static String? _plusDelta(int? delta, String suffix) {
    if (delta == null || delta == 0) return null;
    final sign = delta > 0 ? '+' : '';
    return '$sign$delta $suffix';
  }

  static String? _pctDelta(double? delta, String suffix) {
    if (delta == null || delta == 0) return null;
    final sign = delta > 0 ? '+' : '';
    return '$sign${_trimNum(delta)}% · $suffix';
  }

  static String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

/// Best performer card body. Mirrors the web `BestPerformerInner`:
/// thumbnail + engagement count + "engagements" label, then a 1-line caption.
class _BestPerformerBody extends StatelessWidget {
  final BestPerformerDto data;
  const _BestPerformerBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 44,
                height: 44,
                child: data.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: data.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.surface2),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.surface2),
                      )
                    : Container(color: AppColors.surface2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatNumber(data.engagementCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontFamilyFallback: AppFonts.displayFallback,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      height: 1,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'engagements',
                    style: TextStyle(fontSize: 11, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (data.captionPreview != null &&
            data.captionPreview!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            data.captionPreview!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.ink3, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _SectionHead extends StatelessWidget {
  final String title;
  final String? link;
  final String? eyebrow;
  const _SectionHead({required this.title, this.link, this.eyebrow});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null) ...[
              Text(
                eyebrow!,
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                  color: AppColors.ink3,
                ),
              ),
              const SizedBox(height: 4),
            ],
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
          ],
        ),
        if (link != null)
          Row(
            children: [
              Text(
                link!,
                style: TextStyle(fontSize: 13, color: AppColors.ink2),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward, size: 13, color: AppColors.ink2),
            ],
          ),
      ],
    );
  }
}

class _RecentRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // The empty card sizes to its own content; only the horizontal carousel
      // needs the fixed track height.
      if (controller.recentPosts.isEmpty) {
        return const _EmptyRecentPosts();
      }
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.recentPosts.length,
          itemBuilder: (_, i) =>
              RecentPostCard(post: controller.recentPosts[i]),
        ),
      );
    });
  }
}

class _TrendingRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Obx(() {
        if (controller.trending.isEmpty) {
          return const _EmptyHint(
            text: "We'll surface trending posts here once we know your niche.",
          );
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.trending.length,
          itemBuilder: (_, i) {
            final post = controller.trending[i];
            return TrendingCard(
              post: post,
              shortlisted: controller.isShortlisted(post.postId),
              onShortlist: () => controller.toggleTrendingShortlist(post),
            );
          },
        );
      }),
    );
  }
}

/// Full-screen first-load spinner. Web: "Loading your dashboard…".
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: 16),
          Text(
            'Loading your dashboard…',
            style: TextStyle(fontSize: 14, color: AppColors.ink3),
          ),
        ],
      ),
    );
  }
}

/// Full-screen error with retry. Web: "Couldn't load your dashboard" + Try again.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load your dashboard",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: AppColors.ink3),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty-state for the recent-posts carousel. Web shows a rich illustration;
/// the mobile-adapted version keeps the copy and the CTA into Discover.
class _EmptyRecentPosts extends StatelessWidget {
  const _EmptyRecentPosts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFDAD8D2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: 22, color: AppColors.accent),
          ),
          const SizedBox(height: 12),
          Text(
            'Your published posts will appear here',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Generate your first post in Discover. We'll draft captions and "
            "stage it for your approval — nothing publishes without you.",
            style: TextStyle(fontSize: 13, color: AppColors.ink3, height: 1.45),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Get.toNamed<void>(AppRoutes.discover),
            child: const Text('Generate your first post'),
          ),
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

/// Thousands-separated integer, mirroring the web's
/// `n.toLocaleString('en-US')`. Returns '—' for null (the web fallback).
String formatNumber(int? n) {
  if (n == null) return '—';
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return (n < 0 ? '-' : '') + buf.toString();

}
