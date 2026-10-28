import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/app_assets.dart';
import '../../../utils/constants/app_colors.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/fx_bottom_nav.dart';
import '../../widgets/fx/fx_icon_button.dart';
import '../../widgets/fx/glass_card.dart';
import '../../widgets/fx/gold_shimmer_text.dart';
import '../../widgets/fx/press_scale.dart';

class AdminHomeScreen extends GetView<AuthController> {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: FxAppBar(
        title: 'لوحة الأدمن',
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
          FxIconButton(
            tooltip: 'تسجيل الخروج',
            icon: Icons.logout_rounded,
            onTap: controller.logout,
          ),
        ],
      ),
      bottomNavigationBar: FxBottomNav(
        currentIndex: 2,
        items: const [
          FxBottomNavItem(
            icon: Icons.history_rounded,
            tooltip: 'سجل التدقيق',
          ),
          FxBottomNavItem(
            icon: Icons.calculate_rounded,
            tooltip: 'التكليف',
          ),
          FxBottomNavItem(icon: Icons.home_rounded, tooltip: 'الرئيسية'),
          FxBottomNavItem(
            icon: Icons.receipt_long_rounded,
            tooltip: 'الفواتير',
          ),
          FxBottomNavItem(icon: Icons.groups_rounded, tooltip: 'الزبائن'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Get.toNamed(AppRoutes.auditLogs);
            case 1:
              Get.toNamed(AppRoutes.costing);
            case 3:
              Get.toNamed(AppRoutes.invoices);
            case 4:
              Get.toNamed(AppRoutes.customers);
          }
        },
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
      body: AppFxBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              FxAppBar.subtitleHeight + AppSpacing.md,
              AppSpacing.lg,
              96,
            ),
            children: [
              GlassCard(
                blur: 14,
                glow: true,
                radius: AppRadii.xl,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Image.asset(
                      AppAssets.tarteelLogo,
                      width: 84,
                      height: 84,
                      fit: BoxFit.contain,
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.07, 1.07),
                          duration: 2200.ms,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GoldShimmerText(
                            'مرحباً، أدمن',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'اختر وحدة للإدارة من القائمة أدناه.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.10, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSpacing.lg),
              ..._buildModuleTiles(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildModuleTiles() {
    final modules = [
      (
        Icons.groups_rounded,
        'الزبائن',
        'إضافة، تعديل، حذف وإعادة تعيين كلمة السر',
        AppRoutes.customers,
      ),
      (
        Icons.calculate_rounded,
        'التكليف',
        'حساب التكاليف وكتالوج الألواح',
        AppRoutes.costing,
      ),
      (
        Icons.receipt_long_rounded,
        'الفواتير',
        'إنشاء وتعديل وحذف الفواتير',
        AppRoutes.invoices,
      ),
      (
        Icons.payments_rounded,
        'الدفعات',
        'تسجيل وتعديل وحذف الدفعات',
        AppRoutes.payments,
      ),
      (
        Icons.history_rounded,
        'سجل التدقيق',
        'عرض العمليات الحساسة (قراءة فقط)',
        AppRoutes.auditLogs,
      ),
    ];

    final tiles = <Widget>[];
    for (var i = 0; i < modules.length; i++) {
      final (icon, title, subtitle, route) = modules[i];
      tiles.add(
        _ModuleTile(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onTap: () => Get.toNamed(route),
        )
            .animate(delay: (120 + i * 90).ms)
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.08, curve: Curves.easeOutCubic)
            .scale(
              begin: const Offset(0.97, 0.97),
              curve: Curves.easeOutBack,
            ),
      );
      if (i != modules.length - 1) {
        tiles.add(const SizedBox(height: AppSpacing.md));
      }
    }
    return tiles;
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
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
    final isDark = theme.brightness == Brightness.dark;

    return PressScale(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Stack(
            children: [
              // Ghost watermark icon on the far (chevron) side.
              PositionedDirectional(
                end: 6,
                top: -14,
                child: Icon(
                  icon,
                  size: 96,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: isDark ? 0.05 : 0.07),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.goldLight, AppColors.goldDark],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold
                                .withValues(alpha: isDark ? 0.4 : 0.45),
                            blurRadius: 14,
                            spreadRadius: -2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child:
                          Icon(icon, color: AppColors.navyOnGold, size: 26),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
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
            ],
          ),
        ),
      ),
    );
  }
}
