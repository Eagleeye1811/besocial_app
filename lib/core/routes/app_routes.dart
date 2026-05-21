import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common_widgets/dash_shell.dart';
import '../../controllers/auth_controller/auth_bindings.dart';
import '../../controllers/home_controller/home_bindings.dart';
import '../../controllers/onboarding_controller/onboarding_bindings.dart';
import '../../controllers/splash_controller/splash_bindings.dart';
import '../../views/home_view/screens/home_view.dart';
import '../../views/oauth_webview/screens/oauth_webview_view.dart';
import '../../views/onboarding/steps/analyzing_niche_step.dart';
import '../../views/onboarding/steps/analyzing_posts_step.dart';
import '../../views/onboarding/steps/brand_assets_step.dart';
import '../../views/onboarding/steps/brand_details_step.dart';
import '../../views/onboarding/steps/business_type_step.dart';
import '../../views/onboarding/steps/colors_voice_step.dart';
import '../../views/onboarding/steps/complete_step.dart';
import '../../views/onboarding/steps/detected_style_step.dart';
import '../../views/onboarding/steps/fetching_posts_step.dart';
import '../../views/onboarding/steps/generating_step.dart';
import '../../views/onboarding/steps/inspiration_step.dart';
import '../../views/onboarding/steps/niche_results_step.dart';
import '../../views/onboarding/steps/result_step.dart';
import '../../views/onboarding/steps/style_intro_step.dart';
import '../../views/onboarding/steps/style_selection_step.dart';
import '../../views/request_access_view/screens/request_access_view.dart';
import '../../views/splash_view/screens/splash_view.dart';
import '../../views/welcome_view/screens/welcome_view.dart';
import '../theme/theme_constants.dart';
import 'auth_middleware.dart';

/// Centralized route registry. Routes graduate from placeholder to full
/// view phase by phase; the dashboard cluster (`/home` real, `/discover`,
/// `/shortlist`, `/drafts`, `/brand`) all share [DashShell] and bottom-nav
/// between each other.
class AppRoutes {
  AppRoutes._();

  // ==========================================
  // Auth / shell
  // ==========================================
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String requestAccess = '/request-access';
  static const String oauthWebview = '/oauth/webview';

  // ==========================================
  // Dashboard cluster
  // ==========================================
  static const String home = '/home';
  static const String discover = '/discover';
  static const String shortlist = '/shortlist';
  static const String drafts = '/drafts';
  static const String brand = '/brand';

  // ==========================================
  // Onboarding wizard
  // ==========================================
  static const String onboardingBusinessType = '/onboarding/business-type';
  static const String onboardingBrandDetails = '/onboarding/brand-details';
  static const String onboardingAnalyzingNiche = '/onboarding/analyzing-niche';
  static const String onboardingNicheResults = '/onboarding/niche-results';
  static const String onboardingStyleIntro = '/onboarding/style-intro';
  static const String onboardingAnalyzingPosts = '/onboarding/analyzing-posts';
  static const String onboardingDetectedStyle = '/onboarding/detected-style';
  static const String onboardingStyleSelection = '/onboarding/style-selection';
  static const String onboardingColorsVoice = '/onboarding/colors-voice';
  static const String onboardingBrandAssets = '/onboarding/brand-assets';
  static const String onboardingFetchingPosts = '/onboarding/fetching-posts';
  static const String onboardingInspiration = '/onboarding/inspiration';

  // JWT-gated tail
  static const String onboardingGenerating = '/onboarding/generating';
  static const String onboardingResult = '/onboarding/result';
  static const String onboardingComplete = '/onboarding/complete';

  // ==========================================
  // Route pages
  // ==========================================
  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    // ----- Auth / shell -----
    GetPage<void>(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBindings(),
      transition: Transition.fade,
    ),
    GetPage<void>(
      name: welcome,
      page: () => const WelcomeView(),
      binding: AuthBindings(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: requestAccess,
      page: () => const RequestAccessView(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: oauthWebview,
      page: () => const OAuthWebViewView(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),

    // ----- Dashboard cluster -----
    GetPage<void>(
      name: home,
      page: () => const HomeView(),
      binding: HomeBindings(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: discover,
      page: () => const _DashPlaceholder(
        tab: DashTab.discover,
        phase: 'Phase 7',
        title: 'Discover',
      ),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: shortlist,
      page: () => const _DashPlaceholder(
        tab: DashTab.shortlist,
        phase: 'Phase 8',
        title: 'Shortlist',
      ),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: drafts,
      page: () => const _DashPlaceholder(
        tab: DashTab.drafts,
        phase: 'Phase 10',
        title: 'Drafts',
      ),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: brand,
      page: () => const _DashPlaceholder(
        tab: DashTab.brand,
        phase: 'Phase 11',
        title: 'Brand',
      ),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),

    // ----- Onboarding -----
    GetPage<void>(
      name: onboardingBusinessType,
      page: () => const BusinessTypeStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage<void>(
      name: onboardingBrandDetails,
      page: () => const BrandDetailsStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage<void>(
      name: onboardingAnalyzingNiche,
      page: () => const AnalyzingNicheStep(),
      binding: OnboardingBindings(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: onboardingNicheResults,
      page: () => const NicheResultsStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage<void>(
      name: onboardingStyleIntro,
      page: () => const StyleIntroStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage<void>(
      name: onboardingAnalyzingPosts,
      page: () => const AnalyzingPostsStep(),
      binding: OnboardingBindings(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: onboardingDetectedStyle,
      page: () => const DetectedStyleStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage<void>(
      name: onboardingStyleSelection,
      page: () => const StyleSelectionStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage<void>(
      name: onboardingColorsVoice,
      page: () => const ColorsVoiceStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage<void>(
      name: onboardingBrandAssets,
      page: () => const BrandAssetsStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage<void>(
      name: onboardingFetchingPosts,
      page: () => const FetchingPostsStep(),
      binding: OnboardingBindings(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: onboardingInspiration,
      page: () => const InspirationStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
    ),

    // ----- JWT-gated tail -----
    GetPage<void>(
      name: onboardingGenerating,
      page: () => const GeneratingStep(),
      binding: OnboardingBindings(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: onboardingResult,
      page: () => const ResultStep(),
      binding: OnboardingBindings(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: onboardingComplete,
      page: () => const CompleteStep(),
      binding: OnboardingBindings(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
  ];
}

/// Stand-in for not-yet-built dashboard tabs. Wrapped in [DashShell] so the
/// bottom-nav still works, just shows a "coming in Phase N" body.
class _DashPlaceholder extends StatelessWidget {
  final DashTab tab;
  final String phase;
  final String title;

  const _DashPlaceholder({
    required this.tab,
    required this.phase,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return DashShell(
      currentTab: tab,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Arrives in $phase.',
                style: TextStyle(fontSize: 13, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
