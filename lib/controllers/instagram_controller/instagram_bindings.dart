import 'package:get/get.dart';

import 'instagram_controller.dart';

/// `permanent: true` so the connection state is shared across Brand,
/// Settings, and any future surface that wants to gate behind `connected`.
class InstagramBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<InstagramController>()) {
      Get.put<InstagramController>(InstagramController(), permanent: true);
    }
  }
}
