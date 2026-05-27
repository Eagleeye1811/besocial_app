import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';
import '../../../data/models/scheduled_post_model.dart';
import 'scheduled_status_badge.dart';

/// Card for a scheduled post inside a calendar day slot. Mirrors the web
/// `ScheduledPostCard`: thumbnail + publish time + status badge + caption
/// preview + slide count. Tapping opens the detail sheet (wired by the slot).
class ScheduledPostCard extends StatelessWidget {
  final ScheduledPostModel post;
  final VoidCallback onTap;

  const ScheduledPostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  String get _time {
    final d = post.scheduledAt.toLocal();
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour < 12 ? 'AM' : 'PM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _thumbnail(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        _time,
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontFamilyFallback: AppFonts.monoFallback,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ScheduledStatusBadge(status: post.status),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    post.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.3,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${post.slideCount} slide${post.slideCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: AppColors.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 52,
        height: 52,
        child: (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: post.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surface2),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    size: 18,
                    color: AppColors.ink4,
                  ),
                ),
              )
            : Container(color: AppColors.surface2),
      ),
    );
  }
}
