import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/generation_job_model.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_shell.dart';

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
    return StepShell(
      showAppBar: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Obx(() {
          final job = _c.currentJob.value;
          final err = _c.errorMessage.value;
          final status = job?.status ?? GenerationJobStatus.pending;
          final copy = _statusCopy[status] ?? '';
          final isFailed = status == GenerationJobStatus.failed || err != null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isFailed)
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.accent,
                  ),
                )
              else
                const Icon(Icons.error_outline,
                    color: Color(0xFFDC2626), size: 36),
              const SizedBox(height: 28),
              Text(
                isFailed ? "Generation failed" : "Generating your first post",
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isFailed ? (err ?? copy) : copy,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.ink3,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (isFailed)
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try again'),
                  onPressed: _c.triggerGeneration,
                ),
            ],
          );
        }),
      ),
      footer: Obx(() {
        final showSkip = _c.currentJob.value?.status ==
            GenerationJobStatus.failed;
        if (!showSkip) return const SizedBox.shrink();
        return FootBar(
          left: TextButton(
            onPressed: _c.skipGenerationToComplete,
            child: const Text('Skip for now'),
          ),
          primary: FootBarPrimaryButton(
            label: 'Retry',
            onPressed: _c.triggerGeneration,
          ),
        );
      }),
    );
  }
}
