import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/helpers/app_snackbars.dart';

import '../data/models/cost.dart';
import '../data/repositories/costing_repository.dart';
import '../routes/app_routes.dart';
import '../utils/dio/dio_client.dart';
import '../utils/helpers/list_ui_state.dart';

class CostingListController extends GetxController {
  CostingListController(this._repository);

  final CostingRepository _repository;

  final items = <Cost>[].obs;
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

  void openCreate() => Get.toNamed(AppRoutes.costForm);

  void openDetails(Cost cost) {
    Get.toNamed(AppRoutes.costDetails, arguments: cost.id);
  }
}

class AdditionalCostInput {
  AdditionalCostInput()
      : nameController = TextEditingController(),
        priceController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController priceController;

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class CostFormController extends GetxController {
  CostFormController(this._repository);

  final CostingRepository _repository;

  late final bool isEdit;
  String? costId;

  final nameController = TextEditingController();
  final runtimeController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final boardPriceController = TextEditingController();
  final quantityController = TextEditingController();
  final wasteController = TextEditingController();
  final profitController = TextEditingController();

  final additionalCosts = <AdditionalCostInput>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final savedResult = Rxn<Cost>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) {
      isEdit = true;
      costId = args;
      _load(args);
    } else {
      isEdit = false;
      // sensible defaults matching Postman examples
      runtimeController.text = '2';
      hourlyRateController.text = '50';
      boardPriceController.text = '100';
      quantityController.text = '10';
      wasteController.text = '10';
      profitController.text = '20';
    }
  }

  Future<void> _load(String id) async {
    isLoading.value = true;
    try {
      final cost = await _repository.getById(id);
      _fill(cost);
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _fill(Cost cost) {
    nameController.text = cost.name;
    runtimeController.text = _num(cost.runtime);
    hourlyRateController.text = _num(cost.hourlyRate);
    boardPriceController.text = _num(cost.boardPrice);
    quantityController.text = _num(cost.quantity);
    wasteController.text = _num(cost.wastePercentage);
    profitController.text = _num(cost.profitPercentage);

    for (final item in additionalCosts) {
      item.dispose();
    }
    additionalCosts.clear();
    for (final extra in cost.additionalCosts) {
      final input = AdditionalCostInput();
      input.nameController.text = extra.name;
      input.priceController.text = _num(extra.price);
      additionalCosts.add(input);
    }
  }

  String _num(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  void addAdditionalCost() => additionalCosts.add(AdditionalCostInput());

  void removeAdditionalCost(int index) {
    if (index < 0 || index >= additionalCosts.length) return;
    additionalCosts[index].dispose();
    additionalCosts.removeAt(index);
  }

  @override
  void onClose() {
    nameController.dispose();
    runtimeController.dispose();
    hourlyRateController.dispose();
    boardPriceController.dispose();
    quantityController.dispose();
    wasteController.dispose();
    profitController.dispose();
    for (final item in additionalCosts) {
      item.dispose();
    }
    super.onClose();
  }

  num? _parse(TextEditingController c) => num.tryParse(c.text.trim());

  Future<void> submit() async {
    final name = nameController.text.trim();
    final runtime = _parse(runtimeController);
    final hourlyRate = _parse(hourlyRateController);
    final boardPrice = _parse(boardPriceController);
    final quantity = _parse(quantityController);
    final waste = _parse(wasteController);
    final profit = _parse(profitController);

    if (name.isEmpty ||
        runtime == null ||
        hourlyRate == null ||
        boardPrice == null ||
        quantity == null ||
        waste == null ||
        profit == null) {
      errorMessage.value = 'أكمل جميع الحقول الرقمية المطلوبة.';
      return;
    }
    if (quantity < 1) {
      errorMessage.value = 'الكمية يجب أن تكون 1 على الأقل.';
      return;
    }

    final extras = <AdditionalCost>[];
    for (final item in additionalCosts) {
      final n = item.nameController.text.trim();
      final p = num.tryParse(item.priceController.text.trim());
      if (n.isEmpty && (p == null || p == 0)) continue;
      if (n.isEmpty || p == null) {
        errorMessage.value =
            'كل تكلفة إضافية يجب أن تحتوي اسمًا وسعرًا صالحًا.';
        return;
      }
      extras.add(AdditionalCost(name: n, price: p));
    }

    isLoading.value = true;
    errorMessage.value = null;

    final request = UpsertCostRequest(
      name: name,
      runtime: runtime,
      hourlyRate: hourlyRate,
      boardPrice: boardPrice,
      quantity: quantity,
      wastePercentage: waste,
      profitPercentage: profit,
      additionalCosts: extras,
    );

    try {
      final Cost result;
      if (isEdit && costId != null) {
        result = await _repository.update(costId!, request);
        AppSnackbars.success('تم تحديث وإعادة حساب التكليف');
      } else {
        result = await _repository.create(request);
        AppSnackbars.success('تم حساب وحفظ التكليف');
      }
      savedResult.value = result;
      if (Get.isRegistered<CostingListController>()) {
        Get.find<CostingListController>().fetchFirstPage();
      }
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void viewDetails() {
    final cost = savedResult.value;
    if (cost == null) return;
    Get.offNamed(AppRoutes.costDetails, arguments: cost.id);
  }
}

class CostDetailsController extends GetxController {
  CostDetailsController(this._repository);

  final CostingRepository _repository;

  final cost = Rxn<Cost>();
  final isLoading = true.obs;
  final errorMessage = RxnString();
  late final String costId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    costId = args is String
        ? args
        : args is Cost
            ? args.id
            : '';
    if (costId.isEmpty) {
      errorMessage.value = 'معرّف التكليف غير موجود.';
      isLoading.value = false;
    } else {
      load();
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      cost.value = await _repository.getById(costId);
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
          'هل تريد حذف عنصر التكليف؟ سيتم تعطيله (Soft Delete).',
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
      await _repository.delete(costId);
      if (Get.isRegistered<CostingListController>()) {
        await Get.find<CostingListController>().fetchFirstPage();
      }
      Get.back();
      AppSnackbars.success('تم حذف عنصر التكليف');
    } catch (e) {
      AppSnackbars.error(DioClient.mapError(e));
    }
  }
}
