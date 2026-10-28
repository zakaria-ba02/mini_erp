import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/error_messages.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  /// Extra flag: skip attaching Bearer (login / public calls).
  static const skipAuthExtra = 'skipAuth';

  /// Extra flag: 401 must not refresh or clear the session (FCM sync).
  static const skipSessionInvalidationExtra = 'skipSessionInvalidation';

  /// Extra flag: request already retried after refresh.
  static const retriedExtra = 'retriedAfterRefresh';

  static Dio? _dio;

  static Dio get instance {
    _dio ??= _create();
    return _dio!;
  }

  /// Bare client for token refresh — no AuthInterceptor (avoids loops).
  static Dio createRefreshDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );
  }

  static void reset() {
    _dio = null;
  }

  static Dio _create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(AuthInterceptor(dio: dio));

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // ignore: avoid_print
          print(obj);
        },
      ),
    );

    return dio;
  }

  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return instance.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return instance.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return instance.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return instance.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static String mapError(Object error) => ErrorMessages.fromAny(error);
}
