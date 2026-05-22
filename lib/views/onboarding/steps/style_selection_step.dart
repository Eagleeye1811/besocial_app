import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 5 (custom-style branch). Mirrors `StyleSelectionStep.jsx`. The six
/// preset IDs/labels/tones below match the web exactly so PATCH /session
/// payloads serialize identically on both clients. Up to 3 selected.
class StyleSelectionStep extends GetView<OnboardingController> {
  const StyleSelectionStep({super.key});

  static const List<_StylePreset> _styles = <_StylePreset>[
    _StylePreset('clean-luxury', 'Clean luxury', 'serif · marble · soft',
        _PresetTone.cream),
    _StylePreset('bold-modern', 'Bold modern', 'sans · contrast · big',
        _PresetTone.ink),
    _StylePreset('warm-friendly', 'Warm friendly', 'terracotta · sun',
        _PresetTone.coral),
    _StylePreset('premium-dark', 'Premium dark', 'ivory · gold · noir',
        _PresetTone.ink),
    _StylePreset('minimal-white', 'Minimal white', 'whitespace · grid',
        _PresetTone.gray),
    _StylePreset('vibrant-trendy', 'Vibrant trendy', 'gen-z · gradient',
        _PresetTone.blush),
  ];

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 5 of 8',
        title: 'Pick the styles that feel like you',
        sub: "Choose up to 3. We'll mix them across your post types.",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${controller.selectedStyles.length}/3 selected',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.ink3,
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 12),
          Obx(() {
            final selected = controller.selectedStyles;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _styles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (ctx, i) {
                final s = _styles[i];
                final active = selected.contains(s.id);
                return _PresetTile(
                  preset: s,
                  active: active,
                  onTap: () => controller.toggleStyle(s.id),
                );
              },
            );
          }),
          const SizedBox(height: 22),
          const Text(
            'LIVE PREVIEW',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 11,
              letterSpacing: 0.5,
              color: AppColors.ink4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => _LivePreview(
                selectedStyles: controller.selectedStyles.toList(),
                handle: (controller.instagramHandle.value ?? '').trim(),
                brandCity: (controller.brandCity.value ?? '').trim(),
              )),
        ],
      ),
      footer: Obx(() => FootBar(
            left: Text(
              controller.selectedStyles.isEmpty
                  ? 'Pick at least 1 to continue'
                  : '${controller.selectedStyles.length} of 3 selected',
              style: const TextStyle(fontSize: 13, color: AppColors.ink3),
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

// ---------------------------------------------------------------------------
// Preset tile — colored placeholder swatch + label + sub.
// ---------------------------------------------------------------------------

class _PresetTile extends StatelessWidget {
  final _StylePreset preset;
  final bool active;
  final VoidCallback onTap;
  const _PresetTile({
    required this.preset,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(
                  color: active ? AppColors.ink : AppColors.line,
                  width: active ? 1.8 : 1.2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: active
                    ? const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      color: _toneBg(preset.tone),
                      alignment: Alignment.center,
                      child: Text(
                        preset.label,
                        style: TextStyle(
                          fontFamily: AppFonts.display,
                          fontFamilyFallback: AppFonts.displayFallback,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: _toneFg(preset.tone),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.label,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          preset.sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Color _toneBg(_PresetTone t) {
  switch (t) {
    case _PresetTone.ink:
      return AppColors.ink;
    case _PresetTone.cream:
      return const Color(0xFFF6EDE0);
    case _PresetTone.coral:
      return const Color(0xFFF7D2C0);
    case _PresetTone.gray:
      return AppColors.surface2;
    case _PresetTone.blush:
      return const Color(0xFFF7D6E0);
  }
}

Color _toneFg(_PresetTone t) {
  switch (t) {
    case _PresetTone.ink:
      return Colors.white;
    default:
      return AppColors.ink;
  }
}

// ---------------------------------------------------------------------------
// Live preview — abbreviated Instagram post mockup, tinted by first style.
// ---------------------------------------------------------------------------

class _LivePreview extends StatelessWidget {
  final List<String> selectedStyles;
  final String handle;
  final String brandCity;
  const _LivePreview({
    required this.selectedStyles,
    required this.handle,
    required this.brandCity,
  });

  _PresetTone get _coverTone {
    if (selectedStyles.isEmpty) return _PresetTone.cream;
    switch (selectedStyles.first) {
      case 'premium-dark':
      case 'bold-modern':
        return _PresetTone.ink;
      case 'warm-friendly':
        return _PresetTone.coral;
      case 'vibrant-trendy':
        return _PresetTone.blush;
      case 'minimal-white':
        return _PresetTone.gray;
      default:
        return _PresetTone.cream;
    }
  }

  bool get _darkCover =>
      selectedStyles.contains('premium-dark') ||
      selectedStyles.contains('bold-modern');

  @override
  Widget build(BuildContext context) {
    final display =
        handle.isEmpty ? 'your_handle' : handle;
    final cityLine =
        brandCity.isEmpty ? 'Sponsored' : '$brandCity · Sponsored';

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IG header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppColors.line2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    padding: const EdgeInsets.all(1.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Color(0xFFF47B42),
                          Color(0xFFE1306C),
                          Color(0xFFC13584),
                          Color(0xFFF47B42),
                        ],
                      ),
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          display,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          cityLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz,
                      size: 18, color: AppColors.ink2),
                ],
              ),
            ),
            // Cover
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: _toneBg(_coverTone)),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      '5 bridal looks our stylists\nlove this season',
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontFamilyFallback: AppFonts.displayFallback,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        letterSpacing: -0.5,
                        color: _darkCover ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '1 / 6',
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontFamilyFallback: AppFonts.monoFallback,
                          fontSize: 10.5,
                          color: AppColors.ink2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Actions row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: const [
                  Icon(Icons.favorite_border, size: 20, color: AppColors.ink),
                  SizedBox(width: 14),
                  Icon(Icons.mode_comment_outlined,
                      size: 20, color: AppColors.ink),
                  SizedBox(width: 14),
                  Icon(Icons.send_outlined, size: 20, color: AppColors.ink),
                ],
              ),
            ),
            // Caption
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.ink2,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: '$display ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(
                      text:
                          'Walk down the aisle with hair that turns every head.\n',
                    ),
                    const TextSpan(
                      text: '#MumbaiSalon #BridalLook #LuxuryHair',
                      style: TextStyle(color: AppColors.accentInk),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StylePreset {
  final String id;
  final String label;
  final String sub;
  final _PresetTone tone;
  const _StylePreset(this.id, this.label, this.sub, this.tone);
}

enum _PresetTone { ink, cream, coral, gray, blush }
