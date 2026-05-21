import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';

/// Mirrors `frontend/src/components/patterns/StepHead.jsx` — a small
/// mono-cased eyebrow, a large display title, and an optional supporting
/// paragraph. Sits at the top of every numbered onboarding step.
class StepHead extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? sub;

  const StepHead({
    super.key,
    this.eyebrow,
    required this.title,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.44,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.15,
            letterSpacing: -0.6,
            color: AppColors.ink,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 10),
          Text(
            sub!,
            style: TextStyle(
              fontFamily: AppFonts.ui,
              fontFamilyFallback: AppFonts.uiFallback,
              fontSize: 15,
              height: 1.5,
              color: AppColors.ink2,
            ),
          ),
        ],
      ],
    );
  }
}
