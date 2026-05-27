import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common_widgets/app_snackbar.dart';
import '../../../controllers/calendar_controller/calendar_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/scheduled_post_model.dart';
import 'scheduled_status_badge.dart';

/// Detail sheet for a scheduled post — the mobile analogue of the web
/// `PostDetailPanel` `pool === 'scheduled'` branch.
///
///   - Thumbnail, status badge, scheduled-at header, metadata (slides + status).
///   - Inline caption edit (pencil → textarea + Save/Cancel + char counter,
///     max 2200) only while `status == scheduled`, submitting a PATCH.
///   - Footer: "Cancel schedule" (DELETE, only while scheduled, confirm dialog)
///     and "View on Instagram" (open permalink, only while published).
class ScheduledDetailSheet extends StatefulWidget {
  final ScheduledPostModel post;
  final CalendarController controller;

  const ScheduledDetailSheet({
    super.key,
    required this.post,
    required this.controller,
  });

  static const int captionMax = 2200;

  static Future<void> show(
    BuildContext context, {
    required ScheduledPostModel post,
    required CalendarController controller,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ScheduledDetailSheet(post: post, controller: controller),
    );
  }

  @override
  State<ScheduledDetailSheet> createState() => _ScheduledDetailSheetState();
}

class _ScheduledDetailSheetState extends State<ScheduledDetailSheet> {
  late final TextEditingController _captionCtrl;
  bool _editing = false;
  bool _saving = false;
  bool _cancelling = false;

  // The post is mutated in place via the controller list; we keep a local
  // reference so the sheet reflects edits made here without a refetch.
  late ScheduledPostModel _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _captionCtrl = TextEditingController(text: _post.caption);
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  bool get _canEditCaption => _post.status == ScheduledPostStatus.scheduled;

  String _formatScheduledAt() {
    final d = _post.scheduledAt.toLocal();
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour < 12 ? 'AM' : 'PM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, '
        '$hour:$minute $period';
  }

  void _startEdit() {
    setState(() {
      _captionCtrl.text = _post.caption;
      _editing = true;
    });
  }

  void _cancelEdit() => setState(() => _editing = false);

  Future<void> _saveCaption() async {
    if (_saving) return;
    setState(() => _saving = true);
    final ok = await widget.controller
        .updateCaption(_post.scheduledPostId, _captionCtrl.text);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) {
        _post = _post.copyWith(caption: _captionCtrl.text);
        _editing = false;
      }
    });
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this scheduled post?'),
        content: const Text(
          "It won't publish to Instagram. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep scheduled'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel post'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    final ok = await widget.controller.cancel(_post.scheduledPostId);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _cancelling = false);
    }
  }

  Future<void> _openInstagram() async {
    final link = _post.permalink;
    if (link == null || link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      AppSnackbar.error(
        "Couldn't open Instagram",
        'No app was able to handle this link.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _header(),
                const SizedBox(height: 14),
                _image(),
                const SizedBox(height: 16),
                _captionBlock(),
                const SizedBox(height: 16),
                _metadata(),
              ],
            ),
          ),
          _actionBar(),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SCHEDULED POST',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontFamilyFallback: AppFonts.monoFallback,
                fontSize: 10,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w500,
                color: AppColors.ink4,
              ),
            ),
            const SizedBox(width: 8),
            ScheduledStatusBadge(status: _post.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _formatScheduledAt(),
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _image() {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: (_post.thumbnailUrl != null && _post.thumbnailUrl!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: _post.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surface2),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.ink4,
                  ),
                ),
              )
            : Container(color: AppColors.surface2),
      ),
    );
  }

  Widget _captionBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            if (_canEditCaption && !_editing)
              TextButton.icon(
                onPressed: _startEdit,
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.ink2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (_editing) _captionEditor() else _captionText(),
      ],
    );
  }

  Widget _captionText() {
    final caption = _post.caption;
    return Text(
      caption.isEmpty
          ? 'No caption yet — add one before this post publishes.'
          : caption,
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: caption.isEmpty ? AppColors.ink4 : AppColors.ink2,
      ),
    );
  }

  Widget _captionEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _captionCtrl,
          enabled: !_saving,
          maxLines: 6,
          minLines: 4,
          maxLength: ScheduledDetailSheet.captionMax,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(),
            counterText: '',
          ),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_captionCtrl.text.length} / ${ScheduledDetailSheet.captionMax}',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontFamilyFallback: AppFonts.monoFallback,
                fontSize: 11,
                color: AppColors.ink4,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _saving ? null : _cancelEdit,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saving ? null : _saveCaption,
                  child: Text(_saving ? 'Saving…' : 'Save caption'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _metadata() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.line2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _metaRow('Slides',
              '${_post.slideCount} slide${_post.slideCount == 1 ? '' : 's'}'),
          const SizedBox(height: 6),
          _metaRow('Status', _statusLabel(_post.status)),
          if (_post.status == ScheduledPostStatus.failed &&
              (_post.errorMessage?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 6),
            _metaRow('Error', _post.errorMessage!),
          ],
        ],
      ),
    );
  }

  static String _statusLabel(ScheduledPostStatus status) {
    switch (status) {
      case ScheduledPostStatus.scheduled:
        return 'Scheduled';
      case ScheduledPostStatus.publishing:
        return 'Publishing';
      case ScheduledPostStatus.published:
        return 'Published';
      case ScheduledPostStatus.failed:
        return 'Failed';
    }
  }

  Widget _metaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.5, color: AppColors.ink3),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionBar() {
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
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _primaryAction()),
          ],
        ),
      ),
    );
  }

  Widget _primaryAction() {
    if (_post.status == ScheduledPostStatus.scheduled) {
      return OutlinedButton.icon(
        icon: _cancelling
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.close, size: 16),
        label: Text(_cancelling ? 'Cancelling…' : 'Cancel schedule'),
        onPressed: _cancelling ? null : _confirmCancel,
      );
    }
    if (_post.status == ScheduledPostStatus.published &&
        (_post.permalink?.isNotEmpty ?? false)) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.open_in_new, size: 16),
        label: const Text('View on Instagram'),
        onPressed: _openInstagram,
      );
    }
    // publishing / failed / published-without-permalink: informational only.
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          _post.status == ScheduledPostStatus.publishing
              ? 'Publishing to Instagram…'
              : _post.status == ScheduledPostStatus.failed
                  ? (_post.errorMessage?.isNotEmpty ?? false
                      ? _post.errorMessage!
                      : 'Publishing failed.')
                  : 'Published to Instagram.',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.5, color: AppColors.ink3),
        ),
      ),
    );
  }
}
