import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';
import '../../../data/dto/dashboard_recent_post_dto.dart';

/// One card in the "Your recent posts" horizontal carousel.
class RecentPostCard extends StatelessWidget {
  final DashboardRecentPostDto post;
  const RecentPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
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
            AspectRatio(
              aspectRatio: 1,
              child: post.thumbnailUrl == null
                  ? Container(
                      color: AppColors.surface2,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.ink4,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: post.thumbnailUrl!,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.captionPreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.ink2,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.favorite_outline,
                          size: 12, color: AppColors.ink3),
                      const SizedBox(width: 4),
                      Text(
                        _compactNumber(post.likeCount),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.ink3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        post.publishedAgoLabel,
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontFamilyFallback: AppFonts.monoFallback,
                          fontSize: 10,
                          color: AppColors.ink4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
