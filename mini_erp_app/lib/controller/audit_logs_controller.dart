import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/helpers/app_date_pickers.dart';
import '../utils/helpers/app_snackbars.dart';

import '../data/models/audit_log.dart';
import '../data/repositories/audit_logs_repository.dart';
import '../utils/constants/app_colors.dart';
import '../utils/dio/dio_client.dart';
import '../utils/helpers/format_helpers.dart';
import '../utils/helpers/list_ui_state.dart';

/// Read-only audit logs controller — no create/update/delete.
class AuditLogsController extends GetxController {
  AuditLogsController(this._repository);

  final AuditLogsRepository _repository;

  final items = <AuditLog>[].obs;
  final uiState = ListUiState.initial.obs;
  final errorMessage = RxnString();

  final selectedEntity = RxnString();
  final userIdController = TextEditingController();
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  @override
  void onClose() {
    userIdController.dispose();
    super.onClose();
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
        entity: selectedEntity.value,
        userId: userIdController.text.trim().isEmpty
            ? null
            : userIdController.text.trim(),
        fromDate: fromDate.value,
        toDate: toDate.value,
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
        entity: selectedEntity.value,
        userId: userIdController.text.trim().isEmpty
            ? null
            : userIdController.text.trim(),
        fromDate: fromDate.value,
        toDate: toDate.value,
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

  void setEntity(String? entity) {
    selectedEntity.value = entity;
    fetchFirstPage();
  }

  void applyUserIdFilter() => fetchFirstPage();

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
    selectedEntity.value = null;
    userIdController.clear();
    fromDate.value = null;
    toDate.value = null;
    fetchFirstPage();
  }

  void showDetails(AuditLog log) {
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تفاصيل السجل',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _detailRow('العملية', log.actionLabelAr),
                _detailRow('الكيان', log.entityLabelAr),
                _detailRow('معرّف الكيان', log.entityId ?? '—'),
                _detailRow('المستخدم', log.username ?? log.userId ?? '—'),
                _detailRow('الوقت', FormatHelpers.dateTime(log.createdAt)),
                if (log.details != null && log.details!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'تفاصيل إضافية',
                    style: Get.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SelectableText(
                    log.details!,
                    style: Get.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
