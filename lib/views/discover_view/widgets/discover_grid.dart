import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/discover_post_model.dart';
import 'discover_detail_sheet.dart';

/// Masonry grid of discover posts — the mobile counterpart of the web
/// `DiscoverGridView`. Two balanced columns with format-driven tile heights,
/// a format badge, and a persistent bottom overlay (handle · likes · heart).
/// The heart toggles the shortlist in place; tapping a tile opens the detail
/// modal. An explicit "Load more" button paginates (matching the web).
class DiscoverGrid extends GetView<DiscoverController> {
  const DiscoverGrid({super.key});

  // Format-driven tile heights (mobile-scaled from the web's 280/320/240),
  // so the masonry reads with the same carousel-tallest rhythm.
  static double _heightFor(String format) {
    if (format == 'carousel') return 236;
    if (format == 'video') return 268;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final posts = controller.pager.items.toList();

      if (posts.isEmpty) return const _EmptyFilter();

      // Balance posts across two columns by running height (masonry).
      final left = <DiscoverPostModel>[];
      final right = <DiscoverPostModel>[];
      var leftH = 0.0;
      var rightH = 0.0;
      for (final p in posts) {
        final h = _heightFor(p.format) + 14;
        if (leftH <= rightH) {
          left.add(p);
          leftH += h;
        } else {
          right.add(p);
          rightH += h;
        }
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _MasonryColumn(posts: left)),
                const SizedBox(width: 14),
                Expanded(child: _MasonryColumn(posts: right)),
              ],
            ),
          ),
          const _LoadMore(),
        ],
      );
    });
  }
}

class _MasonryColumn extends StatelessWidget {
  final List<DiscoverPostModel> posts;
  const _MasonryColumn({required this.posts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < posts.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == posts.length - 1 ? 0 : 14),
            child: _MasonryCard(
              post: posts[i],
              height: DiscoverGrid._heightFor(posts[i].format),
            ),
          ),
      ],
    );
  }
}

class _MasonryCard extends GetView<DiscoverController> {
  final DiscoverPostModel post;
  final double height;
  const _MasonryCard({required this.post, required this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => DiscoverDetailSheet.show(context, post: post),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: height,
              child: post.thumbnailUrl.isEmpty
                  ? Container(color: AppColors.surface2)
                  : CachedNetworkImage(
                      imageUrl: post.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.surface2),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surface2,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.ink4,
                        ),
                      ),
                    ),
            ),
            Positioned(left: 10, top: 10, child: _FormatBadge(post: post)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _Overlay(post: post),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final DiscoverPostModel post;
  const _FormatBadge({required this.post});

  String get _label {
    if (post.format.isEmpty) return 'POST';
    if (post.format == 'carousel') {
      return post.slideCount > 0 ? 'CAROUSEL · ${post.slideCount}' : 'CAROUSEL';
    }
    return post.format.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final icon = post.format == 'carousel'
        ? Icons.grid_view_rounded
        : post.format == 'video'
            ? Icons.play_arrow_rounded
            : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xB81C1B19), // rgba(28,27,25,0.72)
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(
            _label,
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  final DiscoverPostModel post;
  const _Overlay({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 18, 10, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xD9181818), // 0.85
            Color(0x73181818), // 0.45
            Color(0x00181818),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@${post.authorHandle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_border,
                        size: 11, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      formatCount(post.likeCount),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _HeartButton(post: post),
        ],
      ),
    );
  }
}

class _HeartButton extends GetView<DiscoverController> {
  final DiscoverPostModel post;
  const _HeartButton({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.toggleShortlist(post),
      child: Obx(() {
        final on = controller.isShortlisted(post.postId);
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: on ? AppColors.accent : Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: on ? Border.all(color: AppColors.accent) : null,
          ),
          child: Icon(
            on ? Icons.favorite : Icons.favorite_border,
            size: 15,
            color: on ? Colors.white : AppColors.ink,
          ),
        );
      }),
    );
  }
}

class _LoadMore extends GetView<DiscoverController> {
  const _LoadMore();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Read the observables FIRST so the Obx always tracks something — the
      // `hasMore` getter is plain (non-reactive), so an early return on it
      // would leave this Obx observing nothing and trip GetX's guard.
      final loadingMore =
          controller.pager.isLoading.value && controller.pager.items.isNotEmpty;
      if (!controller.pager.hasMore) return const SizedBox(height: 24);
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Center(
          child: OutlinedButton(
            onPressed: loadingMore ? null : controller.pager.loadMore,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink2,
              side: const BorderSide(color: AppColors.line),
              backgroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(loadingMore ? 'Loading…' : 'Load more'),
          ),
        ),
      );
    });
  }
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 56),
      child: Column(
        children: [
          Text(
            'No posts match your filter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Switch to "All formats" — we\'ll bring more in as Discover grows.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.ink3, height: 1.55),
          ),
        ],
      ),
    );
  }
}

/// Thousands-separated count, matching the web `formatNumber`.
String formatCount(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return (n < 0 ? '-' : '') + buf.toString();
}
