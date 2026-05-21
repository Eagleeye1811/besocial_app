import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_shell.dart';

/// JWT-gated tail, step C — mirrors `CompleteStep.jsx`. The backend treats
/// `has_completed_onboarding` as a *derived* boolean (true once
/// `instagram_profile` is non-null on the UserDoc), so this screen makes no
/// extra backend call — it's a celebration + dashboard handoff.
class CompleteStep extends GetView<OnboardingController> {
  const CompleteStep({super.key});

  @override
  Widget build(BuildContext context) {
    return StepShell(
      showAppBar: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 64, bottom: 16),
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
                'YOU\'RE IN',
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 10,
                  letterSpacing: 0.4,
                  color: AppColors.accentInk,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "All set.\nYour studio is open.",
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 36,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.0,
                height: 1.05,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Your dashboard tracks engagement, surfaces trending posts in "
              "your niche, and keeps every generation on your drafts shelf.",
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
          label: 'Open dashboard',
          icon: Icons.arrow_forward,
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
      ),
    );
  }
}
