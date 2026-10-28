import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../utils/constants/app_colors.dart';

/// Frosted glass panel with a gold gradient border and soft glow.
/// Set [blur] > 0 for a real backdrop blur (use sparingly for hero cards).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.lg,
    this.blur = 0,
    this.glow = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final bool glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark
        ? Colors.white.withValues(alpha: 0.055)
        : Colors.white.withValues(alpha: 0.60);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.35 : 0.5),
        ),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.gold.withValues(alpha: isDark ? 0.10 : 0.16),
            fill,
            fill,
          ],
        ),
      ),
      child: child,
    );

    if (blur > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    content = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.28),
              blurRadius: 32,
              spreadRadius: -4,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: content,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: AppColors.gold.withValues(alpha: 0.15),
        highlightColor: AppColors.gold.withValues(alpha: 0.06),
        child: content,
      ),
    );
  }
}
