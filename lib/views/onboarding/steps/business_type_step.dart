import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 2 — mirrors `BusinessTypeStep.jsx`. Eight pre-set categories plus
/// a catch-all. Picking writes `business_type` through PATCH /session.
class BusinessTypeStep extends GetView<OnboardingController> {
  const BusinessTypeStep({super.key});

  static const List<_BusinessChoice> _choices = <_BusinessChoice>[
    _BusinessChoice(
      'restaurant',
      'Restaurant',
      'Menus, dishes, ambience',
      Icons.restaurant_menu,
    ),
    _BusinessChoice(
      'salon',
      'Salon',
      'Hair, beauty, transformations',
      Icons.content_cut,
    ),
    _BusinessChoice(
      'gym',
      'Gym',
      'Coaches, classes, results',
      Icons.fitness_center,
    ),
    _BusinessChoice(
      'cafe',
      'Cafe',
      'Drinks, vibe, regulars',
      Icons.local_cafe,
    ),
    _BusinessChoice(
      'realestate',
      'Real estate',
      'Listings, walkthroughs',
      Icons.home_work,
    ),
    _BusinessChoice(
      'clinic',
      'Clinic',
      'Doctors, services, trust',
      Icons.medical_services,
    ),
    _BusinessChoice(
      'clothing',
      'Clothing store',
      'New arrivals, lookbooks',
      Icons.checkroom,
    ),
    _BusinessChoice(
      'other',
      'Something else',
      'Custom workflow',
      Icons.more_horiz,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 2 of 8',
        title: 'What kind of business do you run?',
        sub: "We'll tune content templates, hashtags, and posting cadence "
            'to your category. You can change this later.',
      ),
      body: Obx(() {
        final selected = controller.businessType.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            for (final c in _choices)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChoiceTile(
                  choice: c,
                  selected: selected == c.id,
                  onTap: () => controller.businessType.value = c.id,
                ),
              ),
            const SizedBox(height: 4),
          ],
        );
      }),
      footer: Obx(() => FootBar(
            primary: FootBarPrimaryButton(
              label: 'Continue',
              icon: Icons.arrow_forward,
              loading: controller.isLoading.value,
              onPressed: controller.businessType.value == null
                  ? null
                  : () => controller
                      .submitBusinessType(controller.businessType.value!),
            ),
          )),
    );
  }
}

class _BusinessChoice {
  final String id;
  final String label;
  final String sub;
  final IconData icon;
  const _BusinessChoice(this.id, this.label, this.sub, this.icon);
}

class _ChoiceTile extends StatelessWidget {
  final _BusinessChoice choice;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Icon(
                    choice.icon,
                    size: 22,
                    color: selected ? AppColors.accent : AppColors.ink2,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        choice.label,
                        style: const TextStyle(
                          fontFamily: AppFonts.ui,
                          fontFamilyFallback: AppFonts.uiFallback,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        choice.sub,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
