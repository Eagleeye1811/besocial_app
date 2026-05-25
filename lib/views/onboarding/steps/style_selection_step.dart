import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 5 (custom-style branch). Mirrors `StyleSelectionStep.jsx`.
///
/// The 6 preset IDs/labels/sub-tags/tones below match the web exactly so
/// PATCH /onboarding/session payloads serialize identically on both
/// clients (`selected_styles: [<preset.id>, ...]`). The user picks up to
/// 3 and the live IG preview reacts to the *first* selected style.
///
/// Reactivity architecture:
/// - The counter at the top right reads `.length` inside its own Obx.
/// - Each grid tile is wrapped in its own Obx; the outer grid is NOT,
///   because Obx's tracking only runs during the synchronous build
///   callback — itemBuilder's reads would otherwise be lost and throw
///   "[Get] improper use of GetX/Obx". Per-tile Obx is also lighter:
///   tapping one card rebuilds only that card.
/// - The live preview, chip strip, error surface, and footer each have
///   their own Obxs with synchronous observable reads.
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
          // Counter — right-aligned, mirrors the span next to the web StepHead.
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() {
              final count = controller.selectedStyles.length;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: count == 0
                      ? AppColors.surface
                      : AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: count == 0 ? AppColors.line : AppColors.accentSoft,
                  ),
                ),
                child: Text(
                  '$count/3 selected',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: count == 0
                        ? AppColors.ink3
                        : AppColors.accentInk,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Preset grid — each tile is its own Obx for fine-grained reactivity.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _styles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (_, i) {
              final s = _styles[i];
              return Obx(() {
                final active = controller.selectedStyles.contains(s.id);
                final atLimit = controller.selectedStyles.length >= 3;
                final disabled = !active && atLimit;
                return _PresetTile(
                  preset: s,
                  active: active,
                  disabled: disabled,
                  onTap: () => controller.toggleStyle(s.id),
                );
              });
            },
          ),
          const SizedBox(height: 26),

          // Live preview header
          Row(
            children: [
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
              const SizedBox(width: 8),
              Container(
                width: 26,
                height: 1,
                color: AppColors.line,
              ),
            ],
          ),
          const SizedBox(height: 10),

          Obx(() => _LivePreview(
                selectedStyles: controller.selectedStyles.toList(),
                handle: (controller.instagramHandle.value ?? '').trim(),
                brandCity: (controller.brandCity.value ?? '').trim(),
              )),
          const SizedBox(height: 12),

          // Selected chips strip — mirrors the wrap below the web preview.
          Obx(() {
            final selected = controller.selectedStyles.toList();
            if (selected.isEmpty) {
              return const Text(
                'Select a style to update the preview.',
                style: TextStyle(fontSize: 12.5, color: AppColors.ink3),
              );
            }
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selected.map((id) {
                final label = _styles
                    .firstWhere(
                      (s) => s.id == id,
                      orElse: () => _StylePreset(id, id, '', _PresetTone.gray),
                    )
                    .label;
                return _SelectedChip(
                  label: label,
                  onRemove: () => controller.toggleStyle(id),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 12),

          // Error surface
          Obx(() {
            final err = controller.errorMessage.value;
            if (err == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.ink2,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      err,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink2,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      footer: Obx(() {
        final count = controller.selectedStyles.length;
        return FootBar(
          left: Text(
            count == 0
                ? 'Pick at least 1 to continue'
                : '$count of 3 selected',
            style: const TextStyle(fontSize: 13, color: AppColors.ink3),
          ),
          primary: FootBarPrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward,
            loading: controller.isLoading.value,
            onPressed: count == 0 ? null : controller.submitStyleSelection,
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Preset tile — colored placeholder swatch + label + sub.
// ---------------------------------------------------------------------------

class _PresetTile extends StatelessWidget {
  final _StylePreset preset;
  final bool active;
  final bool disabled;
  final VoidCallback onTap;
  const _PresetTile({
    required this.preset,
    required this.active,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: active ? AppColors.ink : AppColors.line,
            width: active ? 1.8 : 1.2,
          ),
          borderRadius: radius,
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : AppShadows.card,
        ),
        // Clip the ripple + content to the rounded shape so taps don't
        // bleed past the border. ClipRRect lives INSIDE the decorated box
        // so the shadow + border continue to render with proper rounded
        // corners, and the ink ripple stays inside the card.
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: disabled ? null : onTap,
              splashColor: AppColors.accentSoft.withValues(alpha: 0.45),
              highlightColor: AppColors.accentSoft.withValues(alpha: 0.20),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _ToneSwatch(
                          tone: preset.tone,
                          label: preset.label,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                                letterSpacing: -0.1,
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
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check,
                            size: 13, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToneSwatch extends StatelessWidget {
  const _ToneSwatch({required this.tone, required this.label});

  final _PresetTone tone;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = _toneGradient(tone);
    final fg = _toneFg(tone);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Positioned(
            top: -16,
            right: -16,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fg.withValues(alpha: 0.10),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: fg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<Color> _toneGradient(_PresetTone t) {
  switch (t) {
    case _PresetTone.ink:
      return const [Color(0xFF1F1D2A), Color(0xFF0E0D14)];
    case _PresetTone.cream:
      return const [Color(0xFFF8F0E2), Color(0xFFE9DBC1)];
    case _PresetTone.coral:
      return const [Color(0xFFF8D5C2), Color(0xFFE5A079)];
    case _PresetTone.gray:
      return const [Color(0xFFFAFAF9), Color(0xFFEDEDEB)];
    case _PresetTone.blush:
      return const [Color(0xFFFAD9E3), Color(0xFFE9A8C5)];
  }
}

Color _toneFg(_PresetTone t) {
  switch (t) {
    case _PresetTone.ink:
      return Colors.white;
    case _PresetTone.coral:
      return const Color(0xFF6D2A0E);
    case _PresetTone.cream:
      return const Color(0xFF5A4427);
    case _PresetTone.blush:
      return const Color(0xFF7A2E4E);
    case _PresetTone.gray:
      return AppColors.ink;
  }
}

// ---------------------------------------------------------------------------
// Selected chip — pill with label + remove-on-tap behavior.
// ---------------------------------------------------------------------------

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accentSoft),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentInk,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.close,
                size: 12,
                color: AppColors.accentInk,
              ),
            ],
          ),
        ),
      ),
    );
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
    final display = handle.isEmpty ? 'your_handle' : handle;
    final cityLine =
        brandCity.isEmpty ? 'Sponsored' : '$brandCity · Sponsored';

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IG header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.line2)),
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
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _toneGradient(_coverTone),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Centered eyebrow chip — "Cover · slide 1 of 6".
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _darkCover
                            ? Colors.white.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _darkCover
                              ? Colors.white.withValues(alpha: 0.22)
                              : AppColors.line,
                        ),
                      ),
                      child: Text(
                        'Cover · slide 1 of 6',
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontFamilyFallback: AppFonts.monoFallback,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: _darkCover
                              ? Colors.white.withValues(alpha: 0.92)
                              : AppColors.ink2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      '5 bridal looks our stylists\nlove this season',
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontFamilyFallback: AppFonts.displayFallback,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        height: 1.12,
                        letterSpacing: -0.6,
                        color: _darkCover ? Colors.white : AppColors.ink,
                        shadows: _darkCover
                            ? const [
                                Shadow(
                                  blurRadius: 12,
                                  color: Color(0x66000000),
                                  offset: Offset(0, 1),
                                ),
                              ]
                            : null,
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
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.line2)),
              ),
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
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
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
