import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/app_snackbar.dart';
import '../../../controllers/instagram_controller/instagram_controller.dart';
import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/generation_job_model.dart';
import '../widgets/step_shell.dart';

/// JWT-gated tail, step B — mirrors `ResultStep.jsx`.
///
/// Shows the carousel slides from `currentJob`, with:
/// - Counter pill (top-right `n / total`)
/// - Carousel arrows (left/right, only when more than one slide)
/// - Bottom dot indicator (active dot widens)
/// - Caption box (mirrors web: always shows `slides[0].caption`)
/// - Three action buttons:
///     1. Generate another (ghost) → re-run /generation, back to /generating
///     2. Post to Instagram (primary) → IG status check → connect or notice
///     3. Skip for now — go to dashboard (text link) → /home
///
/// Mobile-specific:
/// - Buttons stack vertically (web has them inline) for phone width.
/// - Both swipe (PageView) AND arrow buttons are wired so users can use
///   either gesture.
class ResultStep extends StatefulWidget {
  const ResultStep({super.key});

  @override
  State<ResultStep> createState() => _ResultStepState();
}

class _ResultStepState extends State<ResultStep> {
  final OnboardingController _c = Get.find<OnboardingController>();
  final PageController _page = PageController();
  int _current = 0;
  bool _regenerating = false;
  bool _checkingInstagram = false;
  String? _localError;

  // Lazy-loaded — Phase 11 binding might not have put it yet on this route.
  InstagramController? _ig;

  @override
  void initState() {
    super.initState();
    _page.addListener(_onPageChanged);
    try {
      _ig = Get.find<InstagramController>();
    } catch (_) {
      _ig = Get.put<InstagramController>(InstagramController(), permanent: true);
    }
  }

  void _onPageChanged() {
    final next = _page.page?.round() ?? 0;
    if (next != _current && mounted) {
      setState(() => _current = next);
    }
  }

  @override
  void dispose() {
    _page.removeListener(_onPageChanged);
    _page.dispose();
    super.dispose();
  }

