import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
      // Snackbar handled in controller for the failure path; surface a
      // confirmation here for success since we know the result shape.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posted to Instagram.')),
      );
    }
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
            enabled: _job?.status == GenerationJobStatus.completed,
            onPost: _post,
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
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
            if (slide.slideText.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    slide.slideText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
          ],
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
  final bool enabled;
  final VoidCallback onPost;

  const _ActionBar({
    required this.posting,
    required this.enabled,
    required this.onPost,
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: posting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: 16),
                label: Text(posting ? 'Posting…' : 'Post to Instagram'),
                onPressed: (posting || !enabled) ? null : onPost,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
