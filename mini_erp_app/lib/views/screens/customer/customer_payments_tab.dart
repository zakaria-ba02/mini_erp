import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/customer_portal_controller.dart';
import '../../../data/models/payment.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_paginated_list_body.dart';

class CustomerPaymentsTab extends GetView<CustomerPaymentsController> {
  const CustomerPaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppPaginatedListBody(
        state: controller.uiState.value,
        errorMessage: controller.errorMessage.value ?? 'تعذر تحميل الدفعات',
        itemCount: controller.items.length,
        hasMore: controller.hasMore,
        onRefresh: controller.fetchFirstPage,
        onRetry: controller.fetchFirstPage,
        onLoadMore: controller.loadMore,
        emptyIcon: Icons.payments_outlined,
        emptyTitle: 'لا توجد دفعات',
        emptySubtitle: 'ستظهر دفعاتك هنا عند تسجيلها.',
        emptyAction: TextButton(
          onPressed: controller.fetchFirstPage,
          child: const Text('تحديث'),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemBuilder: (context, index) {
          final payment = controller.items[index];
          return _PaymentTile(
            payment: payment,
            onTap: () => Get.toNamed(
              AppRoutes.customerPaymentDetails,
              arguments: payment.id,
            ),
          ).animate().fadeIn(delay: (20 * (index % 8)).ms);
        },
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment, required this.onTap});

  final Payment payment;
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
                      FormatHelpers.date(payment.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PaymentMethods.labelAr(payment.method),
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
                    payment.amount,
                    payment.currency,
                  ),
                  key: ValueKey(payment.amount),
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