  void _goPrev(int count) {
    if (_current <= 0) return;
    _page.animateToPage(
      _current - 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goNext(int count) {
    if (_current >= count - 1) return;
    _page.animateToPage(
      _current + 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleRegenerate() async {
    if (_regenerating || _checkingInstagram) return;
    setState(() {
      _regenerating = true;
      _localError = null;
    });
    await _c.regenerateFromResult();
    if (!mounted) return;
    setState(() => _regenerating = false);
  }

  Future<void> _handlePostToInstagram() async {
    if (_regenerating || _checkingInstagram) return;
    final ig = _ig;
    if (ig == null) {
      setState(() => _localError =
          'Instagram is not available right now. Try again later.');
      return;
    }

    setState(() {
      _checkingInstagram = true;
      _localError = null;
    });

    // Force a fresh status read — the connection might have happened in
    // settings since this controller booted.
    await ig.refreshStatus();
    if (!mounted) return;

    if (ig.isConnected) {
      final handle = ig.connectedUsername;
      AppSnackbar.success(
        'Drafted to Instagram',
        handle != null
            ? 'Your post is queued for @$handle. Publish it from Drafts when you’re ready.'
            : 'Your post is queued. Publish it from Drafts when you’re ready.',
      );
      setState(() => _checkingInstagram = false);
      Get.offAllNamed<void>(AppRoutes.drafts);
      return;
    }

    // Not connected — open the OAuth WebView. The InstagramController
    // handles the success snackbar internally.
    await ig.startConnect();
    if (!mounted) return;
    setState(() => _checkingInstagram = false);

    if (ig.isConnected) {
      Get.offAllNamed<void>(AppRoutes.drafts);
    } else if (ig.errorMessage.value != null) {
      setState(() => _localError = ig.errorMessage.value);
    }
  }

  void _skipToDashboard() {
    if (_regenerating || _checkingInstagram) return;
    _c.skipResultToDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      body: Obx(() {
        final job = _c.currentJob.value;
        final slides = job?.slides ?? const <GenerationSlideModel>[];
        if (job == null || slides.isEmpty) {
          return const _EmptyState();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _ResultHeader(),
              const SizedBox(height: 20),
              _CarouselCard(
                slides: slides,
                pageController: _page,
                current: _current,
                onPrev: () => _goPrev(slides.length),
                onNext: () => _goNext(slides.length),
              ),
              const SizedBox(height: 14),
              _CaptionCard(caption: slides.first.caption),
              const SizedBox(height: 14),
              if (_localError != null) ...[
                _ErrorPanel(message: _localError!),
                const SizedBox(height: 12),
              ],
              _ActionBar(
                regenerating: _regenerating,
                postingChecking: _checkingInstagram,
                onRegenerate: _handleRegenerate,
                onPostToInstagram: _handlePostToInstagram,
                onSkip: _skipToDashboard,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      }),
    );
  }
}

// ============================================================================
// _ResultHeader — eyebrow + display headline (centered)
// ============================================================================

class _ResultHeader extends StatelessWidget {
  const _ResultHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'FIRST POST',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 11,
            letterSpacing: 0.8,
            color: AppColors.ink4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We made this for you',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// _CarouselCard — image PageView with arrows, counter pill, dot indicator
// ============================================================================

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({
    required this.slides,
    required this.pageController,
    required this.current,
    required this.onPrev,
    required this.onNext,
  });

  final List<GenerationSlideModel> slides;
  final PageController pageController;
  final int current;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final hasMultiple = slides.length > 1;
    final canLeft = hasMultiple && current > 0;
    final canRight = hasMultiple && current < slides.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.cardHi,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: AppColors.surface2),
              PageView.builder(
                controller: pageController,
                itemCount: slides.length,
                itemBuilder: (_, i) => _SlideImage(slide: slides[i]),
              ),
              if (canLeft)
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ArrowButton(
                      icon: Icons.chevron_left,
                      onTap: onPrev,
                    ),
                  ),
                ),
              if (canRight)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ArrowButton(
                      icon: Icons.chevron_right,
                      onTap: onNext,
                    ),
                  ),
                ),
              if (hasMultiple)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${current + 1} / ${slides.length}',
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontFamilyFallback: AppFonts.monoFallback,
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (hasMultiple)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (i) {
                      final active = i == current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideImage extends StatelessWidget {
  const _SlideImage({required this.slide});
  final GenerationSlideModel slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: slide.imageUrl,
          key: ValueKey<String>(slide.imageUrl),
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.surface2),
          errorWidget: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 26,
              ),
            );
          },
        ),
        if (slide.slideText.isNotEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 36,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                slide.slideText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ============================================================================
// _CaptionCard — first-slide caption (mirrors web: always shows slides[0])
// ============================================================================

class _CaptionCard extends StatelessWidget {
  const _CaptionCard({required this.caption});
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CAPTION',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 10.5,
              letterSpacing: 0.6,
              color: AppColors.ink4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption.isEmpty ? 'No caption returned.' : caption,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// _ActionBar — three stacked buttons
// ============================================================================

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.regenerating,
    required this.postingChecking,
    required this.onRegenerate,
    required this.onPostToInstagram,
    required this.onSkip,
  });

  final bool regenerating;
  final bool postingChecking;
  final VoidCallback onRegenerate;
  final VoidCallback onPostToInstagram;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final busy = regenerating || postingChecking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary — Post to Instagram
        ElevatedButton(
          onPressed: busy ? null : onPostToInstagram,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: postingChecking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.camera_alt_outlined, size: 16),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Looks great, post on Instagram",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 10),
        // Ghost — Generate another
        OutlinedButton.icon(
          onPressed: busy ? null : onRegenerate,
          icon: regenerating
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.ink,
                  ),
                )
              : const Icon(Icons.refresh, size: 16),
          label: Text(regenerating ? 'Starting…' : 'Generate another'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
            side: const BorderSide(color: AppColors.line),
            foregroundColor: AppColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        // Text link — Skip
        Center(
          child: TextButton(
            onPressed: busy ? null : onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.ink3,
              textStyle: const TextStyle(
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
            child: const Text('Skip for now — go to dashboard'),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// _ErrorPanel — surfaces regenerate/posting errors
// ============================================================================

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.ink2),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// _EmptyState — no job/slides (deep link, refresh, or pre-completion bounce)
// ============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 24,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No generated post found',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Head back to your inspiration deck and pick a post.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.ink3,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                Get.offAllNamed<void>(AppRoutes.onboardingInspiration),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to deck'),
          ),
        ],
      ),
    );
  }
}
