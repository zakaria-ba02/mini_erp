import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/helpers/app_date_pickers.dart';
import '../utils/helpers/app_snackbars.dart';

import '../data/models/app_currency.dart';
import '../data/models/customer.dart';
import '../data/models/payment.dart';
import '../data/repositories/customers_repository.dart';
import '../data/repositories/payments_repository.dart';
import '../routes/app_routes.dart';
import '../utils/dio/dio_client.dart';
import '../utils/helpers/list_ui_state.dart';

class PaymentsListController extends GetxController {
  PaymentsListController(this._repository, this._customersRepository);

  final PaymentsRepository _repository;
  final CustomersRepository _customersRepository;

  final items = <Payment>[].obs;
  final customers = <Customer>[].obs;
  final uiState = ListUiState.initial.obs;
  final errorMessage = RxnString();

  final selectedCustomerId = RxnString();
  final selectedCurrency = Rxn<AppCurrency>();
  String? settlementId;
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) {
      selectedCustomerId.value = args;
    } else if (args is Map) {
      final id = args['customerId']?.toString();
      if (id != null && id.isNotEmpty) selectedCustomerId.value = id;
      if (args['currency'] != null) {
        selectedCurrency.value =
            AppCurrency.fromString(args['currency'].toString());
      }
      final sid = args['settlementId']?.toString();
      if (sid != null && sid.isNotEmpty) settlementId = sid;
    }
    _loadCustomers();
    fetchFirstPage();
  }

  Future<void> _loadCustomers() async {
    try {
      final result = await _customersRepository.list(page: 1, limit: 100);
      customers.assignAll(result.data);
    } catch (_) {}
  }

  Future<void> fetchFirstPage() async {
    _page = 1;
    _hasMore = true;
    uiState.value =
        items.isEmpty ? ListUiState.loading : ListUiState.refreshing;
    errorMessage.value = null;
    try {
      final result = await _repository.list(
        page: _page,
        limit: _limit,
        customerId: selectedCustomerId.value,
        fromDate: fromDate.value,
        toDate: toDate.value,
        currency: selectedCurrency.value,
        settlementId: settlementId,
      );
      items.assignAll(result.data);
      _hasMore = result.meta.hasMore;
      uiState.value =
          items.isEmpty ? ListUiState.empty : ListUiState.success;
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
      if (items.isEmpty) {
        uiState.value = ListUiState.error;
      } else {
        uiState.value = ListUiState.success;
        AppSnackbars.error(errorMessage.value ?? '');
      }
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore ||
        uiState.value == ListUiState.loadingMore ||
        uiState.value == ListUiState.loading) {
      return;
    }
    uiState.value = ListUiState.loadingMore;
    try {
      final next = _page + 1;
      final result = await _repository.list(
        page: next,
        limit: _limit,
        customerId: selectedCustomerId.value,
        fromDate: fromDate.value,
        toDate: toDate.value,
        currency: selectedCurrency.value,
        settlementId: settlementId,
      );
      _page = next;
      items.addAll(result.data);
      _hasMore = result.meta.hasMore;
      uiState.value = ListUiState.success;
    } catch (e) {
      uiState.value = ListUiState.success;
      AppSnackbars.error(DioClient.mapError(e));
    }
  }

  void setCustomerFilter(String? id) {
    selectedCustomerId.value = id;
    fetchFirstPage();
  }

  void setCurrencyFilter(AppCurrency? currency) {
    selectedCurrency.value = currency;
    fetchFirstPage();
  }

  Future<void> pickFromDate(BuildContext context) async {
    final picked = await AppDatePickers.pick(context, initialDate: fromDate.value ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100),
    );
    if (picked != null) {
      fromDate.value = DateTime(picked.year, picked.month, picked.day);
      fetchFirstPage();
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final picked = await AppDatePickers.pick(context, initialDate: toDate.value ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100),
    );
    if (picked != null) {
      toDate.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        23,
        59,
        59,
        999,
      );
      fetchFirstPage();
    }
  }

  void clearFilters() {
    selectedCustomerId.value = null;
    selectedCurrency.value = null;
    fromDate.value = null;
    toDate.value = null;
    fetchFirstPage();
  }

  void openCreate() {
    final args = <String, dynamic>{};
    final customerId = selectedCustomerId.value;
    final currency = selectedCurrency.value;
    if (customerId != null && customerId.isNotEmpty) {
      args['customerId'] = customerId;
    }
    if (currency != null) args['currency'] = currency.apiValue;
    Get.toNamed(
      AppRoutes.paymentForm,
      arguments: args.isEmpty ? null : args,
    );
  }

  void openDetails(Payment payment) {
    Get.toNamed(AppRoutes.paymentDetails, arguments: payment.id);
  }
}

