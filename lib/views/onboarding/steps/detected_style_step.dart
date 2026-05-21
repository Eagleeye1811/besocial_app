import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 5 (branch). Mirrors `DetectedStyleStep.jsx`: user picks between
/// "Match a specific post" (uses one of their existing posts as visual
/// reference) and "Set your own visual style" (goes to StyleSelectionStep).
///
/// The "match specific post" UI — picking from `analyzedPosts` — is
/// scaffolded but not yet implemented (TODO: full picker grid). For now
/// it routes forward with the branch flag captured.
class DetectedStyleStep extends GetView<OnboardingController> {
  const DetectedStyleStep({super.key});

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 5 of 8 · Analysis complete',
        title: "Pick the visual direction we'll generate from",
        sub: 'Either match a specific post, or set your own from scratch.',
      ),
      body: Column(
        children: [
          _Branch(
            title: 'Match a specific post',
            sub: 'Lean into a winner from your existing feed.',
            tag: 'Recommended',
            onTap: () =>
                controller.chooseDetectedStyleBranch(matchSpecificPost: true),
          ),
          const SizedBox(height: 12),
          _Branch(
            title: 'Set your own visual style',
            sub: "Start fresh — we'll mix style chips.",
            tag: 'Custom',
            onTap: () =>
                controller.chooseDetectedStyleBranch(matchSpecificPost: false),
          ),
        ],
      ),
      footer: FootBar(
        primary: FootBarPrimaryButton(
          label: 'Choose above',
          onPressed: null,
        ),
      ),
    );
  }
}

class _Branch extends StatelessWidget {
  final String title;
  final String sub;
  final String tag;
  final VoidCallback onTap;
  const _Branch({
    required this.title,
    required this.sub,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tag.toUpperCase(),
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 10,
                  letterSpacing: 0.4,
                  color: AppColors.accentInk,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              style: TextStyle(fontSize: 14, color: AppColors.ink3),
            ),
          ],
        ),
      ),
    );
  }
}
