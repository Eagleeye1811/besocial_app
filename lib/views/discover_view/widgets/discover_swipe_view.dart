import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/discover_post_model.dart';
import 'discover_detail_sheet.dart';

/// Swipe presentation for Discover. Mirrors the web `DiscoverSwipeView`:
/// one large card (image carousel + meta + truncated caption) with Skip /
/// Shortlist actions, an "X of Y in this view" progress line, a session
/// shortlist counter, "Undo last skip", and a "How to swipe" block.
///
/// The current card is always the first item in the pager — Skip/Shortlist
/// pop it off optimistically and the next post slides into place.
class DiscoverSwipeView extends GetView<DiscoverController> {
  const DiscoverSwipeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.pager.items;
      final isLoading = controller.pager.isLoading.value;

      if (items.isEmpty && isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 96),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (items.isEmpty) {
        return _AllSeen(canUndo: controller.skippedHistory.isNotEmpty);
      }

      // Auto-load more so the deck never runs dry mid-session.
      if (items.length <= 3 && controller.pager.hasMore) {
        controller.pager.loadMore();
      }

      final current = items.first;
      final totalInView = controller.pager.totalInView.value;
      final shortlistCount = controller.sessionShortlistCount.value;
      final canUndo = controller.skippedHistory.isNotEmpty;
      final lastSkipped =
          canUndo ? controller.skippedHistory.last : null;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            _SwipeCard(
              // Key ensures the carousel resets when the post changes.
              key: ValueKey(current.postId),
              post: current,
            ),
            const SizedBox(height: 18),
            _ActionButtons(post: current),
            const SizedBox(height: 16),
            _Progress(
              totalInView: totalInView,
              shortlistCount: shortlistCount,
            ),
            const SizedBox(height: 16),
            if (canUndo)
              _UndoButton(
                lastSkipped: lastSkipped,
                onTap: controller.undoLastSkip,
              ),
            if (canUndo) const SizedBox(height: 16),
            const _HowToSwipe(),
          ],
        ),
      );
    });
  }
}

