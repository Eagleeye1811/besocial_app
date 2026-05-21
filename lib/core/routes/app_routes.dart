import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../controllers/auth_controller/auth_bindings.dart';
import '../../controllers/onboarding_controller/onboarding_bindings.dart';
import '../../controllers/splash_controller/splash_bindings.dart';
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
import '../services/auth_service.dart';
import '../theme/theme_constants.dart';
import 'auth_middleware.dart';

/// Centralized route registry. Routes graduate from placeholder to full
/// view phase by phase; `home` is a stub today and gets replaced in Phase 6.
class AppRoutes {
  AppRoutes._();

  // ==========================================
  // Auth / shell
  // ==========================================
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String requestAccess = '/request-access';
  static const String oauthWebview = '/oauth/webview';
  static const String home = '/home';

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
    GetPage<void>(
      name: home,
      page: () => const _HomePlaceholderView(),
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

/// Temporary stand-in until Phase 6 lands the real dashboard home. Lets us
/// verify the full sign-in round-trip end-to-end.
class _HomePlaceholderView extends StatelessWidget {
  const _HomePlaceholderView();

  @override
  Widget build(BuildContext context) {
    final auth = GetIt.I<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Get.offAllNamed(AppRoutes.welcome);
            },
          ),
        ],
      ),
      body: Center(
        child: Obx(() {
          final user = auth.currentUserRx.value;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user == null ? 'Signed in.' : 'Signed in as',
                  style: TextStyle(color: AppColors.ink3, fontSize: 14),
                ),
                if (user != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontFamily: AppFonts.ui,
                      fontFamilyFallback: AppFonts.uiFallback,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Dashboard home arrives in Phase 6.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.ink3, fontSize: 13),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
