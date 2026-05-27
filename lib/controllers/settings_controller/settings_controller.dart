import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../instagram_controller/instagram_controller.dart';

/// Drives the Settings screen. Thin — the heavy state lives elsewhere
/// (AuthService for the user, InstagramController for IG status). This
/// controller exists so the view can read everything via one
/// `GetView<SettingsController>` rather than chaining `GetIt.I<...>()`
/// calls inline.
class SettingsController extends GetxController {
  final AuthService _auth = GetIt.I<AuthService>();

  /// Static version string — keeps `package_info_plus` out of the dep tree.
  /// Bump this on each release; sourced from `pubspec.yaml` by hand for now.
  static const String appVersion = '1.0.0';

  Rxn<UserModel> get user => _auth.currentUserRx;

  Future<void> logout() async {
    await _auth.logout();
    // The IG controller is a permanent GetX dep, so it isn't disposed by
    // offAllNamed — clear it explicitly so the next account starts clean.
    if (Get.isRegistered<InstagramController>()) {
      Get.find<InstagramController>().reset();
    }
    Get.offAllNamed(AppRoutes.welcome);
  }
}
