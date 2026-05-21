import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller/auth_bindings.dart';
import '../../controllers/splash_controller/splash_bindings.dart';
import '../../views/oauth_webview/screens/oauth_webview_view.dart';
import '../../views/request_access_view/screens/request_access_view.dart';
import '../../views/splash_view/screens/splash_view.dart';
import '../../views/welcome_view/screens/welcome_view.dart';
import '../services/auth_service.dart';
import '../theme/theme_constants.dart';
import 'auth_middleware.dart';
import 'package:get_it/get_it.dart';

/// Centralized route registry. Routes graduate from placeholder to full
/// view phase by phase; `home` is a stub today and gets replaced in Phase 6.
class AppRoutes {
  AppRoutes._();

  // ==========================================
  // Route names
  // ==========================================
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String requestAccess = '/request-access';
  static const String oauthWebview = '/oauth/webview';
  static const String home = '/home';

  // ==========================================
  // Route pages
  // ==========================================
  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
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
