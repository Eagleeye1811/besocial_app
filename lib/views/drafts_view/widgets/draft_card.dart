import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/drafts_controller/drafts_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/draft_model.dart';
import 'post_detail_sheet.dart';

/// One row in the drafts list. Square thumbnail on the left, caption +
/// source attribution + meta on the right.
class DraftCard extends StatelessWidget {
  final DraftModel draft;
  const DraftCard({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DraftsController>();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => PostDetailSheet.show(
        context,
        draft: draft,
        controller: controller,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _thumbnail(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.captionPreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.ui,
                      fontFamilyFallback: AppFonts.uiFallback,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'From @${draft.sourceAuthorHandle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.ink3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MetaPill(
                        icon: Icons.layers_outlined,
                        text:
                            '${draft.slideCount} slide${draft.slideCount == 1 ? '' : 's'}',
                      ),
                      const SizedBox(width: 6),
                      _MetaPill(
                        icon: Icons.schedule,
                        text: draft.generatedAgoLabel,
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

  Widget _thumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 88,
        height: 110,
        child: CachedNetworkImage(
          imageUrl: draft.thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.surface2),
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
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.ink3),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink2,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
