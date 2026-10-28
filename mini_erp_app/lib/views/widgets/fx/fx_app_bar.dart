import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/theme_controller.dart';
import '../../../utils/constants/app_colors.dart';
import 'fx_icon_button.dart';

/// Transparent app bar in the Tarteel style: centered title (optionally
/// with a subtitle), squircle glass buttons on both sides.
/// Designed for scaffolds with `extendBodyBehindAppBar: true`.
class FxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FxAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.actions = const [],
    this.showThemeToggle = true,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? subtitle;
  final List<Widget> actions;
  final bool showThemeToggle;

  static const double baseHeight = kToolbarHeight;
  static const double subtitleHeight = 86;

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle == null ? baseHeight : subtitleHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    final themeController = Get.find<ThemeController>();

    final side = <Widget>[
      if (showThemeToggle)
        Obx(() {
          final isDark = themeController.isDark;
          return FxIconButton(
            tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onTap: themeController.toggleLightDark,
          );
        }),
      ...actions,
    ];

    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (titleWidget != null)
                  titleWidget!
                else if (title != null)
                  Text(
                    title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  subtitle!,
                ],
              ],
            ),
            if (canPop)
              PositionedDirectional(
                start: 0,
                child: FxIconButton(
                  tooltip: 'رجوع',
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const BackButtonIcon(),
                ),
              ),
            if (side.isNotEmpty)
              PositionedDirectional(
                end: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < side.length; i++) ...[
                      if (i != 0) const SizedBox(width: AppSpacing.sm),
                      side[i],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
