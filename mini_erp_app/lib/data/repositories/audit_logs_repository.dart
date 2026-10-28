import '../models/audit_log.dart';
import '../models/paginated_response.dart';
import '../providers/audit_logs_provider.dart';

class AuditLogsRepository {
  AuditLogsRepository(this._provider);

  final AuditLogsProvider _provider;

  Future<PaginatedResponse<AuditLog>> list({
    int page = 1,
    int limit = 20,
    String? search,
    String? entity,
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _provider.list(
      page: page,
      limit: limit,
      search: search,
      entity: entity,
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
