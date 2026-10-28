import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/app_currency.dart';
import '../data/models/customer.dart';
import '../data/models/invoice.dart';
import '../data/models/payment.dart';
import '../data/repositories/customers_repository.dart';
import '../data/repositories/invoices_repository.dart';
import '../data/repositories/payments_repository.dart';
import '../data/repositories/users_repository.dart';
import '../utils/dio/dio_client.dart';
import '../utils/helpers/app_snackbars.dart';
import '../utils/helpers/list_ui_state.dart';
class CustomerHomeController extends GetxController {
  CustomerHomeController(
    this._customersRepository,
    this._invoicesRepository,
    this._paymentsRepository,
  );

  final CustomersRepository _customersRepository;
  final InvoicesRepository _invoicesRepository;
  final PaymentsRepository _paymentsRepository;

  final customer = Rxn<Customer>();

  /// Name/phone extracted from the populated customer on the user's own
  /// invoices/payments — used when /customers/:id is admin-only.
  final fallbackName = RxnString();
  final fallbackPhone = RxnString();

  final invoicesTotalSyp = 0.0.obs;
  final invoicesTotalUsd = 0.0.obs;
  final paymentsTotalSyp = 0.0.obs;
  final paymentsTotalUsd = 0.0.obs;
  final invoicesCount = 0.obs;
  final paymentsCount = 0.obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Own lists — backend filters by JWT; do NOT send customerId.
      final invoicesFuture = _invoicesRepository.list(page: 1, limit: 100);
      final paymentsFuture = _paymentsRepository.list(page: 1, limit: 100);

      Customer? profile;
      try {
        profile = await _customersRepository.getMe();
      } catch (_) {
        // Older backend without /customers/me — fall back to computed totals.
      }

      final invoices = await invoicesFuture;
      final payments = await paymentsFuture;

      customer.value = profile;

      String? name;
      String? phone;
      for (final i in invoices.data) {
        name ??= i.customerName;
        phone ??= i.customerPhone;
        if (name != null && phone != null) break;
      }
      for (final p in payments.data) {
        if (name != null && phone != null) break;
        name ??= p.customerName;
        phone ??= p.customerPhone;
      }
      fallbackName.value = name;
      fallbackPhone.value = phone;

      invoicesCount.value = invoices.meta.total;
      paymentsCount.value = payments.meta.total;
      invoicesTotalSyp.value = invoices.data
          .where((i) => i.currency == AppCurrency.syp)
          .fold<num>(0, (s, i) => s + i.total)
          .toDouble();
      invoicesTotalUsd.value = invoices.data
          .where((i) => i.currency == AppCurrency.usd)
          .fold<num>(0, (s, i) => s + i.total)
          .toDouble();
      paymentsTotalSyp.value = payments.data
          .where((p) => p.currency == AppCurrency.syp)
          .fold<num>(0, (s, p) => s + p.amount)
          .toDouble();
      paymentsTotalUsd.value = payments.data
          .where((p) => p.currency == AppCurrency.usd)
          .fold<num>(0, (s, p) => s + p.amount)
          .toDouble();
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  CustomerBalances get displayBalances {
    final c = customer.value;
    if (c != null) return c.balances;
    return CustomerBalances(
      syp: invoicesTotalSyp.value - paymentsTotalSyp.value,
      usd: invoicesTotalUsd.value - paymentsTotalUsd.value,
    );
  }

  bool get balanceFromProfile => customer.value != null;

  String? get displayName => customer.value?.name ?? fallbackName.value;
  String? get displayPhone => customer.value?.phone ?? fallbackPhone.value;
}

class CustomerInvoicesController extends GetxController {
  CustomerInvoicesController(this._repository);

  final InvoicesRepository _repository;

  final items = <Invoice>[].obs;
  final uiState = ListUiState.initial.obs;
  final errorMessage = RxnString();

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    _page = 1;
    _hasMore = true;
    uiState.value =
        items.isEmpty ? ListUiState.loading : ListUiState.refreshing;
    errorMessage.value = null;
    try {
      final result = await _repository.list(page: _page, limit: _limit);
      items.assignAll(result.data);
      _hasMore = result.meta.hasMore;
      uiState.value =
          items.isEmpty ? ListUiState.empty : ListUiState.success;
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
      uiState.value =
          items.isEmpty ? ListUiState.error : ListUiState.success;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || uiState.value == ListUiState.loadingMore) return;
    uiState.value = ListUiState.loadingMore;
    try {
      final next = _page + 1;
      final result = await _repository.list(page: next, limit: _limit);
      _page = next;
      items.addAll(result.data);
      _hasMore = result.meta.hasMore;
      uiState.value = ListUiState.success;
    } catch (e) {
      uiState.value = ListUiState.success;
      AppSnackbars.error(DioClient.mapError(e));
    }
  }
}