class _SwipeCard extends StatelessWidget {
  final DiscoverPostModel post;
  const _SwipeCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final images = post.images.isEmpty ? [post.thumbnailUrl] : post.images;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            offset: Offset(0, 18),
            blurRadius: 38,
            spreadRadius: -22,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: _CardCarousel(images: images),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(handle: post.authorHandle),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '@${post.authorHandle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontFamilyFallback: AppFonts.monoFallback,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const Icon(Icons.camera_alt_outlined,
                        size: 16, color: AppColors.ink3),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.favorite_outline,
                        size: 13, color: AppColors.ink3),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(post.likeCount),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink2,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.mode_comment_outlined,
                        size: 13, color: AppColors.ink3),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(post.commentCount),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink2,
                      ),
                    ),
                    const Spacer(),
                    if (post.postedAgoLabel.isNotEmpty)
                      Text(
                        post.postedAgoLabel,
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontFamilyFallback: AppFonts.monoFallback,
                          fontSize: 11,
                          color: AppColors.ink4,
                        ),
                      ),
                  ],
                ),
                if (post.caption.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    post.caption,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.ink2,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => DiscoverDetailSheet.show(context, post: post),
                  child: Text(
                    'View full post',
                    style: TextStyle(
                      fontFamily: AppFonts.ui,
                      fontFamilyFallback: AppFonts.uiFallback,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// Tap-driven carousel with prev/next halves and a slide counter, matching
/// the web `CarouselImage` interaction model.
class _CardCarousel extends StatefulWidget {
  final List<String> images;
  const _CardCarousel({required this.images});

  @override
  State<_CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends State<_CardCarousel> {
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final count = widget.images.length;
    final next = (_index + delta + count) % count;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final showSlideCount = images.length > 1;
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: images.length,
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surface2),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppColors.ink4),
                ),
              ),
            ),
            if (showSlideCount) ...[
              // Tap zones for prev / next.
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _go(-1),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _go(1),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_index + 1}/${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String handle;
  const _Avatar({required this.handle});

  @override
  Widget build(BuildContext context) {
    final letter = handle.isNotEmpty ? handle[0].toUpperCase() : '?';
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8D5BC), Color(0xFFC19064)],
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: AppFonts.display,
          fontFamilyFallback: AppFonts.displayFallback,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ActionButtons extends GetView<DiscoverController> {
  final DiscoverPostModel post;
  const _ActionButtons({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundButton(
          icon: Icons.close,
          background: AppColors.white,
          iconColor: AppColors.ink2,
          border: const BorderSide(color: AppColors.line, width: 1.5),
          tooltip: 'Skip',
          onTap: () => controller.skip(post),
        ),
        const SizedBox(width: 20),
        _RoundButton(
          icon: Icons.favorite,
          background: AppColors.accent,
          iconColor: Colors.white,
          tooltip: 'Shortlist',
          onTap: () => controller.shortlist(post),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final BorderSide? border;
  final String tooltip;
  final VoidCallback onTap;
  const _RoundButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    this.border,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: CircleBorder(
          side: border ?? BorderSide.none,
        ),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(icon, size: 24, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final int? totalInView;
  final int shortlistCount;
  const _Progress({required this.totalInView, required this.shortlistCount});

  @override
  Widget build(BuildContext context) {
    final total = totalInView ?? 0;
    return Column(
      children: [
        Text(
          total > 0 ? '$total in this view' : 'No more in this view',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 11,
            letterSpacing: 0.4,
            color: AppColors.ink3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite,
                    size: 18, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$shortlistCount',
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontFamilyFallback: AppFonts.displayFallback,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'shortlisted',
                    style: TextStyle(
                      fontFamily: AppFonts.ui,
                      fontFamilyFallback: AppFonts.uiFallback,
                      fontSize: 11.5,
                      color: AppColors.ink3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UndoButton extends StatelessWidget {
  final DiscoverPostModel? lastSkipped;
  final VoidCallback onTap;
  const _UndoButton({required this.lastSkipped, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            const Icon(Icons.refresh, size: 14, color: AppColors.ink2),
            const SizedBox(width: 8),
            Text(
              'Undo last skip',
              style: TextStyle(
                fontFamily: AppFonts.ui,
                fontFamilyFallback: AppFonts.uiFallback,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.ink2,
              ),
            ),
            if (lastSkipped != null) ...[
              const Spacer(),
              Flexible(
                child: Text(
                  '@${lastSkipped!.authorHandle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 10.5,
                    color: AppColors.ink4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HowToSwipe extends StatelessWidget {
  const _HowToSwipe();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW TO SWIPE',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 10.5,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w500,
              color: AppColors.ink4,
            ),
          ),
          const SizedBox(height: 12),
          _HowToRow(
            icon: Icons.close,
            iconColor: AppColors.ink2,
            iconBg: AppColors.surface,
            bold: 'Tap X',
            rest: ' to skip — not your vibe.',
          ),
          const SizedBox(height: 10),
          _HowToRow(
            icon: Icons.favorite,
            iconColor: AppColors.accent,
            iconBg: AppColors.accentSoft,
            bold: 'Tap heart',
            rest: ' to add to your shortlist.',
          ),
          const SizedBox(height: 10),
          _HowToRow(
            icon: Icons.visibility_outlined,
            iconColor: AppColors.ink2,
            iconBg: AppColors.surface,
            bold: 'View full post',
            rest: ' for the whole caption.',
          ),
        ],
      ),
    );
  }
}

class _HowToRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String bold;
  final String rest;
  const _HowToRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.bold,
    required this.rest,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: bold,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                TextSpan(text: rest),
              ],
            ),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.ink2,
            ),
          ),
        ),
      ],
    );
  }
}

class _AllSeen extends GetView<DiscoverController> {
  final bool canUndo;
  const _AllSeen({required this.canUndo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 64),
      child: Column(
        children: [
          Text(
            "You've seen all the posts",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.4,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adjust the format filter or check back later — fresh inspiration drops daily.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.ink3,
            ),
          ),
          if (canUndo) ...[
            const SizedBox(height: 16),
            _UndoButton(
              lastSkipped: controller.skippedHistory.last,
              onTap: controller.undoLastSkip,
            ),
          ],
        ],
      ),
    );
  }
}
