import 'package:dio/dio.dart';

import '../../utils/constants/api_constants.dart';
import '../../utils/dio/dio_client.dart';
import '../models/app_currency.dart';
import '../models/invoice.dart';
import '../models/paginated_response.dart';

class InvoicesProvider {
  InvoicesProvider({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<PaginatedResponse<Invoice>> list({
    int page = 1,
    int limit = 20,
    String? customerId,
    InvoiceStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    AppCurrency? currency,
    String? settlementId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.invoices,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (customerId != null && customerId.isNotEmpty)
          'customerId': customerId,
        if (status != null) 'status': status.apiValue,
        if (fromDate != null) 'fromDate': fromDate.toUtc().toIso8601String(),
        if (toDate != null) 'toDate': toDate.toUtc().toIso8601String(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (currency != null) 'currency': currency.apiValue,
        if (settlementId != null && settlementId.isNotEmpty)
          'settlementId': settlementId,
      },
    );
    return PaginatedResponse.fromJson(response.data ?? {}, Invoice.fromJson);
  }

  Future<Invoice> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.invoices}/$id',
    );
    return Invoice.fromJson(response.data ?? {});
  }

  Future<Invoice> create(CreateInvoiceRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.invoices,
      data: request.toJson(),
    );
    return Invoice.fromJson(response.data ?? {});
  }

  Future<Invoice> update(String id, UpdateInvoiceRequest request) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.invoices}/$id',
      data: request.toJson(),
    );
    return Invoice.fromJson(response.data ?? {});
  }

  Future<void> delete(String id) async {
    await _dio.delete('${ApiConstants.invoices}/$id');
  }
}
