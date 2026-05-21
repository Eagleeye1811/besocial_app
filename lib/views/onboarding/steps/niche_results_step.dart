import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 4 — mirrors `NicheResultsStep.jsx`. Surfaces the detected niche
/// and lets the user toggle confirmed/suggested topics and hashtags. Saved
/// via PATCH /session.
class NicheResultsStep extends GetView<OnboardingController> {
  const NicheResultsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 4 of 8 · Analysis complete',
        title: "Here's the niche we found",
        sub: 'Tap to confirm or remove. We use confirmed items in every '
            "post we generate.",
      ),
      body: Obx(() {
        final n = controller.niche.value;
        if (n == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow(label: 'Niche', value: n.niche),
            _SummaryRow(label: 'Sub-niche', value: n.subNiche),
            _SummaryRow(label: 'Micro-niche', value: n.microNiche),
            const SizedBox(height: 24),
            _ChipSection(
              label: 'Confirmed topics · tap to remove',
              items: controller.confirmedTopics,
              onTap: controller.toggleTopic,
              tone: _ChipTone.confirmed,
            ),
            _ChipSection(
              label: 'Suggested topics · tap to add',
              items: controller.suggestedTopics,
              onTap: controller.toggleTopic,
              tone: _ChipTone.suggested,
            ),
            const SizedBox(height: 8),
            _ChipSection(
              label: 'Confirmed hashtags · tap to remove',
              items: controller.confirmedHashtags,
              onTap: controller.toggleHashtag,
              tone: _ChipTone.confirmed,
              prefix: '#',
            ),
            _ChipSection(
              label: 'Suggested hashtags · tap to add',
              items: controller.suggestedHashtags,
              onTap: controller.toggleHashtag,
              tone: _ChipTone.suggested,
              prefix: '#',
            ),
          ],
        );
      }),
      footer: Obx(() => FootBar(
            primary: FootBarPrimaryButton(
              label: 'Looks right',
              icon: Icons.arrow_forward,
              loading: controller.isLoading.value,
              onPressed: controller.submitNicheEdits,
            ),
          )),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontFamilyFallback: AppFonts.monoFallback,
                fontSize: 11,
                color: AppColors.ink4,
                letterSpacing: 0.44,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChipTone { confirmed, suggested }

class _ChipSection extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onTap;
  final _ChipTone tone;
  final String? prefix;

  const _ChipSection({
    required this.label,
    required this.items,
    required this.onTap,
    required this.tone,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final isConfirmed = tone == _ChipTone.confirmed;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              letterSpacing: 0.4,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((item) => InkWell(
                      onTap: () => onTap(item),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isConfirmed
                              ? AppColors.accentSoft
                              : AppColors.white,
                          border: Border.all(
                            color: isConfirmed
                                ? AppColors.accent
                                : AppColors.line,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${prefix ?? ''}$item',
                          style: TextStyle(
                            fontSize: 13,
                            color: isConfirmed
                                ? AppColors.accentInk
                                : AppColors.ink2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
