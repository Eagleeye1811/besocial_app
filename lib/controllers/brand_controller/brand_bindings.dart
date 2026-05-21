import 'package:get/get.dart';

import 'brand_controller.dart';

class BrandBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BrandController>(BrandController.new);
  }
}
