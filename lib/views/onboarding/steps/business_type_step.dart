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
    _BusinessChoice('restaurant', 'Restaurant', 'Menus, dishes, ambience'),
    _BusinessChoice('salon', 'Salon', 'Hair, beauty, transformations'),
    _BusinessChoice('gym', 'Gym', 'Coaches, classes, results'),
    _BusinessChoice('cafe', 'Cafe', 'Drinks, vibe, regulars'),
    _BusinessChoice('realestate', 'Real estate', 'Listings, walkthroughs'),
    _BusinessChoice('clinic', 'Clinic', 'Doctors, services, trust'),
    _BusinessChoice('clothing', 'Clothing store', 'New arrivals, lookbooks'),
    _BusinessChoice('other', 'Something else', 'Custom workflow'),
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
          children: _choices
              .map((c) => _ChoiceTile(
                    choice: c,
                    selected: selected == c.id,
                    onTap: () => controller.businessType.value = c.id,
                  ))
              .toList(),
        );
      }),
      footer: Obx(() => FootBar(
            primary: FootBarPrimaryButton(
              label: 'Continue',
              icon: Icons.arrow_forward,
              loading: controller.isLoading.value,
              onPressed: controller.businessType.value == null
                  ? null
                  : () =>
                      controller.submitBusinessType(controller.businessType.value!),
            ),
          )),
    );
  }
}

class _BusinessChoice {
  final String id;
  final String label;
  final String sub;
  const _BusinessChoice(this.id, this.label, this.sub);
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSoft : AppColors.white,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                choice.label,
                style: TextStyle(
                  fontFamily: AppFonts.ui,
                  fontFamilyFallback: AppFonts.uiFallback,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.accentInk : AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                choice.sub,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.ink3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
