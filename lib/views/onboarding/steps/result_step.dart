import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/generation_job_model.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// JWT-gated tail, step B — mirrors `ResultStep.jsx`. Displays the slides
/// returned by the completed generation job as a horizontal carousel.
/// Phase 9 will extract this slide carousel into a shared widget; for now
/// it's inlined here.
class ResultStep extends StatefulWidget {
  const ResultStep({super.key});

  @override
  State<ResultStep> createState() => _ResultStepState();
}

class _ResultStepState extends State<ResultStep> {
  final OnboardingController _c = Get.find<OnboardingController>();
  final PageController _page = PageController();

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Your first carousel',
        title: "Here's what we made",
        sub: "Swipe to flip through the slides. You can edit captions and "
            'regenerate variations from your drafts later.',
      ),
      body: Obx(() {
        final job = _c.currentJob.value;
        if (job == null || job.slides.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: PageView.builder(
                controller: _page,
                itemCount: job.slides.length,
                itemBuilder: (_, i) => _SlideCard(slide: job.slides[i]),
              ),
            ),
            const SizedBox(height: 12),
            _SlideIndicator(
              controller: _page,
              count: job.slides.length,
            ),
            const SizedBox(height: 16),
            if (job.slides.first.caption.isNotEmpty)
              Container(
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
                      job.slides.first.caption,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.ink2,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
      footer: FootBar(
        primary: FootBarPrimaryButton(
          label: 'Looks good',
          icon: Icons.arrow_forward,
          onPressed: _c.completeOnboardingFromResult,
        ),
      ),
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

class _SlideIndicator extends StatefulWidget {
  final PageController controller;
  final int count;
  const _SlideIndicator({required this.controller, required this.count});

  @override
  State<_SlideIndicator> createState() => _SlideIndicatorState();
}

class _SlideIndicatorState extends State<_SlideIndicator> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listen);
  }

  void _listen() {
    final next = widget.controller.page?.round() ?? 0;
    if (next != _page) setState(() => _page = next);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(widget.count, (i) {
        final active = i == _page;
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
    );
  }
}
