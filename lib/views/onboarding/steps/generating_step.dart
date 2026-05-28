import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/generation_job_model.dart';
import '../widgets/foot_bar.dart';

/// JWT-gated tail, step A — mirrors `GeneratingStep.jsx`. Triggers
/// `POST /generation` on mount and polls until completed or failed.
/// Advances to [ResultStep] on success.
class GeneratingStep extends StatefulWidget {
  const GeneratingStep({super.key});

  @override
  State<GeneratingStep> createState() => _GeneratingStepState();
}

class _GeneratingStepState extends State<GeneratingStep> {
  final OnboardingController _c = Get.find<OnboardingController>();

  static const Map<GenerationJobStatus, String> _statusCopy = {
    GenerationJobStatus.pending: 'Queuing your first carousel…',
    GenerationJobStatus.analyzing: 'Studying your reference post…',
    GenerationJobStatus.planning: 'Planning the slide outline…',
    GenerationJobStatus.rendering: 'Rendering each slide…',
    GenerationJobStatus.completed: 'Done — opening your slides…',
    GenerationJobStatus.failed: 'Something went sideways.',
  };

  // Maps a pipeline status to how many of the 4 progress segments are filled.
  static int _activeStage(GenerationJobStatus s) {
    switch (s) {
      case GenerationJobStatus.pending:
        return 1;
      case GenerationJobStatus.analyzing:
        return 2;
      case GenerationJobStatus.planning:
        return 3;
      case GenerationJobStatus.rendering:
      case GenerationJobStatus.completed:
        return 4;
      case GenerationJobStatus.failed:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.triggerGeneration());
  }

  @override
  void dispose() {
    _c.cancelGeneration();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Obx(() {
              final job = _c.currentJob.value;
              final err = _c.errorMessage.value;
              final status = job?.status ?? GenerationJobStatus.pending;
              final copy = _statusCopy[status] ?? '';
              final isFailed =
                  status == GenerationJobStatus.failed || err != null;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LoaderBadge(failed: isFailed),
                  const SizedBox(height: 28),
                  Text(
                    isFailed
                        ? 'Generation failed'
                        : 'Generating your first post',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontFamilyFallback: AppFonts.displayFallback,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      height: 1.15,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isFailed ? (err ?? copy) : copy,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.ink3,
                      height: 1.5,
                    ),
                  ),
                  if (!isFailed) ...[
                    const SizedBox(height: 28),
                    _StageBar(active: _activeStage(status)),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final isFailed = _c.currentJob.value?.status ==
                GenerationJobStatus.failed ||
            _c.errorMessage.value != null;
        if (!isFailed) return const SizedBox.shrink();
        return FootBar(
          left: TextButton(
            onPressed: _c.skipGenerationToComplete,
            child: const Text('Skip for now'),
          ),
          primary: FootBarPrimaryButton(
            label: 'Retry',
            icon: Icons.refresh,
            onPressed: _c.triggerGeneration,
          ),
        );
      }),
    );
  }
}

/// Circular badge holding the activity ring + a sparkle icon (or an error
/// glyph when generation fails).
class _LoaderBadge extends StatelessWidget {
  final bool failed;
  const _LoaderBadge({required this.failed});

  @override
  Widget build(BuildContext context) {
    if (failed) {
      return Container(
        width: 84,
        height: 84,
        decoration: const BoxDecoration(
          color: Color(0xFFFBEDEA),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.error_outline_rounded,
            color: Color(0xFFDC2626), size: 34),
      );
    }
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: 84,
            height: 84,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.accent,
              backgroundColor: AppColors.line,
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.accent, size: 26),
          ),
        ],
      ),
    );
  }
}

/// Four-segment progress rail that fills as the pipeline advances.
class _StageBar extends StatelessWidget {
  final int active; // count of filled segments (0–4)
  const _StageBar({required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 26,
          height: 4,
          margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
          decoration: BoxDecoration(
            color: i < active ? AppColors.accent : AppColors.line,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
