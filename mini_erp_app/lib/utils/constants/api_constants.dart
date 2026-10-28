import 'package:flutter/foundation.dart';

/// Override for physical devices on the same Wi‑Fi as the PC.
/// Set back to `null` when using Android Emulator (`10.0.2.2`).
const String? kApiBaseUrlOverride = 'http://192.168.1.106:3000';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    if (kApiBaseUrlOverride != null && kApiBaseUrlOverride!.isNotEmpty) {
      return kApiBaseUrlOverride!;
    }
    // Android emulator maps host machine localhost to 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const String health = '/health';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String customers = '/customers';
  static const String customersMe = '/customers/me';
  static const String costing = '/costing';
  static const String invoices = '/invoices';
  static const String payments = '/payments';
  static const String auditLogs = '/audit-logs';
  static const String fcmToken = '/users/me/fcm-token';
  /// Not in OpenAPI yet — confirm path with backend if change-password fails.
  static const String changePassword = '/users/me/password';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
