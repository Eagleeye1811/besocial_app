import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/discover_post_model.dart';

/// Format chips for the discover feed. Mirrors `FilterBar.jsx` — four
/// pill toggles in a horizontal scroller, single-select.
class DiscoverFilterBar extends GetView<DiscoverController> {
  const DiscoverFilterBar({super.key});

  static const Map<DiscoverFormat, String> _labels = {
    DiscoverFormat.all: 'All formats',
    DiscoverFormat.carousel: 'Carousels',
    DiscoverFormat.single: 'Single image',
    DiscoverFormat.video: 'Video',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: DiscoverFormat.values
            .map((f) => _FilterChip(format: f, label: _labels[f]!))
            .toList(),
      ),
    );
  }
}

class _FilterChip extends GetView<DiscoverController> {
  final DiscoverFormat format;
  final String label;
  const _FilterChip({required this.format, required this.label});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOn = controller.selectedFormat.value == format;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () => controller.setFormat(format),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isOn ? AppColors.accentSoft : AppColors.white,
              border: Border.all(
                color: isOn ? AppColors.accent : AppColors.line,
                width: isOn ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isOn ? AppColors.accentInk : AppColors.ink2,
              ),
            ),
          ),
        ),
      );
    });
  }
}