class PaymentFormController extends GetxController {
  PaymentFormController(this._repository, this._customersRepository);

  final PaymentsRepository _repository;
  final CustomersRepository _customersRepository;

  late final bool isEdit;
  String? paymentId;

  final customers = <Customer>[].obs;
  final selectedCustomerId = RxnString();
  final date = DateTime.now().obs;
  final method = PaymentMethods.cash.obs;
  final currency = AppCurrency.syp.obs;
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  // Start true so first Obx paint never mounts the form mid-bootstrap.
  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      isEdit = false;
      final id = args['customerId']?.toString();
      if (id != null && id.isNotEmpty) selectedCustomerId.value = id;
      if (args['currency'] != null) {
        currency.value = AppCurrency.fromString(args['currency'].toString());
      }
      _bootstrapCreate();
    } else if (args is String && args.isNotEmpty) {
      // Edit existing payment by id.
      isEdit = true;
      paymentId = args;
      _bootstrapEdit(args);
    } else {
      isEdit = false;
      _bootstrapCreate();
    }
  }

  Future<void> _loadCustomers() async {
    final result = await _customersRepository.list(page: 1, limit: 100);
    customers.assignAll(result.data);
  }

  Future<void> _bootstrapCreate() async {
    try {
      await _loadCustomers();
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _bootstrapEdit(String id) async {
    try {
      await _loadCustomers();
      final payment = await _repository.getById(id);
      selectedCustomerId.value = payment.customerId;
      date.value = payment.date;
      method.value = PaymentMethods.all.contains(payment.method)
          ? payment.method
          : PaymentMethods.other;
      currency.value = payment.currency;
      amountController.text = _num(payment.amount);
      notesController.text = payment.notes ?? '';
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  String _num(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await AppDatePickers.pick(context, initialDate: date.value, firstDate: DateTime(2020), lastDate: DateTime(2100),
    );
    if (picked != null) {
      date.value = DateTime(picked.year, picked.month, picked.day);
    }
  }

  Future<void> submit() async {
    final customerId = selectedCustomerId.value;
    final amount = num.tryParse(amountController.text.trim());
    if (customerId == null || customerId.isEmpty) {
      errorMessage.value = 'اختر الزبون.';
      return;
    }
    if (amount == null || amount < 0.01) {
      errorMessage.value = 'أدخل مبلغًا صالحًا.';
      return;
    }

    isSaving.value = true;
    errorMessage.value = null;

    final request = UpsertPaymentRequest(
      customerId: customerId,
      amount: amount,
      date: date.value,
      method: method.value,
      currency: currency.value,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    );

    try {
      final Payment result;
      if (isEdit && paymentId != null) {
        result = await _repository.update(paymentId!, request);
        AppSnackbars.success('تم تحديث الدفعة');
      } else {
        result = await _repository.create(request);
        AppSnackbars.success('تم تسجيل الدفعة');
      }
      if (Get.isRegistered<PaymentsListController>()) {
        Get.find<PaymentsListController>().fetchFirstPage();
      }
      Get.offNamed(AppRoutes.paymentDetails, arguments: result.id);
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}

class PaymentDetailsController extends GetxController {
  PaymentDetailsController(this._repository);

  final PaymentsRepository _repository;

  final payment = Rxn<Payment>();
  final isLoading = true.obs;
  final errorMessage = RxnString();
  late final String paymentId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    paymentId = args is String
        ? args
        : args is Payment
            ? args.id
            : '';
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

  Future<void> confirmDelete() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'حذف الدفعة (Soft Delete) سيزيد رصيد الزبون تلقائيًا. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _repository.delete(paymentId);
      if (Get.isRegistered<PaymentsListController>()) {
        await Get.find<PaymentsListController>().fetchFirstPage();
      }
      Get.back();
      AppSnackbars.success('تم حذف الدفعة');
    } catch (e) {
      AppSnackbars.error(DioClient.mapError(e));
    }
  }
}
