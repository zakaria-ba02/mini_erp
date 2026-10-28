import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/invoices_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/fx_icon_button.dart';

class InvoiceDetailsScreen extends GetView<InvoiceDetailsController> {
  const InvoiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              FxAppBar(
                title: 'تفاصيل الفاتورة',
                showThemeToggle: false,
                actions: [
                  Obx(() {
                    final inv = controller.invoice.value;
                    if (inv == null) return const SizedBox.shrink();
                    return FxIconButton(
                      tooltip: 'تعديل',
                      icon: Icons.edit_outlined,
                      onTap: () async {
                        await Get.toNamed(
                          AppRoutes.invoiceForm,
                          arguments: inv.id,
                        );
                        controller.load();
                      },
                    );
                  }),
                  FxIconButton(
                    tooltip: 'حذف',
                    onTap: controller.confirmDelete,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
              Expanded(child: _buildBody(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorState(message: error, onRetry: controller.load);
        }
        final inv = controller.invoice.value;
        if (inv == null) {
          return const AppErrorState(message: 'الفاتورة غير موجودة');
        }

        return RefreshIndicator(
          color: AppColors.gold,
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.2),
                      theme.colorScheme.surface,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: AppShadows.soft(theme.brightness),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.customerName ?? 'زبون',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'التاريخ: ${FormatHelpers.date(inv.date)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'الإجمالي (رسمي من الخادم)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        FormatHelpers.moneyWithCurrency(inv.total, inv.currency),
                        key: ValueKey(inv.total),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.05),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'البنود',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...inv.items.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'الكمية: ${FormatHelpers.money(item.quantity)} × سعر الوحدة: ${FormatHelpers.money(item.unitPrice)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إجمالي السطر: ${FormatHelpers.money(item.lineTotal ?? (item.quantity * item.unitPrice))}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),
              ),
            ],
          ),
        );
    });
  }
}

