import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/helpers/app_snackbars.dart';

import '../data/models/app_currency.dart';
import '../data/models/customer.dart';
import '../data/models/customer_requests.dart';
import '../data/repositories/customers_repository.dart';
import '../routes/app_routes.dart';
import '../utils/dio/dio_client.dart';
import '../utils/helpers/list_ui_state.dart';

export '../utils/helpers/list_ui_state.dart';

class CustomersController extends GetxController {
  CustomersController(this._repository);

  final CustomersRepository _repository;

  final items = <Customer>[].obs;
  final uiState = ListUiState.initial.obs;
  final errorMessage = RxnString();
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  Timer? _debounce;

  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), fetchFirstPage);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchFirstPage();
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
        search: searchQuery.value,
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
        search: searchQuery.value,
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

  Future<void> deleteCustomer(Customer customer) async {
    try {
      await _repository.delete(customer.id);
      items.removeWhere((c) => c.id == customer.id);
      if (items.isEmpty) uiState.value = ListUiState.empty;
      AppSnackbars.success('تم حذف الزبون بنجاح');
    } catch (e) {
      AppSnackbars.error(DioClient.mapError(e));
    }
  }

  void openDetails(Customer customer) {
    Get.toNamed(AppRoutes.customerDetails, arguments: customer.id);
  }

  void openCreate() {
    Get.toNamed(AppRoutes.customerForm);
  }
}

class CustomerFormController extends GetxController {
  CustomerFormController(this._repository);

  final CustomersRepository _repository;

  late final bool isEdit;
  String? customerId;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) {
      isEdit = true;
      customerId = args;
      _load(args);
    } else if (args is Customer) {
      isEdit = true;
      customerId = args.id;
      _fill(args);
    } else {
      isEdit = false;
    }
  }

  Future<void> _load(String id) async {
    isLoading.value = true;
    try {
      final customer = await _repository.getById(id);
      _fill(customer);
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _fill(Customer customer) {
    nameController.text = customer.name;
    phoneController.text = customer.phone;
    notesController.text = customer.notes ?? '';
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    notesController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final notes = notesController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      errorMessage.value = 'الاسم ورقم الهاتف مطلوبان.';
      return;
    }

    if (!isEdit) {
      final username = usernameController.text.trim();
      final password = passwordController.text;
      if (username.isEmpty || password.isEmpty) {
        errorMessage.value = 'اسم المستخدم وكلمة المرور مطلوبان للحساب.';
        return;
      }
      if (password.length < 6) {
        errorMessage.value = 'كلمة المرور يجب ألا تقل عن 6 أحرف.';
        return;
      }
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      if (isEdit && customerId != null) {
        await _repository.update(
          customerId!,
          UpdateCustomerRequest(
            name: name,
            phone: phone,
            notes: notes,
          ),
        );
        Get.back(result: true);
        AppSnackbars.success('تم تحديث بيانات الزبون');
      } else {
        final created = await _repository.create(
          CreateCustomerRequest(
            name: name,
            phone: phone,
            notes: notes.isEmpty ? null : notes,
            username: usernameController.text.trim(),
            password: passwordController.text,
          ),
        );
        Get.offNamed(AppRoutes.customerDetails, arguments: created.id);
        AppSnackbars.success('تم إنشاء الزبون بنجاح');
      }
      if (Get.isRegistered<CustomersController>()) {
        Get.find<CustomersController>().fetchFirstPage();
      }
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }
}

class CustomerDetailsController extends GetxController {
  CustomerDetailsController(this._repository);

  final CustomersRepository _repository;

  final customer = Rxn<Customer>();
  final isLoading = true.obs;
  final isSettling = false.obs;
  final errorMessage = RxnString();

  late final String customerId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    customerId = args is String
        ? args
        : args is Customer
            ? args.id
            : '';
    if (customerId.isEmpty) {
      errorMessage.value = 'معرّف الزبون غير موجود.';
      isLoading.value = false;
    } else {
      load();
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      customer.value = await _repository.getById(customerId);
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmSettle() async {
    final currency = await Get.dialog<AppCurrency>(
      AlertDialog(
        title: const Text('تسوية الحساب'),
        content: const Text(
          'اختر العملة. تُقفل فواتير ودفعات الفترة الحالية لهذه العملة، ويُصفَّر رصيدها. المستندات القديمة تبقى للأرشيف.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: AppCurrency.syp),
            child: Text(AppCurrency.syp.settleAction),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: AppCurrency.usd),
            child: Text(AppCurrency.usd.settleAction),
          ),
        ],
      ),
    );
    if (currency == null) return;

    isSettling.value = true;
    try {
      await _repository.settle(customerId, currency);
      await load();
      if (Get.isRegistered<CustomersController>()) {
        await Get.find<CustomersController>().fetchFirstPage();
      }
      AppSnackbars.success('تمت ${currency.settleAction}');
    } catch (e) {
      AppSnackbars.error(DioClient.mapError(e));
    } finally {
      isSettling.value = false;
    }
  }

  Future<void> confirmDelete() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل تريد حذف هذا الزبون؟ سيتم تعطيله (Soft Delete) ولن يُحذف نهائيًا من النظام.',
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
      await _repository.delete(customerId);
      if (Get.isRegistered<CustomersController>()) {
        await Get.find<CustomersController>().fetchFirstPage();
      }
      Get.back();
      AppSnackbars.success('تم حذف الزبون');
    } catch (e) {
      AppSnackbars.error(DioClient.mapError(e));
    }
  }
}

class ResetPasswordController extends GetxController {
  ResetPasswordController(this._repository);

  final CustomersRepository _repository;

  late final String customerId;
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final isLoading = false.obs;
  final obscure = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    customerId = args is String
        ? args
        : args is Customer
            ? args.id
            : '';
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    final password = passwordController.text;
    final confirm = confirmController.text;
    if (password.length < 6) {
      errorMessage.value = 'كلمة المرور يجب ألا تقل عن 6 أحرف.';
      return;
    }
    if (password != confirm) {
      errorMessage.value = 'كلمتا المرور غير متطابقتين.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _repository.resetPassword(customerId, password);
      Get.back();
      AppSnackbars.success('تم إعادة تعيين كلمة المرور');
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
