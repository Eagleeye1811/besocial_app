import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/discover_post_model.dart';

/// Bottom sheet shown when a discover card is tapped. Carousel of all
/// images, full caption, format/slide pills, and the Shortlist / Skip
/// actions. Closes via either CTA — the swipe call removes the post from
/// the grid optimistically.
class DiscoverDetailSheet extends StatelessWidget {
  final DiscoverPostModel post;
  const DiscoverDetailSheet({super.key, required this.post});

  static Future<void> show(BuildContext context,
      {required DiscoverPostModel post}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DiscoverDetailSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiscoverController>();
    final images = post.images.isEmpty ? [post.thumbnailUrl] : post.images;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                _Header(post: post),
                const SizedBox(height: 12),
                _Carousel(images: images),
                const SizedBox(height: 16),
                _EngagementStrip(post: post, slideFallback: images.length),
                const SizedBox(height: 12),
                _InstagramButton(shortcode: post.shortcode),
                const SizedBox(height: 16),
                if (post.caption.isNotEmpty) ...[
                  Text(
                    'CAPTION',
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontFamilyFallback: AppFonts.monoFallback,
                      fontSize: 10,
                      letterSpacing: 0.4,
                      color: AppColors.ink4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.caption,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.ink2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _ActionBar(post: post, controller: controller),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final DiscoverPostModel post;
  const _Header({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${post.authorHandle}',
                style: TextStyle(
                  fontFamily: AppFonts.ui,
                  fontFamilyFallback: AppFonts.uiFallback,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                post.postedAgoLabel,
                style: TextStyle(fontSize: 12, color: AppColors.ink3),
              ),
            ],
          ),
        ),
        _MetaPill(label: post.format.toUpperCase()),
        if (post.slideCount > 1) ...[
          const SizedBox(width: 6),
          _MetaPill(label: '${post.slideCount} slides'),
        ],
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.ink2,
        ),
      ),
    );
  }
}

/// Likes / comments / slides metrics row. Mirrors the web detail modal's
/// engagement strip (the hardcoded "match score" cell is omitted — there is
/// no backend signal for it on mobile).
class _EngagementStrip extends StatelessWidget {
  final DiscoverPostModel post;
  final int slideFallback;
  const _EngagementStrip({required this.post, required this.slideFallback});

  @override
  Widget build(BuildContext context) {
    final slides = post.slideCount > 0 ? post.slideCount : slideFallback;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Metric(value: _formatNumber(post.likeCount), label: 'likes'),
          _divider(),
          _Metric(value: _formatNumber(post.commentCount), label: 'comments'),
          _divider(),
          _Metric(value: '$slides', label: slides == 1 ? 'slide' : 'slides'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: AppColors.line2,
      );

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

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  const _Metric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.ui,
            fontFamilyFallback: AppFonts.uiFallback,
            fontSize: 11,
            color: AppColors.ink3,
          ),
        ),
      ],
    );
  }
}

/// "View on Instagram" — opens https://www.instagram.com/p/{shortcode}/ in
/// the external browser / IG app. Hidden when no shortcode is present.
class _InstagramButton extends StatelessWidget {
  final String shortcode;
  const _InstagramButton({required this.shortcode});

  Future<void> _open() async {
    if (shortcode.isEmpty) return;
    final uri = Uri.parse('https://www.instagram.com/p/$shortcode/');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        Get.snackbar(
          "Couldn't open Instagram",
          'No app was able to handle this link.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        "Couldn't open Instagram",
        'No app was able to handle this link.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (shortcode.isEmpty) return const SizedBox.shrink();
    return OutlinedButton.icon(
      onPressed: _open,
      icon: const Icon(Icons.camera_alt_outlined, size: 16),
      label: const Text('View on Instagram'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink2,
        side: const BorderSide(color: AppColors.line),
        backgroundColor: AppColors.surface,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  final List<String> images;
  const _Carousel({required this.images});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (_, i) => CachedNetworkImage(
            imageUrl: images[i],
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.surface2),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.surface2,
              alignment: Alignment.center,
              child:
                  const Icon(Icons.broken_image_outlined, color: AppColors.ink4),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final DiscoverPostModel post;
  final DiscoverController controller;
  const _ActionBar({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Skip'),
                onPressed: () async {
                  await controller.skip(post);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.favorite, size: 16),
                label: const Text('Shortlist'),
                onPressed: () async {
                  await controller.shortlist(post);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
