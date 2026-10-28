import 'package:dio/dio.dart';

import '../../utils/constants/api_constants.dart';
import '../../utils/dio/dio_client.dart';

class UsersProvider {
  UsersProvider({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  /// OpenAPI: PATCH /users/me/fcm-token — UpdateFcmTokenDto { fcmToken }
  Future<void> updateFcmToken(String fcmToken) async {
    await _dio.patch(
      ApiConstants.fcmToken,
      data: {'fcmToken': fcmToken},
      options: Options(
        extra: {DioClient.skipSessionInvalidationExtra: true},
      ),
    );
  }

  /// Not documented in openapi-spec.json yet.
  /// Expected Nest shape: { oldPassword, newPassword }.
  /// If backend uses a different path, update [ApiConstants.changePassword].
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.patch(
      ApiConstants.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }
}
