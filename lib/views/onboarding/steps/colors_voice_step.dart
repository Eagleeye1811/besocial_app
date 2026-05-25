import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 6 — mirrors `ColorsVoiceStep.jsx`.
///
/// Picks one color palette and one voice tone, both saved as
/// `color_palette_id` + `voice_tone_id` on PATCH /onboarding/session. The 6
/// palette IDs and 6 voice tone IDs below are copied verbatim from the
/// website so payloads serialize identically on both clients.
///
/// Mobile layout: the web's side-by-side 2-column layout (palette grid +
/// voice list) is stacked vertically. The palette grid stays 2-col (matches
/// the web's inner grid) and the voice list is single-column with an icon
/// chip + label/sub + a radio indicator on the trailing edge. A sample
/// caption strip appears under the voice list once a tone is picked.
///
/// Reactivity: each Obx reads its observables *synchronously* in the build
/// callback (no GridView.builder lazy traps — children are materialized
/// via `.map().toList()` so reads land during the Obx tracking window).
class ColorsVoiceStep extends GetView<OnboardingController> {
  const ColorsVoiceStep({super.key});

  static const List<_Palette> _palettes = <_Palette>[
    _Palette(
      'terracotta',
      'Terracotta noir',
      [Color(0xFF1C1B19), Color(0xFFF47B42), Color(0xFFF1E4D2), Color(0xFFFFFFFF)],
    ),
    _Palette(
      'rose',
      'Rose marble',
      [Color(0xFF2A1F1B), Color(0xFFD88B72), Color(0xFFF5E5E2), Color(0xFFFBF7F4)],
    ),
    _Palette(
      'jade',
      'Jade calm',
      [Color(0xFF0F2A24), Color(0xFF3F8F7B), Color(0xFFE8EFEA), Color(0xFFFFFFFF)],
    ),
    _Palette(
      'mono',
      'Mono ivory',
      [Color(0xFF0A0A0A), Color(0xFF3F3F46), Color(0xFFE5E5E5), Color(0xFFFAFAF7)],
    ),
    _Palette(
      'sun',
      'Sun citrus',
      [Color(0xFF1A1A1A), Color(0xFFE8A33D), Color(0xFFFFE9C2), Color(0xFFFFFFFF)],
    ),
    _Palette(
      'plum',
      'Plum velvet',
      [Color(0xFF1A0E22), Color(0xFF7B3F8A), Color(0xFFE9D9EE), Color(0xFFFBF7F4)],
    ),
  ];

  static const List<_Voice> _voices = <_Voice>[
    _Voice('professional', 'Professional', 'Calm, expert, polished',
        Icons.shield_outlined),
    _Voice('friendly', 'Friendly', 'Warm, conversational',
        Icons.favorite_border),
    _Voice('premium', 'Premium', 'Refined, understated',
        Icons.auto_awesome),
    _Voice('bold', 'Bold', 'Direct, confident', Icons.bolt_outlined),
    _Voice('trustworthy', 'Trustworthy', 'Honest, dependable',
        Icons.lock_outline),
    _Voice('fun', 'Fun', 'Playful, witty, light',
        Icons.auto_fix_high_outlined),
  ];

