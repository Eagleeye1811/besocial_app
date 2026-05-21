import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../auth_controller/auth_controller.dart';
import 'onboarding_controller.dart';

/// Permanent binding so the wizard state survives every step transition.
/// `Get.put(... permanent: true)` is idempotent — re-entering an onboarding
/// route reuses the existing instance instead of resetting it.
class OnboardingBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OnboardingController>()) {
      Get.put<OnboardingController>(OnboardingController(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    // Touch GetIt to surface unwired deps early.
    GetIt.I.isRegistered<OnboardingController>();
  }
}
