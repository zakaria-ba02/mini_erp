import 'package:dio/dio.dart';

import '../../utils/constants/api_constants.dart';
import '../../utils/dio/dio_client.dart';
import '../models/auth_tokens_response.dart';
import '../models/login_request.dart';
import '../models/refresh_token_request.dart';

class AuthProvider {
  AuthProvider({Dio? dio, Dio? refreshDio})
      : _dio = dio ?? DioClient.instance,
        _refreshDio = refreshDio ?? DioClient.createRefreshDio();

  final Dio _dio;
  final Dio _refreshDio;

  Future<AuthTokensResponse> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: request.toJson(),
      options: Options(extra: {DioClient.skipAuthExtra: true}),
    );
    return AuthTokensResponse.fromJson(response.data ?? {});
  }

  /// Uses a bare Dio (no auth interceptor) to avoid refresh loops.
  Future<AuthTokensResponse> refresh(RefreshTokenRequest request) async {
    final response = await _refreshDio.post<Map<String, dynamic>>(
      ApiConstants.refresh,
      data: request.toJson(),
    );
    return AuthTokensResponse.fromJson(response.data ?? {});
  }

  Future<void> logout() async {
    await _dio.post(
      ApiConstants.logout,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }
}