  static const Map<String, String> _sampleCaptions = {
    'premium':
        'Three quiet hours. One transformation. Bridal trials this Thursday — just one slot remaining.',
    'friendly':
        "Hey lovely 🌸 We've got 1 bridal trial open this Thursday — DM us if you'd like to come by.",
    'professional':
        'Our senior stylists open Thursday for bridal consultations. One slot remains. Reserve via DM.',
    'bold': 'Bridal trial. Thursday. One chair. Yours? DM now.',
    'trustworthy':
        'Bridal trials this Thursday — fully confidential, 1:1 with our senior stylist. Book privately via DM.',
    'fun':
        "Pssst — we saved you the prettiest chair on Thursday. Bridal trial? DM us, bestie 💛",
  };

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 6 of 8',
        title: 'Colors and voice',
        sub:
            'Two quick choices that define how every post feels — visually and in writing.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(label: 'COLOR PALETTE'),
          const SizedBox(height: 10),
          Obx(() {
            final selectedId = controller.colorPaletteId.value;
            return _PaletteGrid(
              palettes: _palettes,
              selectedId: selectedId,
              onSelect: (id) => controller.colorPaletteId.value = id,
            );
          }),
          const SizedBox(height: 24),
          const _SectionHeader(label: 'BRAND VOICE'),
          const SizedBox(height: 10),
          Obx(() {
            final selectedId = controller.voiceToneId.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _voices
                  .map((v) => _VoiceTile(
                        voice: v,
                        selected: selectedId == v.id,
                        onTap: () => controller.voiceToneId.value = v.id,
                      ))
                  .toList(),
            );
          }),
          const SizedBox(height: 10),
          Obx(() {
            final id = controller.voiceToneId.value;
            if (id == null) return const SizedBox.shrink();
            final caption = _sampleCaptions[id];
            if (caption == null) return const SizedBox.shrink();
            final label = _voices
                .firstWhere(
                  (v) => v.id == id,
                  orElse: () => _voices.first,
                )
                .label
                .toLowerCase();
            return _SampleCaptionBox(voiceLabel: label, caption: caption);
          }),
          const SizedBox(height: 12),
          Obx(() {
            final err = controller.errorMessage.value;
            if (err == null) return const SizedBox.shrink();
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.ink2),
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
        final paletteId = controller.colorPaletteId.value;
        final voiceId = controller.voiceToneId.value;
        final ready = paletteId != null && voiceId != null;
        return FootBar(
          left: Text(
            ready
                ? 'Looks good'
                : 'Pick a palette and a voice to continue',
            style: const TextStyle(fontSize: 13, color: AppColors.ink3),
          ),
          primary: FootBarPrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward,
            loading: controller.isLoading.value,
            onPressed: ready
                ? () => controller.submitColorsVoice(
                      paletteId: paletteId,
                      voiceId: voiceId,
                    )
                : null,
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 11,
            letterSpacing: 0.7,
            color: AppColors.ink4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.line,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Palette grid
// ---------------------------------------------------------------------------

class _PaletteGrid extends StatelessWidget {
  const _PaletteGrid({
    required this.palettes,
    required this.selectedId,
    required this.onSelect,
  });

  final List<_Palette> palettes;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: palettes
          .map((p) => _PaletteTile(
                palette: p,
                selected: selectedId == p.id,
                onTap: () => onSelect(p.id),
              ))
          .toList(),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final _Palette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: selected ? AppColors.ink : AppColors.line,
          width: selected ? 1.8 : 1.2,
        ),
        borderRadius: radius,
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.accentSoft.withValues(alpha: 0.4),
            highlightColor: AppColors.accentSoft.withValues(alpha: 0.18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 4-color swatch strip
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.line2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: palette.swatches
                                .map(
                                  (c) => Expanded(
                                    child: Container(color: c),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        palette.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        palette.hexAccents,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontFamilyFallback: AppFonts.monoFallback,
                          fontSize: 10.5,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                  if (selected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 10, color: Colors.white),
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

// ---------------------------------------------------------------------------
// Voice tile
// ---------------------------------------------------------------------------

class _VoiceTile extends StatelessWidget {
  const _VoiceTile({
    required this.voice,
    required this.selected,
    required this.onTap,
  });

  final _Voice voice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.line,
            width: selected ? 1.8 : 1.2,
          ),
          borderRadius: radius,
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: AppColors.accentSoft.withValues(alpha: 0.4),
              highlightColor: AppColors.accentSoft.withValues(alpha: 0.18),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentSoft
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        voice.icon,
                        size: 16,
                        color: selected
                            ? AppColors.accentInk
                            : AppColors.ink2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voice.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            voice.sub,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.ink3,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? AppColors.ink : Colors.transparent,
                        border: selected
                            ? null
                            : Border.all(
                                color: AppColors.line, width: 1.5),
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              size: 12, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample caption strip — appears once a voice is picked.
// ---------------------------------------------------------------------------

class _SampleCaptionBox extends StatelessWidget {
  const _SampleCaptionBox({
    required this.voiceLabel,
    required this.caption,
  });

  final String voiceLabel;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_outlined,
                  size: 14, color: AppColors.ink4),
              const SizedBox(width: 6),
              Text(
                'SAMPLE CAPTION · ${voiceLabel.toUpperCase()}',
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 10.5,
                  letterSpacing: 0.5,
                  color: AppColors.ink4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.ink2,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class _Palette {
  final String id;
  final String name;
  final List<Color> swatches;
  const _Palette(this.id, this.name, this.swatches);

  /// The web shows the middle two hex codes (slice(1, 3)) under the name as
  /// "#xxxxxx · #xxxxxx" in mono — they're the most defining ink and accent.
  String get hexAccents {
    if (swatches.length < 3) return '';
    String hex(Color c) {
      // Avoid the deprecated `c.value`; assemble from RGBO.
      final r = c.r.round().clamp(0, 255);
      final g = c.g.round().clamp(0, 255);
      final b = c.b.round().clamp(0, 255);
      String two(int x) => x.toRadixString(16).padLeft(2, '0').toUpperCase();
      return '#${two(r)}${two(g)}${two(b)}';
    }

    return '${hex(swatches[1])} · ${hex(swatches[2])}';
  }
}

class _Voice {
  final String id;
  final String label;
  final String sub;
  final IconData icon;
  const _Voice(this.id, this.label, this.sub, this.icon);
}
