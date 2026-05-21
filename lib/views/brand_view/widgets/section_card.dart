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
