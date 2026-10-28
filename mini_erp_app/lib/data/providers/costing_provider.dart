import 'package:dio/dio.dart';

import '../../utils/constants/api_constants.dart';
import '../../utils/dio/dio_client.dart';
import '../models/cost.dart';
import '../models/paginated_response.dart';

class CostingProvider {
  CostingProvider({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<PaginatedResponse<Cost>> list({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.costing,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return PaginatedResponse.fromJson(response.data ?? {}, Cost.fromJson);
  }

  Future<Cost> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.costing}/$id',
    );
    return Cost.fromJson(response.data ?? {});
  }

  Future<Cost> create(UpsertCostRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.costing,
      data: request.toJson(),
    );
    return Cost.fromJson(response.data ?? {});
  }

  Future<Cost> update(String id, UpsertCostRequest request) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.costing}/$id',
      data: request.toJson(),
    );
    return Cost.fromJson(response.data ?? {});
  }

  Future<void> delete(String id) async {
    await _dio.delete('${ApiConstants.costing}/$id');
  }
}
