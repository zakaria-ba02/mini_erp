import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/helpers/app_date_pickers.dart';
import '../utils/helpers/app_snackbars.dart';

import '../data/models/app_currency.dart';
import '../data/models/cost.dart';
import '../data/models/customer.dart';
import '../data/models/invoice.dart';
import '../data/repositories/costing_repository.dart';
import '../data/repositories/customers_repository.dart';
import '../data/repositories/invoices_repository.dart';
import '../routes/app_routes.dart';
import '../utils/dio/dio_client.dart';
import '../utils/helpers/list_ui_state.dart';

class InvoicesListController extends GetxController {
  InvoicesListController(this._repository, this._customersRepository);

  final InvoicesRepository _repository;
  final CustomersRepository _customersRepository;

  final items = <Invoice>[].obs;
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
    } catch (_) {
      // Filters still work with customerId if passed via arguments.
    }
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
      AppRoutes.invoiceForm,
      arguments: args.isEmpty ? null : args,
    );
  }

  void openDetails(Invoice invoice) {
    Get.toNamed(AppRoutes.invoiceDetails, arguments: invoice.id);
  }
}

/// Line item draft for create/edit — unitPrice is NEVER auto-filled from catalog.
class InvoiceLineDraft {
  InvoiceLineDraft({
    this.costId,
    String name = '',
    this.refCostPerUnit,
    this.refSellingPricePerUnit,
  })  : nameController = TextEditingController(text: name),
        quantityController = TextEditingController(text: '1'),
        unitPriceController = TextEditingController(); // intentionally empty

  String? costId;
  num? refCostPerUnit;
  num? refSellingPricePerUnit;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;

  bool get isFromCatalog => costId != null && costId!.isNotEmpty;

  num get estimatedLineTotal {
    final q = num.tryParse(quantityController.text.trim()) ?? 0;
    final p = num.tryParse(unitPriceController.text.trim()) ?? 0;
    return q * p;
  }

  InvoiceItem? toItemOrNull() {
    final q = num.tryParse(quantityController.text.trim());
    final p = num.tryParse(unitPriceController.text.trim());
    final name = nameController.text.trim();
    if (q == null || q < 0.01 || p == null || p < 0) return null;
    if (!isFromCatalog && name.isEmpty) return null;
    return InvoiceItem(
      costId: costId,
      name: name,
      quantity: q,
      unitPrice: p,
    );
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}

class InvoiceFormController extends GetxController {
  InvoiceFormController(
    this._invoicesRepository,
    this._customersRepository,
    this._costingRepository,
  );

  final InvoicesRepository _invoicesRepository;
  final CustomersRepository _customersRepository;
  final CostingRepository _costingRepository;

  late final bool isEdit;
  String? invoiceId;

  final customers = <Customer>[].obs;
  final catalog = <Cost>[].obs;
  final selectedCustomerId = RxnString();
  final date = DateTime.now().obs;
  final lines = <InvoiceLineDraft>[].obs;
  final currency = AppCurrency.syp.obs;

  // Start true so first Obx paint never mounts the form mid-bootstrap.
  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final savedInvoice = Rxn<Invoice>();

