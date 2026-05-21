import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/step_shell.dart';

/// Loading screen between step 3 and step 4: triggers `POST /analyze` and
/// polls `GET /session` until terminal. Mirrors `AnalyzingNicheStep.jsx`'s
/// "Finding your niche" / "Working" checklist (simplified to a single
/// progress indicator + rotating headline copy on mobile).
class AnalyzingNicheStep extends StatefulWidget {
  const AnalyzingNicheStep({super.key});

  @override
  State<AnalyzingNicheStep> createState() => _AnalyzingNicheStepState();
}

class _AnalyzingNicheStepState extends State<AnalyzingNicheStep> {
  final OnboardingController _c = Get.find<OnboardingController>();

  static const List<String> _captions = <String>[
    'Finding your niche',
    'Reading your last 30 posts',
    'Sampling competitors in your category',
    'Mapping topics and hashtags',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.beginAnalysis());
  }

  @override
  void dispose() {
    _c.cancelAnalysis();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      showAppBar: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Analyzing your account',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),
            ..._captions.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  c,
                  style: TextStyle(fontSize: 14, color: AppColors.ink3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final err = _c.errorMessage.value;
              if (err == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  err,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
