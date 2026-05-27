import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';

/// Display-only refresh cadence banner, mirroring the web `RefreshNotice`:
/// a "Posts refresh every 12 hours" eyebrow over a live "Next refresh in:
/// Xh Ym" countdown. There is no manual trigger on the web Discover page.
class RefreshNotice extends GetView<DiscoverController> {
  const RefreshNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'POSTS REFRESH EVERY 12 HOURS',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 10.5,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w500,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            final countdown = _formatCountdown(controller.timeUntilRefresh.value);
            return RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: AppFonts.ui,
                  fontFamilyFallback: AppFonts.uiFallback,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                children: [
                  const TextSpan(text: 'Next refresh in: '),
                  TextSpan(
                    text: countdown,
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // "Xh Ym", "Xm", or "--" when unknown/elapsed. Matches the web formatter.
  static String _formatCountdown(Duration? remaining) {
    if (remaining == null || remaining <= Duration.zero) return '--';
    final totalMinutes = remaining.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }
}
