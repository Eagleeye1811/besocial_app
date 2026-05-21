import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
