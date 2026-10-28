import 'package:dio/dio.dart';

import '../../utils/constants/api_constants.dart';
import '../../utils/dio/dio_client.dart';
import '../models/app_currency.dart';
import '../models/paginated_response.dart';
import '../models/payment.dart';

class PaymentsProvider {
  PaymentsProvider({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<PaginatedResponse<Payment>> list({
    int page = 1,
    int limit = 20,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    AppCurrency? currency,
    String? settlementId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.payments,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (customerId != null && customerId.isNotEmpty)
          'customerId': customerId,
        if (fromDate != null) 'fromDate': fromDate.toUtc().toIso8601String(),
        if (toDate != null) 'toDate': toDate.toUtc().toIso8601String(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (currency != null) 'currency': currency.apiValue,
        if (settlementId != null && settlementId.isNotEmpty)
          'settlementId': settlementId,
      },
    );
    return PaginatedResponse.fromJson(response.data ?? {}, Payment.fromJson);
  }

  Future<Payment> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.payments}/$id',
    );
    return Payment.fromJson(response.data ?? {});
  }

  Future<Payment> create(UpsertPaymentRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.payments,
      data: request.toJson(),
    );
    return Payment.fromJson(response.data ?? {});
  }

  Future<Payment> update(String id, UpsertPaymentRequest request) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.payments}/$id',
      data: request.toJson(),
    );
    return Payment.fromJson(response.data ?? {});
  }

  Future<void> delete(String id) async {
    await _dio.delete('${ApiConstants.payments}/$id');
  }
}
