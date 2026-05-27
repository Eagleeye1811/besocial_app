import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';

/// Segmented Grid / Swipe toggle. Mirrors the web `ModeToggle` — a pill on a
/// `surface2` track, white-on-active with an accent icon when selected.
class DiscoverModeToggle extends GetView<DiscoverController> {
  const DiscoverModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Obx(() {
          final mode = controller.viewMode.value;
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              border: Border.all(color: AppColors.line2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Segment(
                  label: 'Grid',
                  icon: Icons.grid_view_rounded,
                  active: mode == DiscoverViewMode.grid,
                  onTap: () => controller.setViewMode(DiscoverViewMode.grid),
                ),
                const SizedBox(width: 2),
                _Segment(
                  label: 'Swipe',
                  icon: Icons.favorite,
                  active: mode == DiscoverViewMode.swipe,
                  onTap: () => controller.setViewMode(DiscoverViewMode.swipe),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.white : Colors.transparent,
          border: Border.all(
            color: active ? AppColors.line : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x0F18181B),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? AppColors.accent : AppColors.ink3,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.ui,
                fontFamilyFallback: AppFonts.uiFallback,
                fontSize: 13.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.ink : AppColors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
