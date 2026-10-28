import 'package:dio/dio.dart';

import '../../utils/constants/api_constants.dart';
import '../../utils/dio/dio_client.dart';
import '../models/app_currency.dart';
import '../models/customer.dart';
import '../models/customer_requests.dart';
import '../models/paginated_response.dart';
import '../models/settlement.dart';

class CustomersProvider {
  CustomersProvider({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<PaginatedResponse<Customer>> list({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customers,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      Customer.fromJson,
    );
  }

  Future<Customer> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.customers}/$id',
    );
    return Customer.fromJson(response.data ?? {});
  }

  /// GET /customers/me — own profile for the customer role.
  Future<Customer> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customersMe,
    );
    return Customer.fromJson(response.data ?? {});
  }

  Future<Customer> create(CreateCustomerRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.customers,
      data: request.toJson(),
    );
    final data = response.data ?? {};
    final customerRaw = data['customer'];
    if (customerRaw is Map) {
      return Customer.fromJson(Map<String, dynamic>.from(customerRaw));
    }
    return Customer.fromJson(data);
  }

  Future<Customer> update(String id, UpdateCustomerRequest request) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.customers}/$id',
      data: request.toJson(),
    );
    final data = response.data ?? {};
    final customerRaw = data['customer'];
    if (customerRaw is Map) {
      return Customer.fromJson(Map<String, dynamic>.from(customerRaw));
    }
    return Customer.fromJson(data);
  }

  Future<void> resetPassword(
    String id,
    ResetCustomerPasswordRequest request,
  ) async {
    await _dio.post(
      '${ApiConstants.customers}/$id/reset-password',
      data: request.toJson(),
    );
  }

  Future<void> delete(String id) async {
    await _dio.delete('${ApiConstants.customers}/$id');
  }

  Future<void> settle(String id, AppCurrency currency) async {
    await _dio.post(
      '${ApiConstants.customers}/$id/settle',
      data: {'currency': currency.apiValue},
    );
  }

  Future<PaginatedResponse<Settlement>> listSettlements(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.customers}/$id/settlements',
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      Settlement.fromJson,
    );
  }
}
