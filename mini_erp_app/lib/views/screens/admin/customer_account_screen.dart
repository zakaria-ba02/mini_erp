import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/customer_account_controller.dart';
import '../../../data/models/app_currency.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';

class CustomerAccountScreen extends GetView<CustomerAccountController> {
  const CustomerAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              FxAppBar(
                title: controller.isArchived
                    ? 'حساب قديم ${controller.currency.withPrefixAr}'
                    : controller.currency.accountAction,
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

        final customer = controller.customer.value;
        final entries = controller.entries;

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
                      customer?.name ?? 'الزبون',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      controller.isArchived
                          ? 'الرصيد عند التسوية ${controller.currency.withPrefixAr}'
                          : 'الرصيد الحالي ${controller.currency.withPrefixAr}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (controller.isArchived &&
                        controller.settledAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'تاريخ التسوية: ${FormatHelpers.date(controller.settledAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      FormatHelpers.moneyWithCurrency(
                        controller.balance,
                        controller.currency,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.04),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'سجل الحساب',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _HubTile(
                icon: Icons.receipt_long_outlined,
                title: 'فواتيره',
                subtitle: controller.isArchived
                    ? 'فواتير هذه الفترة المقفلة'
                    : 'عرض فواتير هذا الحساب',
                onTap: controller.openInvoices,
              ),
              const SizedBox(height: AppSpacing.sm),
              _HubTile(
                icon: Icons.payments_outlined,
                title: 'دفعاته',
                subtitle: controller.isArchived
                    ? 'دفعات هذه الفترة المقفلة'
                    : 'عرض دفعات هذا الحساب',
                onTap: controller.openPayments,
              ),
              if (controller.isArchived) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'هذه فترة مقفلة. الفواتير والدفعات للعرض فقط ولا تُعدَّل.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                'حركة الحساب',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: Text(
                      controller.isArchived
                          ? 'لا توجد حركة في هذه الفترة المقفلة.'
                          : 'لا توجد فواتير أو دفعات بهذه العملة في الفترة الحالية.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...entries.map(
                  (entry) => _LedgerTile(
                    entry: entry,
                    currency: controller.currency,
                    onTap: () => controller.openEntry(entry),
                  ),
                ),
            ],
          ),
        );
    });
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
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

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({
    required this.entry,
    required this.currency,
    required this.onTap,
  });

  final AccountLedgerEntry entry;
  final AppCurrency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInvoice = entry.kind == AccountEntryKind.invoice;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
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
                Icon(
                  isInvoice
                      ? Icons.receipt_long_outlined
                      : Icons.payments_outlined,
                  color: AppColors.gold,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isInvoice ? 'فاتورة' : 'دفعة',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        FormatHelpers.date(entry.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isInvoice ? '+' : '−'} ${FormatHelpers.moneyWithCurrency(entry.amount, currency)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isInvoice ? AppColors.gold : AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
