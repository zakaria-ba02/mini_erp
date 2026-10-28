import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/jwt_payload.dart';
import '../data/models/user_role.dart';
import '../data/repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import '../utils/constants/error_messages.dart';
import '../utils/dio/dio_client.dart';
import '../utils/notifications/notification_service.dart';

class AuthController extends GetxController {
  AuthController(this._repository);

  final AuthRepository _repository;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final errorMessage = RxnString();
  final session = Rxn<JwtPayload>();

  bool get isLoggedIn => session.value != null;
  UserRole? get role => session.value?.role;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscurePassword() =>
      obscurePassword.value = !obscurePassword.value;

  void clearError() => errorMessage.value = null;

  Future<JwtPayload?> restoreSession() async {
    final payload = await _repository.restoreSession();
    session.value = payload;
    if (payload != null) {
      await _syncFcm();
      if (!await _hasActiveSession()) {
        session.value = null;
        return null;
      }
    }
    return session.value;
  }

  Future<bool> _hasActiveSession() async {
    if (session.value == null) return false;
    final token = await _repository.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _syncFcm() async {
    if (Get.isRegistered<NotificationService>()) {
      await Get.find<NotificationService>().syncTokenAfterAuth();
    }
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = 'أدخل اسم المستخدم وكلمة المرور.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final tokens = await _repository.login(
        username: username,
        password: password,
      );
      final payload = _repository.decodeAccessToken(tokens.accessToken);
      if (payload == null) {
        await _repository.clearSession();
        errorMessage.value = ErrorMessages.generic;
        return;
      }
      session.value = payload;
      passwordController.clear();
      await _syncFcm();
      if (!await _hasActiveSession()) {
        session.value = null;
        errorMessage.value = ErrorMessages.generic;
        return;
      }
      _navigateByRole(payload.role);
    } on DioException catch (e) {
      final mapped = DioClient.mapError(e);
      if (e.response?.statusCode == 401) {
        // Never reveal whether username or password was wrong.
        errorMessage.value = ErrorMessages.fromCode('INVALID_CREDENTIALS');
      } else {
        errorMessage.value = mapped;
      }
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _repository.logout();
    } finally {
      session.value = null;
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _navigateByRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        Get.offAllNamed(AppRoutes.adminHome);
      case UserRole.customer:
        Get.offAllNamed(AppRoutes.customerHome);
    }
  }

  String homeRouteForRole(UserRole role) {
    return switch (role) {
      UserRole.admin => AppRoutes.adminHome,
      UserRole.customer => AppRoutes.customerHome,
    };
  }
}
