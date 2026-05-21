import 'package:get/get.dart';

import 'auth_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(AuthController.new);
  }
}
