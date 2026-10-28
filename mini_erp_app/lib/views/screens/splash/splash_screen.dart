import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/theme_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/app_assets.dart';
import '../../../utils/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusText = 'جاري التهيئة…';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() => _statusText = 'التحقق من الجلسة…');

    final auth = Get.find<AuthController>();
    try {
      final payload = await auth
          .restoreSession()
          .timeout(const Duration(seconds: 8), onTimeout: () => null);
      if (!mounted) return;

      if (payload != null) {
        Get.offAllNamed(auth.homeRouteForRole(payload.role));
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (_) {
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.darkBackground,
      ),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.15),
              radius: 1.05,
              colors: [
                Color(0xFF0A2A52),
                AppColors.darkBackground,
                Color(0xFF020817),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Obx(() {
                      final isDark = themeController.isDark;
                      return IconButton(
                        tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
                        onPressed: themeController.toggleLightDark,
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: AppColors.gold,
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 330,
                        height: 330,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0.28),
                              AppColors.gold.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1.12, 1.12),
                            duration: 2600.ms,
                            curve: Curves.easeInOut,
                          )
                          .fade(begin: 0.6, end: 1),
                      Image.asset(
                        AppAssets.tarteelLogo,
                        width: 280,
                        fit: BoxFit.contain,
                      )
                          .animate()
                          .fadeIn(duration: 700.ms)
                          .scale(
                            begin: const Offset(0.92, 0.92),
                            curve: Curves.easeOut,
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(
                            duration: 2800.ms,
                            delay: 1400.ms,
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    _statusText,
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: AppSpacing.lg),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.gold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'الخادم: ${ApiConstants.baseUrl}',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
