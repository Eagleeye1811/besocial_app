import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/discover_post_model.dart';

/// Detail modal for a single Discover post — the mobile counterpart of the
/// web `DiscoverDetailModal`. Carousel (arrows · dots · counter), author row
/// with a "View on Instagram" link, an engagement strip (likes · comments ·
/// slides · match score), the full caption, and a shortlist-toggle CTA.
class DiscoverDetailSheet extends StatelessWidget {
  final DiscoverPostModel post;
  const DiscoverDetailSheet({super.key, required this.post});

  static Future<void> show(BuildContext context,
      {required DiscoverPostModel post}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DiscoverDetailSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiscoverController>();
    final images = post.images.isEmpty ? <String>[post.thumbnailUrl] : post.images;
    final slides = post.slideCount > 0 ? post.slideCount : images.length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                _Carousel(images: images),
                const SizedBox(height: 16),
                _AuthorRow(post: post),
                const SizedBox(height: 14),
                _EngagementStrip(post: post, slides: slides),
                if (post.caption.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    post.caption,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: AppColors.ink2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _CtaBar(post: post, controller: controller),
        ],
      ),
    );
  }
}

/// Carousel with prev/next arrows, a slide counter, and dot indicators —
/// mirrors the web `CarouselImage` (clamps at the boundaries).
class _Carousel extends StatefulWidget {
  final List<String> images;
  const _Carousel({required this.images});

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  late final PageController _page = PageController();
  int _index = 0;

  int get _count => widget.images.length;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _goPrev() {
    if (_index <= 0) return;
    _page.animateToPage(_index - 1,
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  void _goNext() {
    if (_index >= _count - 1) return;
    _page.animateToPage(_index + 1,
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            PageView.builder(
              controller: _page,
              itemCount: _count,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: widget.images[i],
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
            if (_count > 1) ...[
              // Slide counter.
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xC71C1B19),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_index + 1} / $_count',
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontFamilyFallback: AppFonts.monoFallback,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(child: _Arrow(icon: Icons.arrow_back, onTap: _goPrev)),
              ),
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                    child: _Arrow(icon: Icons.arrow_forward, onTap: _goNext)),
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(child: _Dots(count: _count, index: _index)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Arrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 16, color: AppColors.ink),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x8C1C1B19),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i == count - 1 ? 0 : 5),
              width: i == index ? 14 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: i == index ? Colors.white : Colors.white54,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  final DiscoverPostModel post;
  const _AuthorRow({required this.post});

  @override
  Widget build(BuildContext context) {
    final initial = post.authorHandle.isNotEmpty
        ? post.authorHandle.substring(0, 1).toUpperCase()
        : '?';
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5E5E2), Color(0xFFB07F76)],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
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
              if (post.postedAgoLabel.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  post.postedAgoLabel,
                  style: TextStyle(fontSize: 12, color: AppColors.ink3),
                ),
              ],
            ],
          ),
        ),
        if (post.shortcode.isNotEmpty) _InstagramLink(shortcode: post.shortcode),
      ],
    );
  }
}

class _InstagramLink extends StatelessWidget {
  final String shortcode;
  const _InstagramLink({required this.shortcode});

  Future<void> _open() async {
    final uri = Uri.parse('https://www.instagram.com/p/$shortcode/');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        Get.snackbar("Couldn't open Instagram",
            'No app was able to handle this link.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar("Couldn't open Instagram",
          'No app was able to handle this link.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 13, color: AppColors.ink2),
            const SizedBox(width: 5),
            Text(
              'View on Instagram',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.arrow_forward, size: 11, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}

class _EngagementStrip extends StatelessWidget {
  final DiscoverPostModel post;
  final int slides;
  const _EngagementStrip({required this.post, required this.slides});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _metric(_formatNumber(post.likeCount), 'likes'),
          _divider(),
          _metric(_formatNumber(post.commentCount), 'comments'),
          _divider(),
          _metric('$slides', 'slides'),
          _divider(),
          // Match score is a fidelity placeholder on the web too (no backend
          // signal yet) — rendered to match the modal layout exactly.
          _matchScore(),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        color: AppColors.line2,
      );

  Widget _metric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: -0.3,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.ink3)),
      ],
    );
  }

  Widget _matchScore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1,
              letterSpacing: -0.3,
              color: AppColors.ink,
            ),
            children: [
              const TextSpan(text: '92'),
              TextSpan(
                text: '/100',
                style: TextStyle(fontSize: 12, color: AppColors.ink3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('match score', style: TextStyle(fontSize: 11, color: AppColors.ink3)),
      ],
    );
  }

  static String _formatNumber(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return (n < 0 ? '-' : '') + buf.toString();
  }
}

/// Pinned shortlist-toggle CTA. Accent "Add to shortlist" when not yet
/// shortlisted; dark "In your shortlist" with a check once it is. Toggling
/// closes the sheet (matching the web modal).
class _CtaBar extends StatelessWidget {
  final DiscoverPostModel post;
  final DiscoverController controller;
  const _CtaBar({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final on = controller.isShortlisted(post.postId);
          return SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(on ? Icons.check : Icons.favorite, size: 18),
              label: Text(on ? 'In your shortlist' : 'Add to shortlist'),
              style: ElevatedButton.styleFrom(
                backgroundColor: on ? AppColors.ink : AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                controller.toggleShortlist(post);
                Navigator.of(context).pop();
              },
            ),
          );
        }),
      ),
    );
  }
}
