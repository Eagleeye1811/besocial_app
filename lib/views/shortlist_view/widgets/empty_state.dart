import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_constants.dart';

/// Shown when the shortlist is empty. Mirrors the website's stacked-card
/// illustration with a CTA back to Discover.
class ShortlistEmptyState extends StatelessWidget {
  const ShortlistEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                _stackedCard(offset: const Offset(16, 12), rotation: 0.12),
                _stackedCard(offset: const Offset(0, 0), rotation: -0.04),
                _stackedCard(offset: const Offset(-16, 4), rotation: -0.16),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your shortlist is empty',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Heart posts on Discover and they'll land here, ready to "
            'generate from.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.ink3, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.explore_outlined, size: 16),
            label: const Text('Open Discover'),
            onPressed: () => Get.offAllNamed(AppRoutes.discover),
          ),
        ],
      ),
    );
  }

  Widget _stackedCard({required Offset offset, required double rotation}) {
    return Positioned.fill(
      child: Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppShadows.card,
            ),
          ),
        ),
      ),
    );
  }
}
