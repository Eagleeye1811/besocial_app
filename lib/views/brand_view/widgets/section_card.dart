import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';

/// Shared chrome for each of Brand's five sections. Mirrors the website's
/// per-section card: eyebrow, title, content slot, save button row.
class BrandSectionCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget child;
  final Widget? actions;

  const BrandSectionCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 11,
              letterSpacing: 0.44,
              color: AppColors.ink4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          child,
          if (actions != null) ...[
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerRight, child: actions!),
          ],
        ],
      ),
    );
  }
}

/// Sub-section heading inside a section card (e.g. "Color palette").
/// Mirrors VoiceVisualSection.jsx SubsectionLabel. Optional [trailing] sits
/// flush-right (used for the "N / 3" style counter).
class BrandSubLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const BrandSubLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: TextStyle(
        fontFamily: AppFonts.ui,
        fontFamilyFallback: AppFonts.uiFallback,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.ink2,
        letterSpacing: -0.06,
      ),
    );
    if (trailing == null) return label;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [Flexible(child: label), trailing!],
    );
  }
}

/// A pill/chip selector cell. Mirrors the web's active `Chip` styling.
class BrandChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const BrandChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : AppColors.surface,
          border: Border.all(
            color: active ? AppColors.accent : AppColors.line,
            width: active ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.ui,
            fontFamilyFallback: AppFonts.uiFallback,
            fontSize: 12.5,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? AppColors.accentInk : AppColors.ink2,
          ),
        ),
      ),
    );
  }
}

/// Mono counter rendered to the right of a sub-label (e.g. "2 / 3").
class BrandCounter extends StatelessWidget {
  final int count;
  final int max;

  const BrandCounter({super.key, required this.count, required this.max});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count / $max',
      style: TextStyle(
        fontFamily: AppFonts.mono,
        fontFamilyFallback: AppFonts.monoFallback,
        fontSize: 11,
        color: AppColors.ink3,
      ),
    );
  }
}

/// Italic explainer shown when a section is locked (niche/personalization not
/// yet set during onboarding). Mirrors BrandSection.jsx disabledReason.
class BrandDisabledReason extends StatelessWidget {
  final String text;

  const BrandDisabledReason(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.ui,
          fontFamilyFallback: AppFonts.uiFallback,
          fontSize: 12,
          color: AppColors.ink3,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Grays out and blocks input on a section body when [disabled]. Mirrors
/// BrandSection.jsx opacity/pointerEvents behaviour.
class BrandDisabledGate extends StatelessWidget {
  final bool disabled;
  final Widget child;

  const BrandDisabledGate({
    super.key,
    required this.disabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!disabled) return child;
    return Opacity(
      opacity: 0.55,
      child: IgnorePointer(child: child),
    );
  }
}

class BrandLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefix;
  final int minLines;
  final int maxLines;

  const BrandLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefix,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 10.5,
              letterSpacing: 0.4,
              color: AppColors.ink4,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefix,
            ),
          ),
        ],
      ),
    );
  }
}
