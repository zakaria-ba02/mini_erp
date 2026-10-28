import 'package:flutter/material.dart';

import '../../../utils/constants/app_colors.dart';

/// Rounded-square glass icon button (squircle) with a gold icon —
/// used in app bars and headers.
class FxIconButton extends StatelessWidget {
  const FxIconButton({
    super.key,
    this.icon,
    this.child,
    this.onTap,
    this.tooltip,
    this.size = 44,
  }) : assert(icon != null || child != null);

  final IconData? icon;
  final Widget? child;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget button = Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.gold.withValues(alpha: 0.2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: isDark ? 0.35 : 0.5),
            ),
          ),
          child: IconTheme(
            data: IconThemeData(color: AppColors.gold, size: size * 0.5),
            child: child ?? Icon(icon),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
