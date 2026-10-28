import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/customers_controller.dart';
import '../../../data/models/app_currency.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/fx_icon_button.dart';

class CustomerDetailsScreen extends GetView<CustomerDetailsController> {
  const CustomerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              FxAppBar(
                title: 'تفاصيل الزبون',
                showThemeToggle: false,
                actions: [
                  Obx(() {
                    final c = controller.customer.value;
                    if (c == null) return const SizedBox.shrink();
                    return FxIconButton(
                      tooltip: 'تعديل',
                      icon: Icons.edit_outlined,
                      onTap: () async {
                        final result = await Get.toNamed(
                          AppRoutes.customerForm,
                          arguments: c.id,
                        );
                        if (result == true) controller.load();
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
        final c = controller.customer.value;
        if (c == null) {
          return const AppErrorState(message: 'الزبون غير موجود');
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
                      AppColors.gold.withValues(alpha: 0.22),
                      theme.colorScheme.surface,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: AppShadows.soft(theme.brightness),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'الرصيد الحالي',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      FormatHelpers.moneyWithCurrency(
                        c.balances.syp,
                        AppCurrency.syp,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FormatHelpers.moneyWithCurrency(
                        c.balances.usd,
                        AppCurrency.usd,
                      ),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.05),
              const SizedBox(height: AppSpacing.lg),
              _InfoCard(
                rows: [
                  _InfoRow(label: 'الهاتف', value: c.phone),
                  _InfoRow(
                    label: 'ملاحظات',
                    value: (c.notes == null || c.notes!.isEmpty)
                        ? '—'
                        : c.notes!,
                  ),
                  _InfoRow(
                    label: 'تاريخ الإنشاء',
                    value: FormatHelpers.dateTime(c.createdAt),
                  ),
                ],
              ).animate().fadeIn(delay: 80.ms),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'إجراءات سريعة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ActionTile(
                icon: Icons.account_balance_wallet_outlined,
                title: AppCurrency.syp.accountAction,
                subtitle: 'الرصيد والفواتير والدفعات بالسوري',
                onTap: () => Get.toNamed(
                  AppRoutes.customerAccount,
                  arguments: {
                    'customerId': c.id,
                    'currency': AppCurrency.syp.apiValue,
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionTile(
                icon: Icons.account_balance_wallet_outlined,
                title: AppCurrency.usd.accountAction,
                subtitle: 'الرصيد والفواتير والدفعات بالدولار',
                onTap: () => Get.toNamed(
                  AppRoutes.customerAccount,
                  arguments: {
                    'customerId': c.id,
                    'currency': AppCurrency.usd.apiValue,
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionTile(
                icon: Icons.history_rounded,
                title: 'الحسابات القديمة',
                subtitle: 'عرض الفترات التي تمت تسويتها سابقاً',
                onTap: () => Get.toNamed(
                  AppRoutes.customerSettlements,
                  arguments: c.id,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Obx(
                () => _ActionTile(
                  icon: Icons.account_balance_outlined,
                  title: 'تسوية الحساب',
                  subtitle: controller.isSettling.value
                      ? 'جاري التسوية…'
                      : 'تصفير رصيد عملة واحدة وقفل فترتها الحالية',
                  onTap: controller.isSettling.value
                      ? () {}
                      : controller.confirmSettle,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionTile(
                icon: Icons.lock_reset_rounded,
                title: 'إعادة تعيين كلمة السر',
                subtitle: 'تعيين كلمة مرور جديدة لحساب الزبون',
                onTap: () => Get.toNamed(
                  AppRoutes.customerResetPassword,
                  arguments: c.id,
                ),
              ),
            ],
          ),
        );
    });
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1) const Divider(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.gold),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
