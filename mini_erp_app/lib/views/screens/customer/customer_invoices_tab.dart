import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/customer_portal_controller.dart';
import '../../../data/models/invoice.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_paginated_list_body.dart';

class CustomerInvoicesTab extends GetView<CustomerInvoicesController> {
  const CustomerInvoicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppPaginatedListBody(
        state: controller.uiState.value,
        errorMessage: controller.errorMessage.value ?? 'تعذر تحميل الفواتير',
        itemCount: controller.items.length,
        hasMore: controller.hasMore,
        skeletonItemHeight: 88,
        onRefresh: controller.fetchFirstPage,
        onRetry: controller.fetchFirstPage,
        onLoadMore: controller.loadMore,
        emptyIcon: Icons.receipt_long_outlined,
        emptyTitle: 'لا توجد فواتير',
        emptySubtitle: 'ستظهر فواتيرك هنا عند إصدارها.',
        emptyAction: TextButton(
          onPressed: controller.fetchFirstPage,
          child: const Text('تحديث'),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemBuilder: (context, index) {
          final inv = controller.items[index];
          return _InvoiceTile(
            invoice: inv,
            onTap: () => Get.toNamed(
              AppRoutes.customerInvoiceDetails,
              arguments: inv.id,
            ),
          ).animate().fadeIn(delay: (20 * (index % 8)).ms);
        },
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice, required this.onTap});

  final Invoice invoice;
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelpers.date(invoice.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${invoice.items.length} بند',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  FormatHelpers.moneyWithCurrency(
                    invoice.total,
                    invoice.currency,
                  ),
                  key: ValueKey(invoice.total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
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
