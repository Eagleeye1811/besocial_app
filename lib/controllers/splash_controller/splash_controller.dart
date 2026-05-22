import 'dart:async';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logger_service.dart';

/// Decides where the user lands at cold start: home if a stored JWT still
/// validates, welcome otherwise. Lives only on the splash route.
class SplashController extends GetxController {
  /// Hard ceiling on the boot check. If `bootFromStorage` ever stalls — a
  /// hung keystore call, a wedged HTTP socket, anything — we still route
  /// the user somewhere so the app doesn't sit on the splash forever.
  static const Duration _bootTimeout = Duration(seconds: 10);

  final AuthService _auth = GetIt.I<AuthService>();
  final LoggerService _log = GetIt.I<LoggerService>();

  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    try {
      await _auth.bootFromStorage().timeout(_bootTimeout);
    } on TimeoutException {
      _log.w('Splash boot timed out after ${_bootTimeout.inSeconds}s; '
          'falling back to welcome');
    } catch (e, st) {
      // `bootFromStorage` is meant to swallow its own errors, but belt-
      // and-braces in case something slips through.
      _log.e('Splash boot threw unexpectedly; falling back to welcome',
          error: e, stackTrace: st);
    }

    if (_auth.isAuthenticated) {
      Get.offAllNamed<void>(AppRoutes.home);
    } else {
      Get.offAllNamed<void>(AppRoutes.welcome);
    }
  }
}
