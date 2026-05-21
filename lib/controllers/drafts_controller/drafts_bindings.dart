import 'package:get/get.dart';

import 'drafts_controller.dart';

class DraftsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DraftsController>(DraftsController.new);
  }
}
