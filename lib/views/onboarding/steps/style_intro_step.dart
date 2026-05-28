import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_shell.dart';

/// Transition screen — mirrors `StyleIntroStep.jsx`.
///
/// Web layout (two columns: text + stacked cards) is collapsed for mobile
/// into a single scrollable column: eyebrow → display headline with italic
/// "visual" → paragraph → 3 feature rows with soft circular icon chips →
/// overlapping 3-card "style deck" (Premium dark · Clean luxury · Warm
/// friendly) with realistic rotation + drop shadow. Footer "Start" advances
/// to AnalyzingPostsStep.
class StyleIntroStep extends GetView<OnboardingController> {
  const StyleIntroStep({super.key});

  static const List<({IconData icon, String label})> _features = [
    (icon: Icons.palette_outlined, label: 'Aesthetic moodboard'),
    (icon: Icons.auto_fix_high_outlined, label: 'On-brand templates'),
    (icon: Icons.remove_red_eye_outlined, label: 'Live post previews'),
  ];

  static const List<_StyleCard> _deck = [
    _StyleCard(
      tone: _CardTone.ink,
      label: 'Premium dark',
      sub: 'editorial · ivory · gold',
      rotationDeg: -6,
      offsetTop: 8,
      offsetLeft: 78,
    ),
    _StyleCard(
      tone: _CardTone.cream,
      label: 'Clean luxury',
      sub: 'serif · marble · soft',
      rotationDeg: 4,
      offsetTop: 56,
      offsetLeft: 0,
    ),
    _StyleCard(
      tone: _CardTone.coral,
      label: 'Warm friendly',
      sub: 'terracotta · handwritten',
      rotationDeg: -3,
      offsetTop: 152,
      offsetLeft: 64,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StepShell(
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STEP 5 OF 8 · PERSONALIZE',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontFamilyFallback: AppFonts.monoFallback,
                fontSize: 11,
                letterSpacing: 0.5,
                color: AppColors.accentInk,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: Responsive.scale(context, 38),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.0,
                  height: 1.05,
                  color: AppColors.ink,
                ),
                children: const [
                  TextSpan(text: "Let's match your\n"),
                  TextSpan(
                    text: 'visual',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(text: ' style.'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "You'll pick a few aesthetics that feel right for your brand. "
              "We'll personalize every cover, frame, and font from here.",
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(height: 24),
            ..._features.map(_FeatureRow.new),
            const SizedBox(height: 28),
            const _StyleCardDeck(cards: _deck),
            const SizedBox(height: 8),
          ],
        ),
      ),
      footer: FootBar(
        left: const _PrivacyCaption(),
        primary: FootBarPrimaryButton(
          label: 'Start',
          icon: Icons.arrow_forward,
          onPressed: controller.completeStyleIntro,
        ),
      ),
    );
  }
}

/// Reassurance microcopy that sits to the left of the primary CTA in the
/// FootBar. Lock icon + 3-line caption. Stays subdued (ink3, 11px) so it
/// reads as supporting text without competing with the action button.
class _PrivacyCaption extends StatelessWidget {
  const _PrivacyCaption();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 13,
            color: AppColors.ink3,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: AppColors.ink3,
                ),
                children: [
                  TextSpan(
                    text: 'Private workspace. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink2,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'We never post without your approval. Disconnect anytime.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(this.feature);

  final ({IconData icon, String label}) feature;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.line),
              ),
            ),
            child: Icon(feature.icon, size: 16, color: AppColors.ink2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.label,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.ink2,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Style card deck (Stack with 3 overlapping Positioned cards)
// ============================================================================

enum _CardTone { ink, cream, coral }

class _StyleCard {
  const _StyleCard({
    required this.tone,
    required this.label,
    required this.sub,
    required this.rotationDeg,
    required this.offsetTop,
    required this.offsetLeft,
  });

  final _CardTone tone;
  final String label;
  final String sub;
  final double rotationDeg;
  final double offsetTop;
  final double offsetLeft;
}

class _StyleCardDeck extends StatelessWidget {
  const _StyleCardDeck({required this.cards});

  final List<_StyleCard> cards;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < cards.length; i++)
            Positioned(
              top: cards[i].offsetTop,
              left: cards[i].offsetLeft,
              child: Transform.rotate(
                angle: cards[i].rotationDeg * math.pi / 180,
                child: _StyleCardTile(card: cards[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _StyleCardTile extends StatelessWidget {
  const _StyleCardTile({required this.card});

  final _StyleCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.cardHi,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: _TonePreview(tone: card.tone),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STYLE',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 10,
                    color: AppColors.ink4,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.label,
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontFamilyFallback: AppFonts.displayFallback,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  card.sub,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.ink3,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stylized "placeholder" art block at the top of each card. Matches the web
/// `<Placeholder tone="..." />` patterns: ink = dark editorial, cream = warm
/// neutral, coral = terracotta. A subtle diagonal sheen sells the depth.
class _TonePreview extends StatelessWidget {
  const _TonePreview({required this.tone});

  final _CardTone tone;

  @override
  Widget build(BuildContext context) {
    late final List<Color> colors;
    late final Color accent;
    late final IconData glyph;
    late final Color glyphColor;

    switch (tone) {
      case _CardTone.ink:
        colors = const [Color(0xFF1F1D2A), Color(0xFF0E0D14)];
        accent = const Color(0xFFD4B26A); // gold
        glyph = Icons.auto_awesome;
        glyphColor = const Color(0xFFEFE3C8);
        break;
      case _CardTone.cream:
        colors = const [Color(0xFFF7F0E2), Color(0xFFEADFC9)];
        accent = const Color(0xFFB89472);
        glyph = Icons.spa_outlined;
        glyphColor = const Color(0xFF6B4F36);
        break;
      case _CardTone.coral:
        colors = const [Color(0xFFF6D2BE), Color(0xFFE5A079)];
        accent = const Color(0xFF8A3E1B);
        glyph = Icons.local_florist_outlined;
        glyphColor = const Color(0xFF8A3E1B);
        break;
    }

    return Container(
      height: 150,
      width: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // diagonal sheen
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // soft accent orb top-right
          Positioned(
            top: -18,
            right: -18,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.22),
              ),
            ),
          ),
          // centered glyph
          Center(
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(glyph, size: 20, color: glyphColor),
            ),
          ),
          // bottom rule
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }
}
