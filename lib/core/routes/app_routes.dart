import 'package:get/get.dart';

/// Centralized route registry.
///
/// Route names are declared as `static const` strings so navigation calls
/// never reference raw string literals. The `routes` list is consumed by
/// `GetMaterialApp(getPages: AppRoutes().routes)` in `main.dart`.
///
/// Pattern (per `application-folder-structure.md`):
///   GetPage(
///     name: AppRoutes.`route`,
///     page: () => const `View`(),
///     binding: `Bindings`(),
///     transition: Transition.fadeIn,
///     middlewares: [/* AuthMiddleware() */],
///   )
class AppRoutes {
  AppRoutes._();

  // ==========================================
  // Route Names
  // ==========================================
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String inviteValidate = '/invite';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // ==========================================
  // Route Pages
  // Register each `GetPage` here as views + bindings are added under
  // `lib/views/` and `lib/controllers/`.
  // ==========================================
  static final List<GetPage> routes = <GetPage>[
    // GetPage(
    //   name: splash,
    //   page: () => const SplashView(),
    //   binding: SplashBindings(),
    //   transition: Transition.fade,
    // ),
  ];
}
