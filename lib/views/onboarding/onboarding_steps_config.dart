import '../../core/routes/app_routes.dart';

/// Ordered list of onboarding step routes the wizard advances through.
///
/// The user-visible step counter (1–8) collapses some loading/transition
/// screens together — those have `displayStep == null`. The internal order
/// here matches `frontend/src/features/onboarding/steps-config.js`.
class OnboardingStep {
  final String route;
  final int? displayStep;

  const OnboardingStep({required this.route, this.displayStep});
}

class OnboardingFlow {
  OnboardingFlow._();

  static const int totalDisplaySteps = 8;

  static const List<OnboardingStep> steps = <OnboardingStep>[
    OnboardingStep(route: AppRoutes.welcome), // counted as step 1 on the web
    OnboardingStep(route: AppRoutes.onboardingBusinessType, displayStep: 2),
    OnboardingStep(route: AppRoutes.onboardingBrandDetails, displayStep: 3),
    OnboardingStep(route: AppRoutes.onboardingAnalyzingNiche),
    OnboardingStep(route: AppRoutes.onboardingNicheResults, displayStep: 4),
    OnboardingStep(route: AppRoutes.onboardingStyleIntro),
    OnboardingStep(route: AppRoutes.onboardingAnalyzingPosts),
    OnboardingStep(route: AppRoutes.onboardingDetectedStyle, displayStep: 5),
    OnboardingStep(route: AppRoutes.onboardingStyleSelection, displayStep: 5),
    OnboardingStep(route: AppRoutes.onboardingColorsVoice, displayStep: 6),
    OnboardingStep(route: AppRoutes.onboardingBrandAssets, displayStep: 7),
    OnboardingStep(route: AppRoutes.onboardingFetchingPosts),
    OnboardingStep(route: AppRoutes.onboardingInspiration, displayStep: 8),
  ];

  static String? next(String currentRoute) {
    final i = steps.indexWhere((s) => s.route == currentRoute);
    if (i < 0 || i >= steps.length - 1) return null;
    return steps[i + 1].route;
  }

  static String? previous(String currentRoute) {
    final i = steps.indexWhere((s) => s.route == currentRoute);
    if (i <= 0) return null;
    return steps[i - 1].route;
  }
}
