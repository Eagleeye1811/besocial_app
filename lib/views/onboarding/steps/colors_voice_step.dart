import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 6 — mirrors `ColorsVoiceStep.jsx`. Picks one color palette and one
/// voice tone. Saved as `color_palette_id` + `voice_tone_id` on the session.
class ColorsVoiceStep extends GetView<OnboardingController> {
  const ColorsVoiceStep({super.key});

  static const List<_Palette> _palettes = <_Palette>[
    _Palette('warm', 'Warm earth', [
      Color(0xFFE7C9A4),
      Color(0xFFC78A56),
      Color(0xFF6F3E1F),
    ]),
    _Palette('cool', 'Cool linen', [
      Color(0xFFE7EAEE),
      Color(0xFFA9B5C2),
      Color(0xFF334A66),
    ]),
    _Palette('mono', 'Mono ink', [
      Color(0xFFFAFAF9),
      Color(0xFFA1A1AA),
      Color(0xFF18181B),
    ]),
    _Palette('bloom', 'Bloom', [
      Color(0xFFFEE5DD),
      Color(0xFFFAB5A6),
      Color(0xFFE25B36),
    ]),
  ];

  static const List<_Voice> _voices = <_Voice>[
    _Voice('crisp', 'Crisp', 'Tight, declarative, modern.'),
    _Voice('warm', 'Warm', 'Inviting, human, story-driven.'),
    _Voice('cheeky', 'Cheeky', 'Playful with a wink.'),
    _Voice('expert', 'Expert', 'Authoritative, specific, deep.'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 6 of 8',
        title: 'Colors and voice',
        sub: "Pick the palette and tone we'll write in.",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PALETTE',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 11,
              letterSpacing: 0.44,
              color: AppColors.ink4,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Column(
                children: _palettes
                    .map((p) => _PaletteTile(
                          palette: p,
                          selected: controller.colorPaletteId.value == p.id,
                          onTap: () => controller.colorPaletteId.value = p.id,
                        ))
                    .toList(),
              )),
          const SizedBox(height: 20),
          Text(
            'VOICE',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 11,
              letterSpacing: 0.44,
              color: AppColors.ink4,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Column(
                children: _voices
                    .map((v) => _VoiceTile(
                          voice: v,
                          selected: controller.voiceToneId.value == v.id,
                          onTap: () => controller.voiceToneId.value = v.id,
                        ))
                    .toList(),
              )),
        ],
      ),
      footer: Obx(() {
        final ready = controller.colorPaletteId.value != null &&
            controller.voiceToneId.value != null;
        return FootBar(
          primary: FootBarPrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward,
            loading: controller.isLoading.value,
            onPressed: ready
                ? () => controller.submitColorsVoice(
                      paletteId: controller.colorPaletteId.value!,
                      voiceId: controller.voiceToneId.value!,
                    )
                : null,
          ),
        );
      }),
    );
  }
}

class _Palette {
  final String id;
  final String label;
  final List<Color> swatches;
  const _Palette(this.id, this.label, this.swatches);
}

class _Voice {
  final String id;
  final String label;
  final String sub;
  const _Voice(this.id, this.label, this.sub);
}

class _PaletteTile extends StatelessWidget {
  final _Palette palette;
  final bool selected;
  final VoidCallback onTap;
  const _PaletteTile({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSoft : AppColors.white,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Row(
                children: palette.swatches
                    .map((c) => Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: c,
                            border: Border.all(color: AppColors.line),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  palette.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.accentInk : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceTile extends StatelessWidget {
  final _Voice voice;
  final bool selected;
  final VoidCallback onTap;
  const _VoiceTile({
    required this.voice,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                voice.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.accentInk : AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(voice.sub,
                  style: TextStyle(fontSize: 13, color: AppColors.ink3)),
            ],
          ),
        ),
      ),
    );
  }
}
