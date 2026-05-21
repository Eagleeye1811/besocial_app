import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/discover_post_model.dart';
import 'discover_detail_sheet.dart';

/// Two-column grid of discover posts. Tapping a card opens the detail
/// sheet; the heart button shortlists inline.
class DiscoverGrid extends GetView<DiscoverController> {
  const DiscoverGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.pager.items;
      final isLoading = controller.pager.isLoading.value;

      if (items.isEmpty && isLoading) {
        return const SizedBox(
          height: 240,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (items.isEmpty) {
        return _Empty(onRetry: controller.pager.loadFirst);
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (note) {
          if (note.metrics.pixels >= note.metrics.maxScrollExtent - 240) {
            controller.pager.loadMore();
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: items.length + (controller.pager.hasMore ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= items.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return _DiscoverCard(post: items[i]);
          },
        ),
      );
    });
  }
}

class _DiscoverCard extends StatelessWidget {
  final DiscoverPostModel post;
  const _DiscoverCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => DiscoverDetailSheet.show(context, post: post),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
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
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post.format.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
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
                        fontSize: 11,
                        color: AppColors.ink3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.favorite_outline,
                            size: 12, color: AppColors.ink3),
                        const SizedBox(width: 4),
                        Text(
                          _compactNumber(post.likeCount),
                          style:
                              TextStyle(fontSize: 11, color: AppColors.ink3),
                        ),
                        const Spacer(),
                        _HeartButton(post: post),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _compactNumber(int n) {
    if (n < 1000) return '$n';
    if (n < 10000) return '${(n / 1000).toStringAsFixed(1)}k';
    if (n < 1000000) return '${(n / 1000).round()}k';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }
}

class _HeartButton extends GetView<DiscoverController> {
  final DiscoverPostModel post;
  const _HeartButton({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.shortlist(post),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Icon(
          Icons.favorite,
          size: 14,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onRetry;
  const _Empty({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 36, color: AppColors.ink4),
          const SizedBox(height: 12),
          Text(
            'No posts to show yet.',
            style: TextStyle(fontSize: 14, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
