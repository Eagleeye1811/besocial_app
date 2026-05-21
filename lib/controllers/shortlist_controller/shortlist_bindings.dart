import 'package:get/get.dart';

import 'shortlist_controller.dart';

class ShortlistBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShortlistController>(ShortlistController.new);
  }
}
