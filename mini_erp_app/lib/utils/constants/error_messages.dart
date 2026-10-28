import 'package:dio/dio.dart';

/// Central mapping from backend error codes to Arabic user-facing messages.
class ErrorMessages {
  ErrorMessages._();

  static const String generic = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  static const String network =
      'تعذّر الاتصال بالخادم. تحقق من الشبكة وحاول مجددًا.';
  static const String sessionExpired =
      'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';
  static const String timeout = 'انتهت مهلة الاتصال. حاول مرة أخرى.';

  static const Map<String, String> _byCode = {
    'INVALID_CREDENTIALS': 'اسم المستخدم أو كلمة المرور غير صحيحة.',
    'VALIDATION_ERROR': 'البيانات المدخلة غير صالحة.',
    'CUSTOMER_NOT_FOUND': 'الزبون غير موجود.',
    'COST_NOT_FOUND': 'عنصر التكليف غير موجود.',
    'INVOICE_NOT_FOUND': 'الفاتورة غير موجودة.',
    'PAYMENT_NOT_FOUND': 'الدفعة غير موجودة.',
    'UNAUTHORIZED': 'غير مصرح لك بتنفيذ هذا الإجراء.',
    'FORBIDDEN': 'ليس لديك صلاحية للوصول إلى هذا المورد.',
    'NOT_FOUND': 'المورد المطلوب غير موجود.',
    'CONFLICT': 'تعارض في البيانات. تحقق من المدخلات.',
    'USERNAME_EXISTS': 'اسم المستخدم مستخدم مسبقًا.',
    'INTERNAL_ERROR': 'خطأ داخلي في الخادم. حاول لاحقًا.',
  };

  static String fromCode(String? code) {
    if (code == null || code.isEmpty) return generic;
    return _byCode[code] ?? generic;
  }

  /// Prefer status-aware mapping, then body codes — never raw JSON/English dumps.
  static String fromStatusCode(int? statusCode, [dynamic body]) {
    if (statusCode == 401) {
      final mapped = fromResponseBody(body);
      if (mapped != generic) return mapped;
      return sessionExpired;
    }
    if (statusCode == 403) return fromCode('FORBIDDEN');
    if (statusCode == 404) {
      final mapped = fromResponseBody(body);
      if (mapped != generic) return mapped;
      return fromCode('NOT_FOUND');
    }
    if (statusCode == 409) {
      final mapped = fromResponseBody(body);
      if (mapped != generic) return mapped;
      return fromCode('CONFLICT');
    }
    if (statusCode == 422 || statusCode == 400) {
      final mapped = fromResponseBody(body);
      if (mapped != generic) return mapped;
      return fromCode('VALIDATION_ERROR');
    }
    if (statusCode != null && statusCode >= 500) {
      return fromCode('INTERNAL_ERROR');
    }
    return fromResponseBody(body);
  }

  /// Extracts `errorCode` / `code` from typical NestJS / API error bodies.
  static String fromResponseBody(dynamic body) {
    if (body == null) return generic;

    if (body is Map) {
      final code = body['errorCode'] ?? body['code'] ?? body['error'];
      if (code is String && _byCode.containsKey(code)) {
        return _byCode[code]!;
      }

      final message = body['message'];
      if (message is String && message.trim().isNotEmpty) {
        if (_byCode.containsKey(message)) return _byCode[message]!;
        if (_looksLikeTechnicalMessage(message)) return generic;
        return message;
      }
      if (message is List && message.isNotEmpty) {
        final first = message.first.toString();
        if (_byCode.containsKey(first)) return _byCode[first]!;
        if (!_looksLikeTechnicalMessage(first)) return first;
      }
    }

    if (body is String && body.trim().isNotEmpty) {
      if (_byCode.containsKey(body)) return _byCode[body]!;
      if (!_looksLikeTechnicalMessage(body)) return body;
    }

    return generic;
  }

  /// Unified entry for any thrown object (Dio or otherwise).
  static String fromAny(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return timeout;
        case DioExceptionType.connectionError:
          return network;
        case DioExceptionType.badResponse:
          return fromStatusCode(
            error.response?.statusCode,
            error.response?.data,
          );
        case DioExceptionType.cancel:
          return generic;
        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
          return network;
      }
    }
    return generic;
  }

  static bool _looksLikeTechnicalMessage(String value) {
    final lower = value.toLowerCase();
    return lower.contains('exception') ||
        lower.contains('stack') ||
        lower.contains('{') ||
        lower.startsWith('error') ||
        lower.contains('cannot ') ||
        lower.contains('failed to') ||
        RegExp(r'^[A-Z][A-Z0-9_]+$').hasMatch(value);
  }
}
