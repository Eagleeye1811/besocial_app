import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/discover_controller/discover_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/discover_post_model.dart';

/// Format filter — mirrors the web `FilterBar`: a "Format" eyebrow label
/// followed by single-select pills, with a hairline divider beneath.
class DiscoverFilterBar extends GetView<DiscoverController> {
  const DiscoverFilterBar({super.key});

  static const Map<DiscoverFormat, String> _labels = {
    DiscoverFormat.all: 'All formats',
    DiscoverFormat.carousel: 'Carousel',
    DiscoverFormat.single: 'Single image',
    DiscoverFormat.video: 'Video',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(
                  child: Text(
                    'FORMAT',
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontFamilyFallback: AppFonts.monoFallback,
                      fontSize: 10.5,
                      letterSpacing: 0.6,
                      color: AppColors.ink4,
                    ),
                  ),
                ),
              ),
              for (final f in DiscoverFormat.values)
                _FilterPill(format: f, label: _labels[f]!),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Container(height: 1, color: AppColors.line2),
        ),
      ],
    );
  }
}

class _FilterPill extends GetView<DiscoverController> {
  final DiscoverFormat format;
  final String label;
  const _FilterPill({required this.format, required this.label});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final on = controller.selectedFormat.value == format;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Center(
          child: GestureDetector(
            onTap: () => controller.setFormat(format),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: on ? AppColors.accent : AppColors.white,
                border: Border.all(color: on ? AppColors.accent : AppColors.line),
                borderRadius: BorderRadius.circular(999),
                boxShadow: on ? null : AppShadows.card,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                  color: on ? Colors.white : AppColors.ink2,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
