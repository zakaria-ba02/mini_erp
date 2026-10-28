import 'package:flutter/material.dart';

/// Design tokens from the Tarteel logo: navy field + metallic gold.
class AppColors {
  AppColors._();

  // Brand / accent (metallic gold — kept as `gold` for existing call sites)
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF1D78A);
  static const Color goldDark = Color(0xFFA8892A);
  static const Color navyOnGold = Color(0xFF041126);
  static const Color glow = Color(0xFF7EB8E8);

  // Light surfaces — warm ivory with navy text
  static const Color lightBackground = Color(0xFFF4F0E6);
  static const Color lightSurface = Color(0xFFFFFCF5);
  static const Color lightSurfaceMuted = Color(0xFFEDE6D6);
  static const Color lightTextPrimary = Color(0xFF041126);
  static const Color lightTextSecondary = Color(0xFF3D5270);
  static const Color lightBorder = Color(0xFFD4C9A8);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightSuccess = Color(0xFF1B7F4E);

  // Dark surfaces — deep navy, matching the splash
  static const Color darkBackground = Color(0xFF041126);
  static const Color darkSurface = Color(0xFF0A2342);
  static const Color darkSurfaceMuted = Color(0xFF122C4E);
  static const Color darkTextPrimary = Color(0xFFF5F0E6);
  static const Color darkTextSecondary = Color(0xFFB8C5D6);
  static const Color darkBorder = Color(0xFF1E3A5F);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkSuccess = Color(0xFF6FCF97);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadii {
  AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];
  }
}
