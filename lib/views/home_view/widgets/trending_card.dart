import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';
import '../../../data/dto/dashboard_trending_dto.dart';

/// One card in the "Trending in your niche" horizontal carousel. Mirrors the
/// web `TrendingCard`: thumbnail with a format badge and an overlay heart that
/// toggles the post into the shortlist.
class TrendingCard extends StatelessWidget {
  final DashboardTrendingPostDto post;

  /// Whether this post is currently shortlisted (drives the filled heart).
  final bool shortlisted;

  /// Fired when the heart is tapped. Null leaves the card read-only.
  final VoidCallback? onShortlist;

  const TrendingCard({
    super.key,
    required this.post,
    this.shortlisted = false,
    this.onShortlist,
  });

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
                  if (onShortlist != null)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: _HeartButton(
                        shortlisted: shortlisted,
                        onTap: onShortlist!,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.favorite_outline,
                          size: 12, color: AppColors.ink3),
                      const SizedBox(width: 4),
                      Text(
                        '${_compactNumber(post.likeCount)} likes',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.ink3,
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

  // Thousands-separated, matching the web's `formatNumber(like_count)`.
  static String _compactNumber(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return (n < 0 ? '-' : '') + buf.toString();
  }
}

/// Round overlay heart. Filled accent when shortlisted, translucent white
/// outline otherwise — mirrors the web card's top-right shortlist button.
class _HeartButton extends StatelessWidget {
  final bool shortlisted;
  final VoidCallback onTap;
  const _HeartButton({required this.shortlisted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: shortlisted
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(
            color: shortlisted ? AppColors.accent : AppColors.line,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          shortlisted ? Icons.favorite : Icons.favorite_border,
          size: 15,
          color: shortlisted ? Colors.white : AppColors.ink2,
        ),
      ),
    );
  }
}
