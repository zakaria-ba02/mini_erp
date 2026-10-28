import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../utils/constants/app_colors.dart';

class FxBottomNavItem {
  const FxBottomNavItem({required this.icon, this.tooltip});

  final IconData icon;
  final String? tooltip;
}

/// Floating glass pill navigation bar. The selected item pops up as a
/// glowing gold circle, like the Tarteel mockup.
class FxBottomNav extends StatelessWidget {
  const FxBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<FxBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: SizedBox(
        height: 68,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF06182F).withValues(alpha: 0.82)
                          : Colors.white.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.gold
                            .withValues(alpha: isDark ? 0.30 : 0.45),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FxBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: selected ? 1 : 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, t, _) {
            return Transform.translate(
              offset: Offset(0, -10 * t),
              child: Container(
                width: 46 + 6 * t,
                height: 46 + 6 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: t > 0.05
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.goldLight, AppColors.goldDark],
                        )
                      : null,
                  boxShadow: t > 0.05
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.45 * t),
                            blurRadius: 18,
                            spreadRadius: -2,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  item.icon,
                  color: Color.lerp(
                    theme.colorScheme.onSurfaceVariant,
                    AppColors.navyOnGold,
                    t,
                  ),
                  size: 24,
                ),
              ),
            );
          },
        ),
      ),
    );

    if (item.tooltip != null) {
      button = Tooltip(message: item.tooltip!, child: button);
    }
    return button;
  }
}
