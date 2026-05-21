import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_shell.dart';

/// Transition screen between step 4 and step 5. Mirrors `StyleIntroStep.jsx`:
/// large display headline introducing the visual-style picker.
class StyleIntroStep extends GetView<OnboardingController> {
  const StyleIntroStep({super.key});

  @override
  Widget build(BuildContext context) {
    return StepShell(
      body: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Now let's lock\nyour visual style.",
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 36,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.1,
                height: 1.05,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "We've studied your last 30 posts. Next you'll either match a "
              'specific high-performer or set a fresh direction.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.ink2,
              ),
            ),
          ],
        ),
      ),
      footer: FootBar(
        primary: FootBarPrimaryButton(
          label: 'Continue',
          icon: Icons.arrow_forward,
          onPressed: controller.completeStyleIntro,
        ),
      ),
    );
  }
}
