import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/app_snackbar.dart';
import '../../../controllers/drafts_controller/drafts_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/draft_model.dart';
import '../../../data/models/generation_job_model.dart';

/// Tap-to-watch on a draft card opens this sheet. Loads the full
/// generation job (slides + caption), shows the slide carousel, and offers
/// "Post to Instagram" as the primary CTA.
class PostDetailSheet extends StatefulWidget {
  final DraftModel draft;
  final DraftsController controller;

  const PostDetailSheet({
    super.key,
    required this.draft,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required DraftModel draft,
    required DraftsController controller,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // Keep the sheet (drag handle + title) below the status bar / notch so
      // the title is never tucked under it at tall drag sizes.
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          PostDetailSheet(draft: draft, controller: controller),
    );
  }

  @override
  State<PostDetailSheet> createState() => _PostDetailSheetState();
}

class _PostDetailSheetState extends State<PostDetailSheet> {
  GenerationJobModel? _job;
  bool _loadingJob = true;
  bool _posting = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final job = await widget.controller.loadJob(widget.draft.jobId);
    if (!mounted) return;
    setState(() {
      _job = job;
      _loadingJob = false;
    });
  }

  Future<void> _post() async {
    if (_posting) return;
    setState(() => _posting = true);
    final result =
        await widget.controller.postToInstagram(widget.draft.jobId);
    if (!mounted) return;
    setState(() => _posting = false);
    if (result != null) {
      Navigator.of(context).pop();
      // Failure snackbar is handled in the controller; confirm success here.
      AppSnackbar.success('Posted to Instagram', 'Your carousel is now live.');
    }
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    // Controller saves each slide to the gallery and owns the result
    // snackbars (saved / permission / failure).
    await widget.controller.downloadSlides(
      widget.draft.jobId,
      slides: _job?.slides,
    );
    if (!mounted) return;
    setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.55,
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
                _Header(draft: widget.draft),
                const SizedBox(height: 14),
                _SlideArea(loading: _loadingJob, job: _job),
                const SizedBox(height: 16),
                if (_job?.slides.isNotEmpty ?? false) _CaptionBlock(job: _job!),
              ],
            ),
          ),
          _ActionBar(
            posting: _posting,
            downloading: _downloading,
            enabled: _job?.status == GenerationJobStatus.completed,
            slideCount: _job?.slides.length ?? widget.draft.slideCount,
            connected: widget.controller.isInstagramConnected,
            onPost: _post,
            onDownload: _download,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final DraftModel draft;
  const _Header({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          draft.captionPreview,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: -0.3,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'From @${draft.sourceAuthorHandle} · ${draft.generatedAgoLabel}',
          style: TextStyle(fontSize: 12, color: AppColors.ink3),
        ),
      ],
    );
  }
}

class _SlideArea extends StatefulWidget {
  final bool loading;
  final GenerationJobModel? job;
  const _SlideArea({required this.loading, required this.job});

  @override
  State<_SlideArea> createState() => _SlideAreaState();
}

class _SlideAreaState extends State<_SlideArea> {
  final PageController _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const AspectRatio(
        aspectRatio: 4 / 5,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final slides = widget.job?.slides ?? const <GenerationSlideModel>[];
    if (slides.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 5,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            "Couldn't load slides.",
            style: TextStyle(color: AppColors.ink3, fontSize: 13),
          ),
        ),
      );
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: PageView.builder(
            controller: _page,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: slides.length,
            itemBuilder: (_, i) => _SlideCard(slide: slides[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(slides.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 22 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.line,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SlideCard extends StatelessWidget {
  final GenerationSlideModel slide;
  const _SlideCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        // The generated slide image already has its text rendered into it,
        // so we show the image alone — no duplicate text overlay.
        child: CachedNetworkImage(
          imageUrl: slide.imageUrl,
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
        ),
      ),
    );
  }
}

class _CaptionBlock extends StatelessWidget {
  final GenerationJobModel job;
  const _CaptionBlock({required this.job});

  @override
  Widget build(BuildContext context) {
    final caption = job.slides.isNotEmpty ? job.slides.first.caption : '';
    if (caption.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 6),
          Text(
            caption,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.ink2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool posting;
  final bool downloading;
  final bool enabled;
  final int slideCount;
  final RxBool connected;
  final VoidCallback onPost;
  final VoidCallback onDownload;

  const _ActionBar({
    required this.posting,
    required this.downloading,
    required this.enabled,
    required this.slideCount,
    required this.connected,
    required this.onPost,
    required this.onDownload,
  });

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
        child: Obx(() {
          final isConnected = connected.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isConnected) ...[
                Text(
                  'Connect Instagram to post directly.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.ink3),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isConnected
                        ? _primaryButton(
                            busy: posting,
                            icon: Icons.send,
                            label: posting ? 'Posting…' : 'Post to Instagram',
                            onPressed:
                                (posting || !enabled) ? null : onPost,
                          )
                        : _primaryButton(
                            busy: downloading,
                            icon: Icons.download,
                            label: downloading
                                ? 'Saving…'
                                : slideCount > 1
                                    ? 'Download images'
                                    : 'Download image',
                            onPressed:
                                (downloading || !enabled) ? null : onDownload,
                          ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _primaryButton({
    required bool busy,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      icon: busy
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : Icon(icon, size: 16),
      label: Text(label, overflow: TextOverflow.ellipsis),
      onPressed: onPressed,
    );
  }
}
