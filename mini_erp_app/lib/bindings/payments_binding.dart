import 'package:get/get.dart';

import '../controller/payments_controller.dart';
import '../data/providers/customers_provider.dart';
import '../data/providers/payments_provider.dart';
import '../data/repositories/customers_repository.dart';
import '../data/repositories/payments_repository.dart';

void _ensurePaymentDeps() {
  if (!Get.isRegistered<CustomersProvider>()) {
    Get.lazyPut<CustomersProvider>(() => CustomersProvider(), fenix: true);
  }
  if (!Get.isRegistered<CustomersRepository>()) {
    Get.lazyPut<CustomersRepository>(
      () => CustomersRepository(Get.find<CustomersProvider>()),
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

class PaymentsListBinding extends Bindings {
  @override
  void dependencies() {
    _ensurePaymentDeps();
    Get.lazyPut<PaymentsListController>(
      () => PaymentsListController(
        Get.find<PaymentsRepository>(),
        Get.find<CustomersRepository>(),
      ),
    );
  }
}

class PaymentFormBinding extends Bindings {
  @override
  void dependencies() {
    _ensurePaymentDeps();
    Get.lazyPut<PaymentFormController>(
      () => PaymentFormController(
        Get.find<PaymentsRepository>(),
        Get.find<CustomersRepository>(),
      ),
    );
  }
}

class PaymentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    _ensurePaymentDeps();
    Get.lazyPut<PaymentDetailsController>(
      () => PaymentDetailsController(Get.find<PaymentsRepository>()),
    );
  }
}
