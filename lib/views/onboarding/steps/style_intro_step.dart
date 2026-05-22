import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_shell.dart';

/// Transition screen — mirrors `StyleIntroStep.jsx`. Eyebrow + display
/// headline with italic "visual" + paragraph + 3 feature rows (icons).
/// Footer "Start" advances to AnalyzingPostsStep.
class StyleIntroStep extends GetView<OnboardingController> {
  const StyleIntroStep({super.key});

  static const List<({IconData icon, String label})> _features = [
    (icon: Icons.palette_outlined, label: 'Aesthetic moodboard'),
    (icon: Icons.auto_fix_high_outlined, label: 'On-brand templates'),
    (icon: Icons.remove_red_eye_outlined, label: 'Live post previews'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepShell(
      body: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STEP 5 OF 8 · PERSONALIZE',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontFamilyFallback: AppFonts.monoFallback,
                fontSize: 11,
                letterSpacing: 0.5,
                color: AppColors.accentInk,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.0,
                  height: 1.05,
                  color: AppColors.ink,
                ),
                children: const [
                  TextSpan(text: "Let's match your\n"),
                  TextSpan(
                    text: 'visual',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(text: ' style.'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "You'll pick a few aesthetics that feel right for your brand. "
              "We'll personalize every cover, frame, and font from here.",
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(height: 28),
            ..._features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(f.icon, size: 18, color: AppColors.ink2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        f.label,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.ink2,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      footer: FootBar(
        primary: FootBarPrimaryButton(
          label: 'Start',
          icon: Icons.arrow_forward,
          onPressed: controller.completeStyleIntro,
        ),
      ),
    );
  }
}
