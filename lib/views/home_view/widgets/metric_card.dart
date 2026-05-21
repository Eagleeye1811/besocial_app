import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';

/// One tile in the home metric grid. Mirrors the web `MetricCard`:
/// a mono-cased eyebrow up top, a large display value, an optional signed
/// delta line, and an optional trailing widget (e.g. sparkline).
class MetricCard extends StatelessWidget {
  final String eyebrow;
  final String? value;
  final String? delta;
  final MetricDeltaTone deltaTone;
  final Widget? trailing;

  const MetricCard({
    super.key,
    required this.eyebrow,
    this.value,
    this.delta,
    this.deltaTone = MetricDeltaTone.neutral,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: AppColors.ink4,
            ),
          ),
          const SizedBox(height: 10),
          if (value != null)
            Text(
              value!,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Text(
              delta!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _deltaColor(),
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(height: 8),
            trailing!,
          ],
        ],
      ),
    );
  }

  Color _deltaColor() {
    switch (deltaTone) {
      case MetricDeltaTone.good:
        return AppColors.good;
      case MetricDeltaTone.bad:
        return const Color(0xFFDC2626);
      case MetricDeltaTone.neutral:
        return AppColors.ink3;
    }
  }
}

enum MetricDeltaTone { good, bad, neutral }
