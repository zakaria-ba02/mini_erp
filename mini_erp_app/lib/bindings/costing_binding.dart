import 'package:get/get.dart';

import '../controller/costing_controller.dart';
import '../data/providers/costing_provider.dart';
import '../data/repositories/costing_repository.dart';

void _ensureCostingDeps() {
  if (!Get.isRegistered<CostingProvider>()) {
    Get.lazyPut<CostingProvider>(() => CostingProvider(), fenix: true);
  }
  if (!Get.isRegistered<CostingRepository>()) {
    Get.lazyPut<CostingRepository>(
      () => CostingRepository(Get.find<CostingProvider>()),
      fenix: true,
    );
  }
}

class CostingListBinding extends Bindings {
  @override
  void dependencies() {
    _ensureCostingDeps();
    Get.lazyPut<CostingListController>(
      () => CostingListController(Get.find<CostingRepository>()),
    );
  }
}

class CostFormBinding extends Bindings {
  @override
  void dependencies() {
    _ensureCostingDeps();
    Get.lazyPut<CostFormController>(
      () => CostFormController(Get.find<CostingRepository>()),
    );
  }
}

class CostDetailsBinding extends Bindings {
  @override
  void dependencies() {
    _ensureCostingDeps();
    Get.lazyPut<CostDetailsController>(
      () => CostDetailsController(Get.find<CostingRepository>()),
    );
  }
}
