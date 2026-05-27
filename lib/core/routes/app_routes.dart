import 'package:get/get.dart';

import '../../common_widgets/dash_shell.dart';
import '../../controllers/auth_controller/auth_bindings.dart';
import '../../controllers/brand_controller/brand_bindings.dart';
import '../../controllers/calendar_controller/calendar_bindings.dart';
import '../../controllers/discover_controller/discover_bindings.dart';
import '../../controllers/drafts_controller/drafts_bindings.dart';
import '../../controllers/home_controller/home_bindings.dart';
import '../../controllers/onboarding_controller/onboarding_bindings.dart';
import '../../controllers/settings_controller/settings_bindings.dart';
import '../../controllers/shortlist_controller/shortlist_bindings.dart';
import '../../controllers/splash_controller/splash_bindings.dart';
import '../../views/brand_view/screens/brand_view.dart';
import '../../views/calendar_view/screens/calendar_view.dart';
import '../../views/discover_view/screens/discover_view.dart';
import '../../views/drafts_view/screens/drafts_view.dart';
import '../../views/home_view/screens/home_view.dart';
import '../../views/settings_view/screens/settings_view.dart';
import '../../views/shortlist_view/screens/shortlist_view.dart';
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
  static const String settings = '/settings';

  // ==========================================
  // Dashboard cluster
  // ==========================================
  static const String home = '/home';
  static const String discover = '/discover';
  static const String shortlist = '/shortlist';
  static const String drafts = '/drafts';
  static const String calendar = '/calendar';
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
    GetPage<void>(
      name: settings,
      page: () => const SettingsView(),
      binding: SettingsBindings(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware()],
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
      page: () => const DiscoverView(),
      binding: DiscoverBindings(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: shortlist,
      page: () => const ShortlistView(),
      binding: ShortlistBindings(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: drafts,
      page: () => const DraftsView(),
      binding: DraftsBindings(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: calendar,
      page: () => const CalendarView(),
      binding: CalendarBindings(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage<void>(
      name: brand,
      page: () => const BrandView(),
      binding: BrandBindings(),
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

