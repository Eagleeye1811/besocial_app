import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/step_shell.dart';

/// Short cinematic between the style intro and detected-style screens.
/// Mirrors `AnalyzingPostsStep.jsx` — the live "Studying your feed" badge.
/// On mobile this is just a brief delay so the UI doesn't feel abrupt.
class AnalyzingPostsStep extends StatefulWidget {
  const AnalyzingPostsStep({super.key});

  @override
  State<AnalyzingPostsStep> createState() => _AnalyzingPostsStepState();
}

class _AnalyzingPostsStepState extends State<AnalyzingPostsStep> {
  final OnboardingController _c = Get.find<OnboardingController>();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _c.completeAnalyzingPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final handle = _c.instagramHandle.value;
    return StepShell(
      showAppBar: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Studying your feed',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              handle == null || handle.isEmpty
                  ? 'Reading your last 30 posts.'
                  : 'Reading the last 30 posts on @$handle.',
              style: TextStyle(fontSize: 14, color: AppColors.ink3),
            ),
          ],
        ),
      ),
    );
  }
}
