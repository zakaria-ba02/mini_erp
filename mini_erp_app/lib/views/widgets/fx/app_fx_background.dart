import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../utils/constants/app_colors.dart';

/// Animated ambient background: deep gradient with slowly drifting
/// glow orbs (gold + cool blue) painted behind the screen content.
class AppFxBackground extends StatefulWidget {
  const AppFxBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AppFxBackground> createState() => _AppFxBackgroundState();
}

class _AppFxBackgroundState extends State<AppFxBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A2342),
                      AppColors.darkBackground,
                      Color(0xFF020817),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFDF9EE),
                      AppColors.lightBackground,
                      Color(0xFFEDE4CE),
                    ],
                  ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _GlowOrbsPainter(
              progress: _controller.value,
              isDark: isDark,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GlowOrbsPainter extends CustomPainter {
  _GlowOrbsPainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    final baseAlpha = isDark ? 0.20 : 0.16;

    void orb(double cx, double cy, double radius, Color color, double alpha) {
      final rect = Rect.fromCircle(
        center: Offset(cx * size.width, cy * size.height),
        radius: radius,
      );
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(rect);
      canvas.drawCircle(rect.center, radius, paint);
    }

    orb(
      0.85 + 0.08 * math.sin(t),
      0.12 + 0.05 * math.cos(t * 0.8),
      size.width * 0.55,
      AppColors.gold,
      baseAlpha,
    );
    orb(
      0.10 + 0.07 * math.cos(t * 0.6),
      0.45 + 0.06 * math.sin(t * 0.9),
      size.width * 0.45,
      isDark ? AppColors.glow : AppColors.goldLight,
      baseAlpha * 0.8,
    );
    orb(
      0.55 + 0.10 * math.sin(t * 0.7 + 2),
      0.92 + 0.04 * math.cos(t + 1),
      size.width * 0.5,
      AppColors.goldDark,
      baseAlpha * 0.7,
    );
  }

  @override
  bool shouldRepaint(_GlowOrbsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
