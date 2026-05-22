import 'package:get/get.dart';

import 'splash_controller.dart';

/// `Get.put` (eager) instead of `Get.lazyPut` is intentional: [SplashView]
/// is a plain `StatelessWidget` that never resolves the controller, so a
/// lazy registration would never instantiate it and `onReady` (where the
/// routing decision happens) would never fire — the app would hang on the
/// splash forever.
class SplashBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}
