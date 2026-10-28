import 'package:get/get.dart';

import '../data/models/settlement.dart';
import '../data/repositories/customers_repository.dart';
import '../routes/app_routes.dart';
import '../utils/dio/dio_client.dart';
import '../utils/helpers/list_ui_state.dart';

class CustomerSettlementsController extends GetxController {
  CustomerSettlementsController(this._repository);

  final CustomersRepository _repository;

  late final String customerId;
  final items = <Settlement>[].obs;
  final uiState = ListUiState.initial.obs;
  final errorMessage = RxnString();

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    customerId = (Get.arguments as String?) ?? '';
    if (customerId.isEmpty) {
      errorMessage.value = 'معرّف الزبون غير موجود.';
      uiState.value = ListUiState.error;
    } else {
      fetchFirstPage();
    }
  }

  Future<void> fetchFirstPage() async {
    if (customerId.isEmpty) return;
    _page = 1;
    _hasMore = true;
    uiState.value =
        items.isEmpty ? ListUiState.loading : ListUiState.refreshing;
    errorMessage.value = null;
    try {
      final result = await _repository.listSettlements(
        customerId,
        page: _page,
        limit: _limit,
      );
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
      final result = await _repository.listSettlements(
        customerId,
        page: next,
        limit: _limit,
      );
      _page = next;
      items.addAll(result.data);
      _hasMore = result.meta.hasMore;
      uiState.value = ListUiState.success;
    } catch (e) {
      uiState.value = ListUiState.success;
    }
  }

  void openSettlement(Settlement settlement) {
    Get.toNamed(
      AppRoutes.customerAccount,
      arguments: {
        'customerId': customerId,
        'currency': settlement.currency.apiValue,
        'settlementId': settlement.id,
        'balanceAtSettlement': settlement.balanceAtSettlement,
        'settledAt': settlement.createdAt?.toIso8601String(),
      },
    );
  }
}
