import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../../data/models/auth_tokens_response.dart';
import '../../data/models/refresh_token_request.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants/api_constants.dart';
import '../../utils/storage/secure_storage_service.dart';
import 'dio_client.dart';

/// Attaches Bearer token and rotates session on 401 via `/auth/refresh`.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    SecureStorageService? storage,
    Dio? refreshDio,
  })  : _dio = dio,
        _storage = storage,
        _refreshDio = refreshDio ?? DioClient.createRefreshDio();

  final Dio _dio;
  final Dio _refreshDio;
  SecureStorageService? _storage;

  SecureStorageService get storage {
    _storage ??= Get.isRegistered<SecureStorageService>()
        ? Get.find<SecureStorageService>()
        : SecureStorageService();
    return _storage!;
  }

  bool _isPublicPath(String path) {
    return path.endsWith(ApiConstants.login) ||
        path.endsWith(ApiConstants.refresh) ||
        path.endsWith(ApiConstants.health);
  }

  bool _skipSessionInvalidation(RequestOptions options) {
    return options.extra[DioClient.skipSessionInvalidationExtra] == true ||
        options.path.endsWith(ApiConstants.fcmToken);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skip = options.extra[DioClient.skipAuthExtra] == true;
    if (!skip && !_isPublicPath(options.path)) {
      final token = await storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      } else if (!_skipSessionInvalidation(options)) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: 'Missing access token',
          ),
        );
        return;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final options = err.requestOptions;
    final alreadyRetried = options.extra[DioClient.retriedExtra] == true;
    final isPublic = _isPublicPath(options.path) ||
        options.extra[DioClient.skipAuthExtra] == true;

    if (status != 401 ||
        alreadyRetried ||
        isPublic ||
        _skipSessionInvalidation(options)) {
      handler.next(err);
      return;
    }

    try {
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _forceLogout();
        handler.next(err);
        return;
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      );
      final tokens = AuthTokensResponse.fromJson(response.data ?? {});
      await storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      options.extra[DioClient.retriedExtra] = true;

      final retryResponse = await _dio.fetch(options);
      handler.resolve(retryResponse);
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Token refresh failed: $e\n$st');
      }
      await _forceLogout();
      handler.next(err);
    }
  }

  Future<void> _forceLogout() async {
    try {
      await storage.clearAll();
    } catch (_) {}

    if (Get.key.currentContext != null) {
      final current = Get.currentRoute;
      if (current != AppRoutes.login && current != AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }
}
