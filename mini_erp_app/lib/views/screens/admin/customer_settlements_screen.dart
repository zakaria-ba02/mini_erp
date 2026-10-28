import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/customer_settlements_controller.dart';
import '../../../data/models/settlement.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_paginated_list_body.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';

class CustomerSettlementsScreen
    extends GetView<CustomerSettlementsController> {
  const CustomerSettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              const FxAppBar(title: 'الحسابات القديمة'),
              Expanded(
                child: Obx(
                  () => AppPaginatedListBody(
          state: controller.uiState.value,
          errorMessage:
              controller.errorMessage.value ?? 'تعذّر تحميل الحسابات القديمة',
          itemCount: controller.items.length,
          hasMore: controller.hasMore,
          skeletonItemHeight: 108,
          onRefresh: controller.fetchFirstPage,
          onRetry: controller.fetchFirstPage,
          onLoadMore: controller.loadMore,
          emptyIcon: Icons.history_rounded,
          emptyTitle: 'لا توجد تسويات سابقة',
          emptySubtitle: 'بعد تسوية الحساب تظهر الفترة المقفلة هنا.',
          itemBuilder: (context, index) {
            final settlement = controller.items[index];
            return _SettlementTile(
              settlement: settlement,
              onTap: () => controller.openSettlement(settlement),
            )
                .animate(delay: (40 * (index % 8)).ms)
                .fadeIn(duration: 320.ms)
                .slideX(begin: 0.06, curve: Curves.easeOutCubic);
          },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  const _SettlementTile({required this.settlement, required this.onTap});

  final Settlement settlement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'حساب مقفل ${settlement.currency.withPrefixAr}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    FormatHelpers.date(settlement.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'فواتير: ${FormatHelpers.moneyWithCurrency(settlement.totalInvoices, settlement.currency)}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'دفعات: ${FormatHelpers.moneyWithCurrency(settlement.totalPayments, settlement.currency)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'الرصيد عند التسوية: ${FormatHelpers.moneyWithCurrency(settlement.balanceAtSettlement, settlement.currency)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
