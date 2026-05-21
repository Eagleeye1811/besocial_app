import 'package:get/get.dart';

import 'discover_controller.dart';

class DiscoverBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscoverController>(DiscoverController.new);
  }
}
