import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/customer_portal_controller.dart';
import '../../../utils/constants/app_colors.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/glass_card.dart';

/// Standalone password change screen for the customer role.
/// Reuses [CustomerSettingsController], which stays alive under the shell.
class CustomerChangePasswordScreen extends GetView<CustomerSettingsController> {
  const CustomerChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              const FxAppBar(title: 'تغيير كلمة المرور'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: GlassCard(
                    blur: 14,
                    glow: true,
                    radius: AppRadii.xl,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.goldLight,
                                  AppColors.goldDark,
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.lg),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.navyOnGold,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'أدخل كلمة المرور الحالية ثم الجديدة.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Obx(() {
                          final obscure = controller.obscure.value;
                          return Column(
                            children: [
                              TextField(
                                controller: controller.oldPasswordController,
                                obscureText: obscure,
                                decoration: const InputDecoration(
                                  labelText: 'كلمة المرور الحالية',
                                  prefixIcon:
                                      Icon(Icons.lock_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextField(
                                controller: controller.newPasswordController,
                                obscureText: obscure,
                                decoration: const InputDecoration(
                                  labelText: 'كلمة المرور الجديدة',
                                  prefixIcon: Icon(Icons.password_rounded),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextField(
                                controller:
                                    controller.confirmPasswordController,
                                obscureText: obscure,
                                decoration: InputDecoration(
                                  labelText: 'تأكيد كلمة المرور',
                                  prefixIcon:
                                      const Icon(Icons.lock_person_outlined),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        controller.obscure.value = !obscure,
                                    icon: Icon(
                                      obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        Obx(() {
                          final err = controller.errorMessage.value;
                          final ok = controller.successMessage.value;
                          if (err == null && ok == null) {
                            return const SizedBox(height: AppSpacing.lg);
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Text(
                              err ?? ok!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: err != null
                                    ? theme.colorScheme.error
                                    : theme.brightness == Brightness.dark
                                        ? AppColors.darkSuccess
                                        : AppColors.lightSuccess,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ).animate().fadeIn();
                        }),
                        Obx(
                          () => ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : controller.changePassword,
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('حفظ كلمة المرور'),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
