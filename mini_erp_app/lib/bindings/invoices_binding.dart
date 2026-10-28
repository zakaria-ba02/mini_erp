import 'package:get/get.dart';

import '../controller/invoices_controller.dart';
import '../data/providers/costing_provider.dart';
import '../data/providers/customers_provider.dart';
import '../data/providers/invoices_provider.dart';
import '../data/repositories/costing_repository.dart';
import '../data/repositories/customers_repository.dart';
import '../data/repositories/invoices_repository.dart';

void _ensureInvoiceDeps() {
  if (!Get.isRegistered<CustomersProvider>()) {
    Get.lazyPut<CustomersProvider>(() => CustomersProvider(), fenix: true);
  }
  if (!Get.isRegistered<CustomersRepository>()) {
    Get.lazyPut<CustomersRepository>(
      () => CustomersRepository(Get.find<CustomersProvider>()),
      fenix: true,
    );
  }
  if (!Get.isRegistered<CostingProvider>()) {
    Get.lazyPut<CostingProvider>(() => CostingProvider(), fenix: true);
  }
  if (!Get.isRegistered<CostingRepository>()) {
    Get.lazyPut<CostingRepository>(
      () => CostingRepository(Get.find<CostingProvider>()),
      fenix: true,
    );
  }
  if (!Get.isRegistered<InvoicesProvider>()) {
    Get.lazyPut<InvoicesProvider>(() => InvoicesProvider(), fenix: true);
  }
  if (!Get.isRegistered<InvoicesRepository>()) {
    Get.lazyPut<InvoicesRepository>(
      () => InvoicesRepository(Get.find<InvoicesProvider>()),
      fenix: true,
    );
  }
}

class InvoicesListBinding extends Bindings {
  @override
  void dependencies() {
    _ensureInvoiceDeps();
    Get.lazyPut<InvoicesListController>(
      () => InvoicesListController(
        Get.find<InvoicesRepository>(),
        Get.find<CustomersRepository>(),
      ),
    );
  }
}

class InvoiceFormBinding extends Bindings {
  @override
  void dependencies() {
    _ensureInvoiceDeps();
    Get.lazyPut<InvoiceFormController>(
      () => InvoiceFormController(
        Get.find<InvoicesRepository>(),
        Get.find<CustomersRepository>(),
        Get.find<CostingRepository>(),
      ),
    );
  }
}

class InvoiceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    _ensureInvoiceDeps();
    Get.lazyPut<InvoiceDetailsController>(
      () => InvoiceDetailsController(Get.find<InvoicesRepository>()),
    );
  }
}
