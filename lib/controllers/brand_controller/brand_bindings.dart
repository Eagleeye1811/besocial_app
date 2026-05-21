import 'package:get/get.dart';

import '../instagram_controller/instagram_bindings.dart';
import 'brand_controller.dart';

class BrandBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BrandController>(BrandController.new);
    // InstagramController is shared (permanent) across surfaces — chain in
    // its bindings so the Brand `InstagramSection` can resolve it.
    InstagramBindings().dependencies();
  }
}
