import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logger_service.dart';

/// Decides where the user lands at cold start: home if a stored JWT still
/// validates, welcome otherwise. Lives only on the splash route.
class SplashController extends GetxController {
  final AuthService _auth = GetIt.I<AuthService>();
  final LoggerService _log = GetIt.I<LoggerService>();

  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    try {
      await _auth.bootFromStorage();
    } catch (e, st) {
      _log.e('Splash boot failed; falling back to welcome',
          error: e, stackTrace: st);
    }
    if (_auth.isAuthenticated) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
