import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/customers_controller.dart';
import '../../../utils/constants/app_colors.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              const FxAppBar(title: 'إعادة تعيين كلمة السر'),
              Expanded(
                child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'أدخل كلمة مرور جديدة لحساب الزبون',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Obx(
                () => TextField(
                  controller: controller.passwordController,
                  obscureText: controller.obscure.value,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => controller.obscure.toggle(),
                      icon: Icon(
                        controller.obscure.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(
                () => TextField(
                  controller: controller.confirmController,
                  obscureText: controller.obscure.value,
                  decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    prefixIcon: Icon(Icons.lock_person_outlined),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(() {
                final error = controller.errorMessage.value;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    error,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.submit,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('حفظ كلمة المرور'),
                ),
              ),
            ],
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
