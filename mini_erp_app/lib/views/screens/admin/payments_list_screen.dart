import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/payments_controller.dart';
import '../../../data/models/app_currency.dart';
import '../../../data/models/payment.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_paginated_list_body.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/fx_icon_button.dart';
import '../../widgets/fx/glass_card.dart';
import '../../widgets/fx/press_scale.dart';

class PaymentsListScreen extends GetView<PaymentsListController> {
  const PaymentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FxAppBar(
        titleWidget: Obx(() {
          final currency = controller.selectedCurrency.value;
          return Text(
            currency == null ? 'الدفعات' : currency.paymentsListTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          );
        }),
        actions: [
          FxIconButton(
            tooltip: 'مسح الفلاتر',
            icon: Icons.filter_alt_off_outlined,
            onTap: controller.clearFilters,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('دفعة جديدة'),
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              kToolbarHeight + AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Obx(
              () => Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String?>(
                      value: controller.selectedCustomerId.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'الزبون',
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('الكل'),
                        ),
                        ...controller.customers.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: controller.setCustomerFilter,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<AppCurrency?>(
                      value: controller.selectedCurrency.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem<AppCurrency?>(
                          value: null,
                          child: Text('الكل'),
                        ),
                        DropdownMenuItem(
                          value: AppCurrency.syp,
                          child: Text('سوري'),
                        ),
                        DropdownMenuItem(
                          value: AppCurrency.usd,
                          child: Text('دولار'),
                        ),
                      ],
                      onChanged: controller.setCurrencyFilter,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ActionChip(
                    label: Text(
                      controller.fromDate.value == null
                          ? 'من تاريخ'
                          : FormatHelpers.date(controller.fromDate.value),
                    ),
                    onPressed: () => controller.pickFromDate(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ActionChip(
                    label: Text(
                      controller.toDate.value == null
                          ? 'إلى تاريخ'
                          : FormatHelpers.date(controller.toDate.value),
                    ),
                    onPressed: () => controller.pickToDate(context),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => AppPaginatedListBody(
                state: controller.uiState.value,
                errorMessage:
                    controller.errorMessage.value ?? 'تعذّر تحميل الدفعات',
                itemCount: controller.items.length,
                hasMore: controller.hasMore,
                onRefresh: controller.fetchFirstPage,
                onRetry: controller.fetchFirstPage,
                onLoadMore: controller.loadMore,
                emptyIcon: Icons.payments_outlined,
                emptyTitle: 'لا توجد دفعات',
                emptySubtitle: 'سجّل دفعة جديدة أو عدّل الفلاتر.',
                emptyAction: ElevatedButton.icon(
                  onPressed: controller.openCreate,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('دفعة جديدة'),
                ),
                itemBuilder: (context, index) {
                  final payment = controller.items[index];
                  return _PaymentTile(
                    payment: payment,
                    customerName: _customerName(payment),
                    onTap: () => controller.openDetails(payment),
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

  String _customerName(Payment payment) {
    if (payment.customerName != null && payment.customerName!.isNotEmpty) {
      return payment.customerName!;
    }
    for (final c in controller.customers) {
      if (c.id == payment.customerId) return c.name;
    }
    return payment.customerId;
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.payment,
    required this.customerName,
    required this.onTap,
  });

  final Payment payment;
  final String customerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${FormatHelpers.date(payment.date)} · ${PaymentMethods.labelAr(payment.method)}',
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
    );
  }
}