class CustomerPaymentsController extends GetxController {
  CustomerPaymentsController(this._repository);

  final PaymentsRepository _repository;

  final items = <Payment>[].obs;
  final uiState = ListUiState.initial.obs;
  final errorMessage = RxnString();

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    _page = 1;
    _hasMore = true;
    uiState.value =
        items.isEmpty ? ListUiState.loading : ListUiState.refreshing;
    errorMessage.value = null;
    try {
      final result = await _repository.list(page: _page, limit: _limit);
      items.assignAll(result.data);
      _hasMore = result.meta.hasMore;
      uiState.value =
          items.isEmpty ? ListUiState.empty : ListUiState.success;
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
      uiState.value =
          items.isEmpty ? ListUiState.error : ListUiState.success;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || uiState.value == ListUiState.loadingMore) return;
    uiState.value = ListUiState.loadingMore;
    try {
      final next = _page + 1;
      final result = await _repository.list(page: next, limit: _limit);
      _page = next;
      items.addAll(result.data);
      _hasMore = result.meta.hasMore;
      uiState.value = ListUiState.success;
    } catch (e) {
      uiState.value = ListUiState.success;
      AppSnackbars.error(DioClient.mapError(e));
    }
  }
}

class CustomerInvoiceDetailsController extends GetxController {
  CustomerInvoiceDetailsController(this._repository);

  final InvoicesRepository _repository;
  final invoice = Rxn<Invoice>();
  final isLoading = true.obs;
  final errorMessage = RxnString();
  late final String invoiceId;

  @override
  void onInit() {
    super.onInit();
    invoiceId = (Get.arguments as String?) ?? '';
    if (invoiceId.isEmpty) {
      errorMessage.value = 'معرّف الفاتورة غير موجود.';
      isLoading.value = false;
    } else {
      load();
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      invoice.value = await _repository.getById(invoiceId);
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }
}

class CustomerPaymentDetailsController extends GetxController {
  CustomerPaymentDetailsController(this._repository);

  final PaymentsRepository _repository;
  final payment = Rxn<Payment>();
  final isLoading = true.obs;
  final errorMessage = RxnString();
  late final String paymentId;

  @override
  void onInit() {
    super.onInit();
    paymentId = (Get.arguments as String?) ?? '';
    if (paymentId.isEmpty) {
      errorMessage.value = 'معرّف الدفعة غير موجود.';
      isLoading.value = false;
    } else {
      load();
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      payment.value = await _repository.getById(paymentId);
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }
}

class CustomerSettingsController extends GetxController {
  CustomerSettingsController(
    this._customersRepository,
    this._usersRepository,
  );

  final CustomersRepository _customersRepository;
  final UsersRepository _usersRepository;

  final customer = Rxn<Customer>();
  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscure = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      customer.value = await _customersRepository.getMe();
    } catch (_) {
      // Older backend without /customers/me — keep settings usable.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      errorMessage.value = 'أدخل كلمة المرور الحالية والجديدة.';
      successMessage.value = null;
      return;
    }
    if (newPassword.length < 6) {
      errorMessage.value = 'كلمة المرور الجديدة يجب ألا تقل عن 6 أحرف.';
      successMessage.value = null;
      return;
    }
    if (newPassword != confirm) {
      errorMessage.value = 'كلمتا المرور غير متطابقتين.';
      successMessage.value = null;
      return;
    }

    isSaving.value = true;
    errorMessage.value = null;
    successMessage.value = null;
    try {
      // Provisional path — not in openapi-spec.json yet.
      await _usersRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      successMessage.value = 'تم تغيير كلمة المرور بنجاح.';
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isSaving.value = false;
    }
  }
}

/// Bottom-nav index for the customer shell.
class CustomerShellController extends GetxController {
  final tabIndex = 0.obs;

  void setTab(int index) => tabIndex.value = index;
}
