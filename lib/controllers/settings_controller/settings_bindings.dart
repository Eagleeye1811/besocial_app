import 'package:get/get.dart';

import '../instagram_controller/instagram_bindings.dart';
import 'settings_controller.dart';

/// Pulls in [InstagramBindings] so the Settings IG row resolves the shared
/// permanent controller, then registers the thin settings controller.
class SettingsBindings extends Bindings {
  @override
  void dependencies() {
    InstagramBindings().dependencies();
    Get.lazyPut<SettingsController>(SettingsController.new);
  }
}
