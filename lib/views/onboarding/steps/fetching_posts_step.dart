import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/step_shell.dart';

/// Loading screen between brand-assets and inspiration. Mirrors
/// `FetchingPostsStep.jsx` — animated checklist of what we're pulling in.
/// On mount: load `/api/v1/onboarding/feed`, then auto-advance.
class FetchingPostsStep extends StatefulWidget {
  const FetchingPostsStep({super.key});

  @override
  State<FetchingPostsStep> createState() => _FetchingPostsStepState();
}

class _FetchingPostsStepState extends State<FetchingPostsStep> {
  final OnboardingController _c = Get.find<OnboardingController>();

  static const List<String> _lines = <String>[
    'Fetching the best posts for you',
    'Understanding your competitors in your niche',
    "Sampling what's trending in your category",
    'Filtering for posts that matched your visual style',
    'Curating a swipeable deck of inspiration',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _c.loadInspirationFeed());
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      showAppBar: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Building your inspiration deck',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 24),
            ..._lines.map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(line,
                          style: TextStyle(
                              fontSize: 14, color: AppColors.ink2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final err = _c.errorMessage.value;
              if (err == null) return const SizedBox.shrink();
              return Text(
                err,
                style:
                    const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
              );
            }),
          ],
        ),
      ),
    );
  }
}
