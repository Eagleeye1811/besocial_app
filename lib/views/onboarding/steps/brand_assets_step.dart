import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 7 — mirrors `BrandAssetsStep.jsx`. Three optional upload slots:
/// people photos, products, brand logo. Backend endpoint is
/// `POST /api/v1/onboarding/assets/upload`.
///
/// File picker isn't wired up yet (no `image_picker` dep this phase) — the
/// upload buttons are disabled placeholders. The user can still skip the
/// step entirely; the backend treats assets as optional.
class BrandAssetsStep extends GetView<OnboardingController> {
  const BrandAssetsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 7 of 8',
        title: 'Add a few of your real assets',
        sub: "Optional — but they make every generation look more like you.",
      ),
      body: Column(
        children: const [
          _AssetSlot(
            eyebrow: 'Your face & team',
            title: 'People photos',
            sub: 'Selfies, team headshots, founder portraits.',
          ),
          SizedBox(height: 10),
          _AssetSlot(
            eyebrow: 'Products & space',
            title: 'Product or asset photos',
            sub: 'Hero shots of the things you sell or serve.',
          ),
          SizedBox(height: 10),
          _AssetSlot(
            eyebrow: 'Brand mark',
            title: 'Brand logo',
            sub: 'PNG or SVG works best.',
          ),
          SizedBox(height: 16),
          Text(
            'File picker arrives next phase — for now, tap continue to '
            "skip. You can upload assets from Brand settings later.",
            style: TextStyle(fontSize: 12, color: AppColors.ink3),
          ),
        ],
      ),
      footer: FootBar(
        left: TextButton(
          onPressed: controller.completeBrandAssets,
          child: const Text('Skip for now'),
        ),
        primary: FootBarPrimaryButton(
          label: 'Continue',
          icon: Icons.arrow_forward,
          onPressed: controller.completeBrandAssets,
        ),
      ),
    );
  }
}

class _AssetSlot extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String sub;
  const _AssetSlot({
    required this.eyebrow,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.ink4,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 10,
                    letterSpacing: 0.4,
                    color: AppColors.ink4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(fontSize: 12, color: AppColors.ink3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
