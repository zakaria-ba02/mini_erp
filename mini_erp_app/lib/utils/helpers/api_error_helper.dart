import '../constants/error_messages.dart';

/// Maps Dio / backend errors to Arabic messages for UI.
class ApiErrorHelper {
  ApiErrorHelper._();

  static String messageOf(Object error) {
    // Deferred import pattern avoided — callers use DioClient.mapError.
    // Kept as alias for screens/controllers that prefer this name.
    return ErrorMessages.fromAny(error);
  }

  static String fromStatusCode(int? statusCode, [dynamic body]) {
    return ErrorMessages.fromStatusCode(statusCode, body);
  }
}
