import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 5 (custom-style branch). Mirrors `StyleSelectionStep.jsx`. User
/// picks up to three style chips; saved via PATCH /session.selected_styles.
class StyleSelectionStep extends GetView<OnboardingController> {
  const StyleSelectionStep({super.key});

  static const List<_StylePreset> _styles = <_StylePreset>[
    _StylePreset('minimal', 'Minimal', 'Clean, generous whitespace'),
    _StylePreset('editorial', 'Editorial', 'Magazine-style layout'),
    _StylePreset('bold', 'Bold', 'High contrast, statement type'),
    _StylePreset('playful', 'Playful', 'Bright, character-driven'),
    _StylePreset('organic', 'Organic', 'Warm tones, hand-crafted'),
    _StylePreset('premium', 'Premium', 'Restrained, luxe'),
    _StylePreset('vibrant', 'Vibrant', 'Saturated, energetic'),
    _StylePreset('documentary', 'Documentary', 'Real moments, candid'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 5 of 8',
        title: 'Pick the styles that feel like you',
        sub: "Choose up to 3. We'll mix them across your post types.",
      ),
      body: Obx(() {
        final selected = controller.selectedStyles;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _styles.map((s) {
            final isOn = selected.contains(s.id);
            return InkWell(
              onTap: () => controller.toggleStyle(s.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: (MediaQuery.of(context).size.width - 48 - 10) / 2,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isOn ? AppColors.accentSoft : AppColors.white,
                  border: Border.all(
                    color: isOn ? AppColors.accent : AppColors.line,
                    width: isOn ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.label,
                      style: TextStyle(
                        fontFamily: AppFonts.ui,
                        fontFamilyFallback: AppFonts.uiFallback,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isOn ? AppColors.accentInk : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.sub,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
      footer: Obx(() => FootBar(
            left: Text(
              controller.selectedStyles.isEmpty
                  ? 'Pick at least 1'
                  : '${controller.selectedStyles.length} of 3 selected',
              style: TextStyle(fontSize: 13, color: AppColors.ink3),
            ),
            primary: FootBarPrimaryButton(
              label: 'Continue',
              icon: Icons.arrow_forward,
              loading: controller.isLoading.value,
              onPressed: controller.selectedStyles.isEmpty
                  ? null
                  : controller.submitStyleSelection,
            ),
          )),
    );
  }
}

class _StylePreset {
  final String id;
  final String label;
  final String sub;
  const _StylePreset(this.id, this.label, this.sub);
}
