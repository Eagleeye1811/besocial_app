import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';

/// Compact banner that surfaces the countdown until the next automatic
/// discover refresh and offers a manual "Pull fresh" trigger. Mirrors
/// `RefreshNotice.jsx`.
class RefreshNotice extends GetView<DiscoverController> {
  const RefreshNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final remaining = controller.timeUntilRefresh.value;
      final busy = controller.isManualRefreshing.value;
      final err = controller.refreshError.value;

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule, size: 16, color: AppColors.ink3),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                err ?? (remaining != null
                    ? 'Next refresh in ${_format(remaining)}'
                    : "We'll pull a fresh batch on a regular cadence."),
                style: TextStyle(
                  fontSize: 12.5,
                  color: err != null ? const Color(0xFFDC2626) : AppColors.ink2,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: busy ? null : controller.triggerManualRefresh,
              icon: busy
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: Text(busy ? 'Pulling…' : 'Pull fresh'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 32),
              ),
            ),
          ],
        ),
      );
    });
  }

  static String _format(Duration d) {
    if (d.inMinutes < 1) return 'a moment';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }
}
