import 'package:get/get.dart';

import '../controller/customer_portal_controller.dart';
import '../data/providers/customers_provider.dart';
import '../data/providers/invoices_provider.dart';
import '../data/providers/payments_provider.dart';
import '../data/repositories/customers_repository.dart';
import '../data/repositories/invoices_repository.dart';
import '../data/repositories/payments_repository.dart';
import '../data/repositories/users_repository.dart';

void _ensureCustomerPortalDeps() {
  if (!Get.isRegistered<CustomersProvider>()) {
    Get.lazyPut<CustomersProvider>(() => CustomersProvider(), fenix: true);
  }
  if (!Get.isRegistered<CustomersRepository>()) {
    Get.lazyPut<CustomersRepository>(
      () => CustomersRepository(Get.find<CustomersProvider>()),
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
  if (!Get.isRegistered<PaymentsProvider>()) {
    Get.lazyPut<PaymentsProvider>(() => PaymentsProvider(), fenix: true);
  }
  if (!Get.isRegistered<PaymentsRepository>()) {
    Get.lazyPut<PaymentsRepository>(
      () => PaymentsRepository(Get.find<PaymentsProvider>()),
      fenix: true,
    );
  }
}

class CustomerPortalBinding extends Bindings {
  @override
  void dependencies() {
    _ensureCustomerPortalDeps();
    Get.lazyPut<CustomerShellController>(() => CustomerShellController());
    Get.lazyPut<CustomerHomeController>(
      () => CustomerHomeController(
        Get.find<CustomersRepository>(),
        Get.find<InvoicesRepository>(),
        Get.find<PaymentsRepository>(),
      ),
    );
    Get.lazyPut<CustomerInvoicesController>(
      () => CustomerInvoicesController(Get.find<InvoicesRepository>()),
    );
    Get.lazyPut<CustomerPaymentsController>(
      () => CustomerPaymentsController(Get.find<PaymentsRepository>()),
    );
    Get.lazyPut<CustomerSettingsController>(
      () => CustomerSettingsController(
        Get.find<CustomersRepository>(),
        Get.find<UsersRepository>(),
      ),
    );
  }
}

class CustomerInvoiceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    _ensureCustomerPortalDeps();
    Get.lazyPut<CustomerInvoiceDetailsController>(
      () => CustomerInvoiceDetailsController(Get.find<InvoicesRepository>()),
    );
  }
}

class CustomerPaymentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    _ensureCustomerPortalDeps();
    Get.lazyPut<CustomerPaymentDetailsController>(
      () => CustomerPaymentDetailsController(Get.find<PaymentsRepository>()),
    );
  }
}
