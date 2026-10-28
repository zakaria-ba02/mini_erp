import 'package:get/get.dart';

import '../controller/audit_logs_controller.dart';
import '../data/providers/audit_logs_provider.dart';
import '../data/repositories/audit_logs_repository.dart';

class AuditLogsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuditLogsProvider>()) {
      Get.lazyPut<AuditLogsProvider>(() => AuditLogsProvider(), fenix: true);
    }
    if (!Get.isRegistered<AuditLogsRepository>()) {
      Get.lazyPut<AuditLogsRepository>(
        () => AuditLogsRepository(Get.find<AuditLogsProvider>()),
        fenix: true,
      );
    }
    Get.lazyPut<AuditLogsController>(
      () => AuditLogsController(Get.find<AuditLogsRepository>()),
    );
  }
}
