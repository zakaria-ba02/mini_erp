import '../models/app_currency.dart';
import '../models/paginated_response.dart';
import '../models/payment.dart';
import '../providers/payments_provider.dart';

class PaymentsRepository {
  PaymentsRepository(this._provider);

  final PaymentsProvider _provider;

  Future<PaginatedResponse<Payment>> list({
    int page = 1,
    int limit = 20,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    AppCurrency? currency,
    String? settlementId,
  }) {
    return _provider.list(
      page: page,
      limit: limit,
      customerId: customerId,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
      currency: currency,
      settlementId: settlementId,
    );
  }

  Future<Payment> getById(String id) => _provider.getById(id);

  Future<Payment> create(UpsertPaymentRequest request) =>
      _provider.create(request);

  Future<Payment> update(String id, UpsertPaymentRequest request) =>
      _provider.update(id, request);

  Future<void> delete(String id) => _provider.delete(id);
}
