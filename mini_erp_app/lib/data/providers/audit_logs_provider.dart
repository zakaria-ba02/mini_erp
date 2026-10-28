import 'package:dio/dio.dart';

import '../../utils/constants/api_constants.dart';
import '../../utils/dio/dio_client.dart';
import '../models/audit_log.dart';
import '../models/paginated_response.dart';

class AuditLogsProvider {
  AuditLogsProvider({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<PaginatedResponse<AuditLog>> list({
    int page = 1,
    int limit = 20,
    String? search,
    String? entity,
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.auditLogs,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (entity != null && entity.isNotEmpty) 'entity': entity,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        if (fromDate != null) 'fromDate': fromDate.toUtc().toIso8601String(),
        if (toDate != null) 'toDate': toDate.toUtc().toIso8601String(),
      },
    );
    return PaginatedResponse.fromJson(response.data ?? {}, AuditLog.fromJson);
  }
}
