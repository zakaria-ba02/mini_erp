import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/customer_portal_controller.dart';
import '../../../data/models/customer.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/app_colors.dart';
import '../../widgets/fx/glass_card.dart';
import '../../widgets/fx/press_scale.dart';

class CustomerSettingsTab extends GetView<CustomerSettingsController> {
  const CustomerSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Get.find<AuthController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // The profile endpoint is admin-only for the customer role, so fall
      // back to the name/phone embedded in the user's invoices/payments.
      final Customer? c = controller.customer.value;
      final home = Get.isRegistered<CustomerHomeController>()
          ? Get.find<CustomerHomeController>()
          : null;
      final name = c?.name ?? home?.displayName;
      final phone = c?.phone ?? home?.displayPhone;

      return ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          96,
        ),
        children: [
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
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.goldLight, AppColors.goldDark],
                        ),
                      ),
                      child: Text(
                        (name != null && name.isNotEmpty) ? name[0] : '؟',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyOnGold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'معلومات الحساب',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _InfoRow('الاسم', name ?? '—'),
                const Divider(height: AppSpacing.lg),
                _InfoRow('الهاتف', phone ?? '—'),
                if (c?.notes != null && c!.notes!.isNotEmpty) ...[
                  const Divider(height: AppSpacing.lg),
                  _InfoRow('ملاحظات', c.notes!),
                ],
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.06, curve: Curves.easeOutCubic),
          const SizedBox(height: AppSpacing.lg),
          PressScale(
            onTap: () => Get.toNamed(AppRoutes.customerChangePassword),
            child: GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldLight, AppColors.goldDark],
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 14,
                          spreadRadius: -2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.navyOnGold,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تغيير كلمة المرور',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'تعديل كلمة مرور حسابك',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.gold,
                  ),
                ],
              ),
            ),
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.06, curve: Curves.easeOutCubic),
          const SizedBox(height: AppSpacing.lg),
          PressScale(
            onTap: auth.logout,
            child: GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: theme.colorScheme.error,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'تسجيل الخروج',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            ),
          )
              .animate(delay: 180.ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.06, curve: Curves.easeOutCubic),
        ],
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
