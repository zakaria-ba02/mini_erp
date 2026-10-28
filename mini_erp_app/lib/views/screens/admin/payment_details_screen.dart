import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/payments_controller.dart';
import '../../../data/models/payment.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/fx_icon_button.dart';

class PaymentDetailsScreen extends GetView<PaymentDetailsController> {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              FxAppBar(
                title: 'تفاصيل الدفعة',
                showThemeToggle: false,
                actions: [
                  Obx(() {
                    final p = controller.payment.value;
                    if (p == null) return const SizedBox.shrink();
                    return FxIconButton(
                      tooltip: 'تعديل',
                      icon: Icons.edit_outlined,
                      onTap: () async {
                        await Get.toNamed(
                          AppRoutes.paymentForm,
                          arguments: p.id,
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
        final p = controller.payment.value;
        if (p == null) {
          return const AppErrorState(message: 'الدفعة غير موجودة');
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
                      p.customerName ?? 'زبون',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'المبلغ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        FormatHelpers.moneyWithCurrency(p.amount, p.currency),
                        key: ValueKey(p.amount),
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
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _Row('التاريخ', FormatHelpers.date(p.date)),
                    const Divider(height: AppSpacing.lg),
                    _Row('العملة', p.currency.labelAr),
                    const Divider(height: AppSpacing.lg),
                    _Row('طريقة الدفع', PaymentMethods.labelAr(p.method)),
                    const Divider(height: AppSpacing.lg),
                    _Row(
                      'ملاحظات',
                      (p.notes == null || p.notes!.isEmpty) ? '—' : p.notes!,
                    ),
                    const Divider(height: AppSpacing.lg),
                    _Row(
                      'تاريخ التسجيل',
                      FormatHelpers.dateTime(p.createdAt),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 80.ms),
            ],
          ),
        );
    });
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
