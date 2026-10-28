import '../models/cost.dart';
import '../models/paginated_response.dart';
import '../providers/costing_provider.dart';

class CostingRepository {
  CostingRepository(this._provider);

  final CostingProvider _provider;

  Future<PaginatedResponse<Cost>> list({
    int page = 1,
    int limit = 20,
    String? search,
  }) {
    return _provider.list(page: page, limit: limit, search: search);
  }

  Future<Cost> getById(String id) => _provider.getById(id);

  Future<Cost> create(UpsertCostRequest request) => _provider.create(request);

  Future<Cost> update(String id, UpsertCostRequest request) =>
      _provider.update(id, request);

  Future<void> delete(String id) => _provider.delete(id);
}
