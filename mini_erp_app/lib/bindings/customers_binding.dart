import 'package:get/get.dart';

import '../controller/customer_account_controller.dart';
import '../controller/customer_settlements_controller.dart';
import '../controller/customers_controller.dart';
import '../data/providers/customers_provider.dart';
import '../data/providers/invoices_provider.dart';
import '../data/providers/payments_provider.dart';
import '../data/repositories/customers_repository.dart';
import '../data/repositories/invoices_repository.dart';
import '../data/repositories/payments_repository.dart';

class CustomersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomersProvider>()) {
      Get.lazyPut<CustomersProvider>(() => CustomersProvider(), fenix: true);
    }
    if (!Get.isRegistered<CustomersRepository>()) {
      Get.lazyPut<CustomersRepository>(
        () => CustomersRepository(Get.find<CustomersProvider>()),
        fenix: true,
      );
    }
    Get.lazyPut<CustomersController>(
      () => CustomersController(Get.find<CustomersRepository>()),
    );
  }
}

class CustomerFormBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomersProvider>()) {
      Get.lazyPut<CustomersProvider>(() => CustomersProvider(), fenix: true);
    }
    if (!Get.isRegistered<CustomersRepository>()) {
      Get.lazyPut<CustomersRepository>(
        () => CustomersRepository(Get.find<CustomersProvider>()),
        fenix: true,
      );
    }
    Get.lazyPut<CustomerFormController>(
      () => CustomerFormController(Get.find<CustomersRepository>()),
    );
  }
}

class CustomerDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomersProvider>()) {
      Get.lazyPut<CustomersProvider>(() => CustomersProvider(), fenix: true);
    }
    if (!Get.isRegistered<CustomersRepository>()) {
      Get.lazyPut<CustomersRepository>(
        () => CustomersRepository(Get.find<CustomersProvider>()),
        fenix: true,
      );
    }
    Get.lazyPut<CustomerDetailsController>(
      () => CustomerDetailsController(Get.find<CustomersRepository>()),
    );
  }
}

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomersProvider>()) {
      Get.lazyPut<CustomersProvider>(() => CustomersProvider(), fenix: true);
    }
    if (!Get.isRegistered<CustomersRepository>()) {
      Get.lazyPut<CustomersRepository>(
        () => CustomersRepository(Get.find<CustomersProvider>()),
        fenix: true,
      );
    }
    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(Get.find<CustomersRepository>()),
    );
  }
}

class CustomerAccountBinding extends Bindings {
  @override
  void dependencies() {
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
    Get.lazyPut<CustomerAccountController>(
      () => CustomerAccountController(
        Get.find<CustomersRepository>(),
        Get.find<InvoicesRepository>(),
        Get.find<PaymentsRepository>(),
      ),
    );
  }
}

class CustomerSettlementsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomersProvider>()) {
      Get.lazyPut<CustomersProvider>(() => CustomersProvider(), fenix: true);
    }
    if (!Get.isRegistered<CustomersRepository>()) {
      Get.lazyPut<CustomersRepository>(
        () => CustomersRepository(Get.find<CustomersProvider>()),
        fenix: true,
      );
    }
    Get.lazyPut<CustomerSettlementsController>(
      () => CustomerSettlementsController(Get.find<CustomersRepository>()),
    );
  }
}
