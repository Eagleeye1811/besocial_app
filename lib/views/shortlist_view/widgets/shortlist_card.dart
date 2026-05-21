import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/shortlist_controller/shortlist_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/shortlist_item_model.dart';
import 'mode2_config_sheet.dart';

/// One row in the shortlist. Thumbnail on the left, content + status pill
/// in the middle, action menu on the right. Tap "Configure" to open the
/// Mode 2 sheet, "Generate" to kick a new job.
class ShortlistCard extends StatelessWidget {
  final ShortlistItemModel item;
  const ShortlistCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortlistController>();

    return Container(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '@${item.authorHandle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.ui,
                          fontFamilyFallback: AppFonts.uiFallback,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    _ActionMenu(item: item),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.ink2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatusPill(status: item.generationStatus),
                    const SizedBox(width: 8),
                    Text(
                      '${item.slideCount} slide${item.slideCount == 1 ? '' : 's'} · ${item.format}',
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontFamilyFallback: AppFonts.monoFallback,
                        fontSize: 10.5,
                        color: AppColors.ink4,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Mode2ConfigSheet.show(
                          context,
                          postId: item.postId,
                          controller: controller,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Configure'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: _generateIcon(),
                        label: Text(_generateLabel()),
                        onPressed: _isBusy()
                            ? null
                            : () => controller.generate(item),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 76,
        height: 96,
        child: item.thumbnailUrl == null
            ? Container(
                color: AppColors.surface2,
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, color: AppColors.ink4),
              )
            : CachedNetworkImage(
                imageUrl: item.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surface2),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: AppColors.ink4),
                ),
              ),
      ),
    );
  }

  Widget _generateIcon() {
    if (item.generationStatus == ShortlistGenerationStatus.generating) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.white,
        ),
      );
    }
    return const Icon(Icons.auto_awesome, size: 14);
  }

  String _generateLabel() {
    switch (item.generationStatus) {
      case ShortlistGenerationStatus.ready:
        return 'Generate';
      case ShortlistGenerationStatus.generating:
        return 'Generating…';
      case ShortlistGenerationStatus.generated:
        return 'Regenerate';
      case ShortlistGenerationStatus.failed:
        return 'Retry';
    }
  }

  bool _isBusy() =>
      item.generationStatus == ShortlistGenerationStatus.generating;
}

class _StatusPill extends StatelessWidget {
  final ShortlistGenerationStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      ShortlistGenerationStatus.ready => (
          AppColors.surface2,
          AppColors.ink2,
          'Ready'
        ),
      ShortlistGenerationStatus.generating => (
          AppColors.accentSoft,
          AppColors.accentInk,
          'Generating'
        ),
      ShortlistGenerationStatus.generated => (
          const Color(0xFFE5F4EA),
          AppColors.good,
          'Generated'
        ),
      ShortlistGenerationStatus.failed => (
          const Color(0xFFFDE8E8),
          const Color(0xFFB91C1C),
          'Failed'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final ShortlistItemModel item;
  const _ActionMenu({required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortlistController>();
    return PopupMenuButton<_CardAction>(
      icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.ink3),
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case _CardAction.configure:
            Mode2ConfigSheet.show(
              context,
              postId: item.postId,
              controller: controller,
            );
          case _CardAction.remove:
            controller.remove(item);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
            value: _CardAction.configure, child: Text('Configure style')),
        PopupMenuItem(
            value: _CardAction.remove, child: Text('Remove from shortlist')),
      ],
    );
  }
}

enum _CardAction { configure, remove }
