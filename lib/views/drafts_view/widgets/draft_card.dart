import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/app_snackbar.dart';
import '../../../controllers/drafts_controller/drafts_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/draft_model.dart';
import 'post_detail_sheet.dart';

/// One row in the drafts list. Square thumbnail on the left, caption +
/// source attribution + meta on the right, and an Instagram-aware primary
/// action (Post to Instagram when connected, Download otherwise).
class DraftCard extends StatefulWidget {
  final DraftModel draft;
  const DraftCard({super.key, required this.draft});

  @override
  State<DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<DraftCard> {
  final DraftsController _controller = Get.find<DraftsController>();
  bool _busy = false;

  DraftModel get draft => widget.draft;

  void _openSheet() {
    PostDetailSheet.show(
      context,
      draft: draft,
      controller: _controller,
    );
  }

  Future<void> _post() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await _controller.postToInstagram(draft.jobId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result != null) {
      AppSnackbar.success('Posted to Instagram', 'Your carousel is now live.');
    }
  }

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    // The list payload doesn't carry slide URLs, so the controller fetches
    // the job before saving each image to the gallery. It owns the result
    // snackbars (saved / permission / failure).
    await _controller.downloadSlides(draft.jobId);
    if (!mounted) return;
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _openSheet,
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
                  const SizedBox(height: 10),
                  _action(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action() {
    return Obx(() {
      final connected = _controller.isInstagramConnected.value;
      final label = _busy
          ? (connected ? 'Posting…' : 'Saving…')
          : connected
              ? 'Post to Instagram'
              : draft.slideCount > 1
                  ? 'Download images'
                  : 'Download image';
      return SizedBox(
        height: 34,
        child: connected
            ? ElevatedButton.icon(
                icon: _icon(Icons.send),
                label: Text(label, style: const TextStyle(fontSize: 12.5)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _busy ? null : _post,
              )
            : OutlinedButton.icon(
                icon: _icon(Icons.download),
                label: Text(label, style: const TextStyle(fontSize: 12.5)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _busy ? null : _download,
              ),
      );
    });
  }

  Widget _icon(IconData icon) {
    if (_busy) {
      return const SizedBox(
        width: 13,
        height: 13,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Icon(icon, size: 14);
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