  /// Client-side estimate only — not source of truth.
  num get estimatedTotal =>
      lines.fold<num>(0, (sum, line) => sum + line.estimatedLineTotal);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) {
      isEdit = true;
      invoiceId = args;
      _bootstrapEdit(args);
    } else {
      isEdit = false;
      if (args is Map) {
        final id = args['customerId']?.toString();
        if (id != null && id.isNotEmpty) selectedCustomerId.value = id;
        if (args['currency'] != null) {
          currency.value = AppCurrency.fromString(args['currency'].toString());
        }
      }
      _bootstrapCreate();
    }
  }

  Future<void> _bootstrapCreate() async {
    try {
      await _loadLookups();
      if (lines.isEmpty) {
        lines.add(InvoiceLineDraft());
      }
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadLookups() async {
    final customersResult =
        await _customersRepository.list(page: 1, limit: 100);
    final costingResult = await _costingRepository.list(page: 1, limit: 100);
    customers.assignAll(customersResult.data);
    catalog.assignAll(costingResult.data);
  }

  Future<void> _bootstrapEdit(String id) async {
    try {
      await _loadLookups();
      final invoice = await _invoicesRepository.getById(id);
      selectedCustomerId.value = invoice.customerId;
      date.value = invoice.date;
      currency.value = invoice.currency;
      for (final line in lines) {
        line.dispose();
      }
      lines.clear();
      for (final item in invoice.items) {
        final draft = InvoiceLineDraft(
          costId: item.costId,
          name: item.name,
        );
        // Prefill existing saved values on edit (from invoice, not catalog).
        draft.quantityController.text = _num(item.quantity);
        draft.unitPriceController.text = _num(item.unitPrice);
        if (item.costId != null) {
          Cost? match;
          for (final c in catalog) {
            if (c.id == item.costId) {
              match = c;
              break;
            }
          }
          draft.refCostPerUnit = match?.costPerUnit;
          draft.refSellingPricePerUnit = match?.sellingPricePerUnit;
        }
        lines.add(draft);
      }
      if (lines.isEmpty) lines.add(InvoiceLineDraft());
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

  void addManualLine() => lines.add(InvoiceLineDraft());

  /// Catalog pick: fill name + costId only. NEVER fill unitPrice.
  void addFromCatalog(Cost cost) {
    final draft = InvoiceLineDraft(
      costId: cost.id,
      name: cost.name,
      refCostPerUnit: cost.costPerUnit,
      refSellingPricePerUnit: cost.sellingPricePerUnit,
    );
    // Explicit guarantee — unitPrice stays empty for admin to enter.
    draft.unitPriceController.clear();
    lines.add(draft);
  }

  /// Apply catalog selection onto an existing line — name/costId/refs only.
  void applyCatalogToLine(int index, Cost cost) {
    if (index < 0 || index >= lines.length) return;
    final draft = lines[index];
    draft.costId = cost.id;
    draft.nameController.text = cost.name;
    draft.refCostPerUnit = cost.costPerUnit;
    draft.refSellingPricePerUnit = cost.sellingPricePerUnit;
    // Critical: do not touch unitPriceController.
    lines.refresh();
  }

  void clearCatalogLink(int index) {
    if (index < 0 || index >= lines.length) return;
    final draft = lines[index];
    draft.costId = null;
    draft.refCostPerUnit = null;
    draft.refSellingPricePerUnit = null;
    lines.refresh();
  }

  void removeLine(int index) {
    if (lines.length <= 1) return;
    lines[index].dispose();
    lines.removeAt(index);
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await AppDatePickers.pick(context, initialDate: date.value, firstDate: DateTime(2020), lastDate: DateTime(2100),
    );
    if (picked != null) {
      date.value = DateTime(picked.year, picked.month, picked.day);
    }
  }

  void notifyLineChanged() => lines.refresh();

  Future<void> submit() async {
    final customerId = selectedCustomerId.value;
    if (customerId == null || customerId.isEmpty) {
      errorMessage.value = 'اختر الزبون.';
      return;
    }

    final items = <InvoiceItem>[];
    for (final line in lines) {
      final item = line.toItemOrNull();
      if (item == null) {
        errorMessage.value =
            'أكمل كل البنود: الاسم (للبند اليدوي) والكمية وسعر الوحدة.';
        return;
      }
      items.add(item);
    }

    isSaving.value = true;
    errorMessage.value = null;

    try {
      final Invoice result;
      if (isEdit && invoiceId != null) {
        result = await _invoicesRepository.update(
          invoiceId!,
          UpdateInvoiceRequest(
            customerId: customerId,
            date: date.value,
            items: items,
            currency: currency.value,
          ),
        );
        AppSnackbars.success('تم تحديث الفاتورة');
      } else {
        result = await _invoicesRepository.create(
          CreateInvoiceRequest(
            customerId: customerId,
            date: date.value,
            items: items,
            currency: currency.value,
          ),
        );
        AppSnackbars.success('تم إنشاء الفاتورة');
      }
      savedInvoice.value = result;
      if (Get.isRegistered<InvoicesListController>()) {
        Get.find<InvoicesListController>().fetchFirstPage();
      }
      Get.offNamed(AppRoutes.invoiceDetails, arguments: result.id);
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    for (final line in lines) {
      line.dispose();
    }
    super.onClose();
  }
}

class InvoiceDetailsController extends GetxController {
  InvoiceDetailsController(this._repository);

  final InvoicesRepository _repository;

  final invoice = Rxn<Invoice>();
  final isLoading = true.obs;
  final errorMessage = RxnString();
  late final String invoiceId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    invoiceId = args is String
        ? args
        : args is Invoice
            ? args.id
            : '';
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

  Future<void> confirmDelete() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'حذف الفاتورة (Soft Delete) سيُنقص رصيد الزبون تلقائيًا. هل تريد المتابعة؟',
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
      await _repository.delete(invoiceId);
      if (Get.isRegistered<InvoicesListController>()) {
        await Get.find<InvoicesListController>().fetchFirstPage();
      }
      Get.back();
      AppSnackbars.success('تم حذف الفاتورة');
    } catch (e) {
      AppSnackbars.error(DioClient.mapError(e));
    }
  }
}
