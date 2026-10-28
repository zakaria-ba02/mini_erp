import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../utils/constants/app_colors.dart';

/// Headline text filled with a metallic gold gradient and a
/// repeating shimmer sweep.
class GoldShimmerText extends StatelessWidget {
  const GoldShimmerText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          AppColors.goldDark,
          AppColors.gold,
          AppColors.goldLight,
          AppColors.gold,
        ],
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? Theme.of(context).textTheme.titleLarge)?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 2400.ms,
          delay: 1200.ms,
          color: Colors.white.withValues(alpha: 0.35),
        );
  }
}
