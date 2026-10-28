import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/customer_portal_controller.dart';
import '../../../data/models/app_currency.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/fx_bottom_nav.dart';
import '../../widgets/fx/fx_icon_button.dart';
import '../../widgets/fx/glass_card.dart';
import '../../widgets/fx/gold_shimmer_text.dart';
import '../../widgets/fx/press_scale.dart';
import 'customer_invoices_tab.dart';
import 'customer_payments_tab.dart';
import 'customer_settings_tab.dart';

/// Customer shell: Home / Invoices / Payments / Settings.
class CustomerHomeScreen extends GetView<CustomerShellController> {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Obx(() {
      final index = controller.tabIndex.value;
      return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: FxAppBar(
          title: _titleFor(index),
          subtitle: Text.rich(
            TextSpan(
              text: 'مرحباً بك في نظام ',
              children: const [
                TextSpan(
                  text: 'ترتيل',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            if (index == 3)
              FxIconButton(
                tooltip: 'تسجيل الخروج',
                icon: Icons.logout_rounded,
                onTap: auth.logout,
              ),
          ],
        ),
        body: AppFxBackground(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: FxAppBar.subtitleHeight),
              child: IndexedStack(
                index: index,
                children: const [
                  _CustomerDashboardTab(),
                  CustomerInvoicesTab(),
                  CustomerPaymentsTab(),
                  CustomerSettingsTab(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: FxBottomNav(
          currentIndex: index,
          onTap: controller.setTab,
          items: const [
            FxBottomNavItem(icon: Icons.home_rounded, tooltip: 'الرئيسية'),
            FxBottomNavItem(
              icon: Icons.receipt_long_rounded,
              tooltip: 'فواتيري',
            ),
            FxBottomNavItem(icon: Icons.payments_rounded, tooltip: 'دفعاتي'),
            FxBottomNavItem(
              icon: Icons.settings_rounded,
              tooltip: 'الإعدادات',
            ),
          ],
        ),
      );
    });
  }

  String _titleFor(int index) => switch (index) {
        0 => 'حسابي',
        1 => 'فواتيري',
        2 => 'دفعاتي',
        _ => 'الإعدادات',
      };
}

class _CustomerDashboardTab extends GetView<CustomerHomeController> {
  const _CustomerDashboardTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shell = Get.find<CustomerShellController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final error = controller.errorMessage.value;
      if (error != null) {
        return AppErrorState(message: error, onRetry: controller.load);
      }

      final name = controller.customer.value?.name;
      final balances = controller.displayBalances;

      return RefreshIndicator(
        color: AppColors.gold,
        onRefresh: controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            96,
          ),
          children: [
            GoldShimmerText(
              name == null || name.isEmpty ? 'مرحباً بك' : 'مرحباً، $name',
              style: theme.textTheme.titleLarge,
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              blur: 14,
              glow: true,
              radius: AppRadii.xl,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldLight, AppColors.goldDark],
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.navyOnGold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'الرصيد الحالي',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GoldShimmerText(
                    FormatHelpers.moneyWithCurrency(
                      balances.syp,
                      AppCurrency.syp,
                    ),
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FormatHelpers.moneyWithCurrency(
                      balances.usd,
                      AppCurrency.usd,
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!controller.balanceFromProfile) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'تقديري من الفواتير والدفعات (الملف الشخصي غير متاح)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.10, curve: Curves.easeOutCubic),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    title: 'إجمالي الفواتير',
                    value:
                        '${FormatHelpers.moneyWithCurrency(controller.invoicesTotalSyp.value, AppCurrency.syp)}\n${FormatHelpers.moneyWithCurrency(controller.invoicesTotalUsd.value, AppCurrency.usd)}',
                    subtitle: '${controller.invoicesCount.value} فاتورة',
                    icon: Icons.receipt_long_rounded,
                    onTap: () => shell.setTab(1),
                  )
                      .animate(delay: 150.ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.08, curve: Curves.easeOutCubic),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _SummaryTile(
                    title: 'إجمالي الدفعات',
                    value:
                        '${FormatHelpers.moneyWithCurrency(controller.paymentsTotalSyp.value, AppCurrency.syp)}\n${FormatHelpers.moneyWithCurrency(controller.paymentsTotalUsd.value, AppCurrency.usd)}',
                    subtitle: '${controller.paymentsCount.value} دفعة',
                    icon: Icons.payments_rounded,
                    onTap: () => shell.setTab(2),
                  )
                      .animate(delay: 240.ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.08, curve: Curves.easeOutCubic),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldDark],
                ),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: -2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.navyOnGold, size: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
