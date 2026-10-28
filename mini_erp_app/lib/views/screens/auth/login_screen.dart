import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../utils/constants/app_assets.dart';
import '../../../utils/constants/app_colors.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/glass_card.dart';
import '../../widgets/fx/gold_shimmer_text.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const FxAppBar(title: 'تسجيل الدخول'),
      body: AppFxBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                kToolbarHeight + AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.gold.withValues(alpha: 0.30),
                                AppColors.gold.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.1, 1.1),
                              duration: 2400.ms,
                              curve: Curves.easeInOut,
                            ),
                        Image.asset(
                          AppAssets.tarteelLogo,
                          height: 150,
                          fit: BoxFit.contain,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(
                              begin: const Offset(0.88, 0.88),
                              curve: Curves.easeOutBack,
                            ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GoldShimmerText(
                      'مرحباً بك',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'أدخل بيانات حسابك للمتابعة',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 160.ms),
                    const SizedBox(height: AppSpacing.lg),
                    GlassCard(
                      blur: 14,
                      glow: true,
                      radius: AppRadii.xl,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: controller.usernameController,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            decoration: const InputDecoration(
                              labelText: 'اسم المستخدم',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            onChanged: (_) => controller.clearError(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Obx(
                            () => TextField(
                              controller: controller.passwordController,
                              obscureText: controller.obscurePassword.value,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) => controller.login(),
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                prefixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  onPressed: controller.toggleObscurePassword,
                                  icon: Icon(
                                    controller.obscurePassword.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              onChanged: (_) => controller.clearError(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Obx(() {
                            final error = controller.errorMessage.value;
                            if (error == null) return const SizedBox.shrink();
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                                border: Border.all(
                                  color: theme.colorScheme.error
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn()
                                .shake(hz: 2.5, rotation: 0.01);
                          }),
                          Obx(
                            () => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.login,
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('دخول'),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 220.ms, duration: 500.ms)
                        .slideY(begin: 0.10, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
